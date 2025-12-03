import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/online_game_provider.dart';
import '../models/carta.dart';
import '../models/partida.dart';
import '../services/websocket_service.dart'; // Para PlayerInfo
import '../utils/avatar_helper.dart';
import '../widgets/carta_widget.dart';
import '../theme/app_theme.dart';
import 'package:animate_do/animate_do.dart';
import '../models/partida.dart';
import '../models/carta.dart';
import 'dart:math';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // State for animations
  Map<int, MatchDetails> _pileAnimations = {};
  Map<int, bool> _pileHalos = {}; // Para el halo rojo de otros jugadores
  StreamSubscription? _cardPlayedSubscription;
  List<String> _lastSortedIds = [];

  @override
  void initState() {
    super.initState();
    
    // Listen to card played events for animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final onlineProvider = Provider.of<OnlineGameProvider>(context, listen: false);
      if (onlineProvider.isOnline) {
        _cardPlayedSubscription = onlineProvider.cardPlayedStream.listen((data) {
          if (!mounted) return;
          
          final pileIndex = data['pileIndex'] as int;
          final playerId = data['playerId'] as String;
          final isMe = playerId == onlineProvider.currentUser?.id;
          
          if (isMe) {
            // Animación de operaciones para mí
            final matchDetailsMap = data['matchDetails'] as Map<String, dynamic>;
            final matchDetails = MatchDetails.fromJson(matchDetailsMap);
            
            setState(() {
              _pileAnimations[pileIndex] = matchDetails;
            });
            
            Future.delayed(const Duration(milliseconds: 2000), () {
              if (mounted) {
                setState(() {
                  _pileAnimations.remove(pileIndex);
                });
              }
            });
          } else {
            // Halo rojo para otros
            setState(() {
              _pileHalos[pileIndex] = true;
            });
            
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() {
                  _pileHalos.remove(pileIndex);
                });
              }
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _cardPlayedSubscription?.cancel();
    super.dispose();
  }

  void _handleCardDiscard(Carta carta, int pileIndex) {
    final onlineProvider = Provider.of<OnlineGameProvider>(context, listen: false);
    // En modo online, enviar al servidor
    final myHand = onlineProvider.myHand;
    final cardIndex = myHand.indexWhere((c) => 
      c.multiplicaciones == carta.multiplicaciones &&
      c.division == carta.division &&
      c.resultados == carta.resultados
    );
    
    if (cardIndex >= 0) {
      onlineProvider.playCard(cardIndex, pileIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onlineProvider = Provider.of<OnlineGameProvider>(context);
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Obtener datos del provider online
    final List<Carta> myHand = onlineProvider.myHand;
    final List<List<Carta>> discardPiles = onlineProvider.discardPiles;
    
    int myDeckSize = 0;
    // Find my player info to get deck size
    if (onlineProvider.players.isNotEmpty) {
      final myPlayer = onlineProvider.players.firstWhere(
        (p) => p.id == onlineProvider.currentUser?.id, 
        orElse: () => PlayerInfo(id: '', alias: '', handSize: 0, personalDeckSize: 0, penalties: 0)
      );
      myDeckSize = myPlayer.personalDeckSize;
      debugPrint('[GameScreen] MyPlayer: ${myPlayer.alias}, DeckSize: $myDeckSize, Players: ${onlineProvider.players.length}');
    }

    debugPrint('[GameScreen] Mode: ONLINE, Hand: ${myHand.length}, Piles: ${discardPiles.map((p) => p.length).toList()}');
    
    // Fixed margins - NEVER change with screen size
    // Fixed margins - NEVER change with screen size
    const double topMargin = 60.0;
    const double bottomMargin = 20.0;
    const double leftMargin = 20.0;
    const double rightMargin = 20.0;
    const double minVerticalSpacing = 20.0; // Minimum space between zones
    const double cardSpacing = 12.0; // Between rows of cards (vertical)
    const double cardSpacingHorizontal = 10.0; // Between cards in the same row
    
    // Available space after fixed margins and minimum spacing
    final availableHeight = size.height - topMargin - bottomMargin - minVerticalSpacing;
    
    // Calculate card size based on available height
    // Upper zone: 2 rows of cards + spacing between them
    // Constraint 1: Vertical space
    final maxCardHeight = (availableHeight - (cardSpacing * 3)) / 4;
    
    // Constraint 2: Horizontal space
    final availableWidth = size.width - leftMargin - rightMargin;
    final maxCardWidth = (availableWidth - (cardSpacingHorizontal * 2)) / 3;
    
    // Desired Aspect Ratio: Original (1/1.5) increased by 5%
    // Ratio = Width / Height
    // New Ratio = (1 / 1.5) * 1.05 = 0.7
    const double targetRatio = (1 / 1.5) * 1.05;
    
    // Calculate height based on width and ratio
    // H = W / R
    final heightFromWidth = maxCardWidth / targetRatio;
    
    // Use the smaller height to ensure it fits both horizontally and vertically
    final cardHeight = heightFromWidth < maxCardHeight ? heightFromWidth : maxCardHeight;
    
    // Width is derived from height and ratio to maintain aspect
    final cardWidth = cardHeight * targetRatio;
    
    // Calculate actual zone heights
    final upperZoneHeight = (cardHeight * 2) + cardSpacing;
    final lowerZoneHeight = (cardHeight * 2) + cardSpacing;

    // Calculate max chars in board for variable font size logic
    // Always use variable font size for now
    int maxCharsInBoard = 3; 
    // if (!gameProvider.variableFontSize) {
    //   maxCharsInBoard = _calculateMaxCharsInBoard(myHand, discardPiles);
    // }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: topMargin,
              bottom: bottomMargin,
            ),
            child: Column(
              children: [
                // UPPER ZONE: Discard piles (left) + Player Info (right)
                SizedBox(
                  height: upperZoneHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Discard piles (2x2 grid) - Fixed width
                      Padding(
                        padding: const EdgeInsets.only(left: leftMargin),
                        child: SizedBox(
                          width: (cardWidth * 2) + (cardSpacingHorizontal * 1.5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // First row: Piles 0 and 1
                              SizedBox(
                                height: cardHeight,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildDiscardPile(0, discardPiles, cardWidth, cardHeight, matchDetails: _pileAnimations[0], showHalo: _pileHalos[0] ?? false, maxChars: maxCharsInBoard, useVariableFont: true),
                                    SizedBox(width: cardSpacingHorizontal),
                                    _buildDiscardPile(1, discardPiles, cardWidth, cardHeight, matchDetails: _pileAnimations[1], showHalo: _pileHalos[1] ?? false, maxChars: maxCharsInBoard, useVariableFont: true),
                                  ],
                                ),
                              ),
                              
                              SizedBox(height: cardSpacing),
                              
                              // Row 2: Piles 2 and 3
                              SizedBox(
                                height: cardHeight,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildDiscardPile(2, discardPiles, cardWidth, cardHeight, matchDetails: _pileAnimations[2], showHalo: _pileHalos[2] ?? false, maxChars: maxCharsInBoard, useVariableFont: true),
                                    SizedBox(width: cardSpacingHorizontal),
                                    _buildDiscardPile(3, discardPiles, cardWidth, cardHeight, matchDetails: _pileAnimations[3], showHalo: _pileHalos[3] ?? false, maxChars: maxCharsInBoard, useVariableFont: true),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Spacing between discard piles and player info
                      const SizedBox(width: 12),
              
                      // Right: Player information - expands to fill remaining space
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: rightMargin),
                          child: SizedBox(
                            height: upperZoneHeight,
                            child: _buildPlayersInfo(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Flexible vertical spacing between zones
                const Spacer(),
                  
                // LOWER ZONE: Player hand
                SizedBox(
                  height: lowerZoneHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: leftMargin),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Row 1: First 3 cards of hand
                        SizedBox(
                          height: cardHeight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildHandCard(0, myHand, cardWidth, cardHeight, maxChars: maxCharsInBoard, useVariableFont: true),
                              SizedBox(width: cardSpacingHorizontal),
                              _buildHandCard(1, myHand, cardWidth, cardHeight, maxChars: maxCharsInBoard, useVariableFont: true),
                              SizedBox(width: cardSpacingHorizontal),
                              _buildHandCard(2, myHand, cardWidth, cardHeight, maxChars: maxCharsInBoard, useVariableFont: true),
                            ],
                          ),
                         ),
                        const SizedBox(height: cardSpacing),
                        // Row 2: Last 2 cards + deck
                        SizedBox(
                          height: cardHeight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildHandCard(3, myHand, cardWidth, cardHeight, maxChars: maxCharsInBoard, useVariableFont: true),
                              SizedBox(width: cardSpacingHorizontal),
                              _buildHandCard(4, myHand, cardWidth, cardHeight, maxChars: maxCharsInBoard, useVariableFont: true),
                              SizedBox(width: cardSpacingHorizontal),
                              _buildDeck(
                                myDeckSize,
                                24,
                                cardWidth, 
                                cardHeight
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Overlays
          if (onlineProvider.isEliminated && onlineProvider.winner == null)
            _buildEliminatedOverlay(),
            
          if (onlineProvider.winner != null)
            _buildGameOverOverlay(onlineProvider.winner!),
        ],
      ),
    );
  }

  Widget _buildEliminatedOverlay() {
    return GestureDetector(
      onTap: () {
        final onlineProvider = Provider.of<OnlineGameProvider>(context, listen: false);
        onlineProvider.disconnect();
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      },
      child: Container(
        color: Colors.black.withOpacity(0.85),
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Has sido eliminado",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Haz clic en cualquier lugar para volver al menú",
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay(Map<String, dynamic> winner) {
    final onlineProvider = Provider.of<OnlineGameProvider>(context, listen: false);
    final isMe = winner['id'] == onlineProvider.currentUser?.id;
    
    // Auto-redirect logic could be here or in initState listener, 
    // but specs say "Auto-redirección al menú después de 3 segundos si no hay interacción"
    // We can use a Future.delayed here but be careful with rebuilds.
    // Better to handle it once. Since build is called multiple times, let's just rely on user tap for now 
    // or add a state variable to track if redirect timer started.
    
    return GestureDetector(
      onTap: () {
        final onlineProvider = Provider.of<OnlineGameProvider>(context, listen: false);
        onlineProvider.disconnect();
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      },
      child: Container(
        color: Colors.black.withOpacity(0.9),
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isMe ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                size: 80,
                color: isMe ? Colors.amber : Colors.grey,
              ),
              const SizedBox(height: 24),
              Text(
                isMe ? "¡Has ganado la partida!" : "El jugador ${winner['alias']} ha ganado la partida",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isMe ? Colors.amber : Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Haz clic para continuar",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  int _calculateMaxCharsInBoard(List<Carta> hand, List<List<Carta>> piles) {
    int maxChars = 3;
    
    void checkCarta(Carta c) {
      for (var m in c.multiplicaciones) {
        int len = "${m[0]}×${m[1]}".length;
        if (len > maxChars) maxChars = len;
      }
      int divLen = "${c.division[0]}:${c.division[1]}".length;
      if (divLen > maxChars) maxChars = divLen;
    }
    
    for (var c in hand) checkCarta(c);
    for (var pile in piles) {
      if (pile.isNotEmpty) checkCarta(pile.last);
    }
    
    return maxChars;
  }

  Widget _buildDiscardPile(int index, List<List<Carta>> allPiles, double w, double h, {MatchDetails? matchDetails, bool showHalo = false, int maxChars = 5, bool useVariableFont = true}) {
    final pile = allPiles[index];
    
    if (pile.isEmpty) {
      // Empty pile - show placeholder
      return Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.withOpacity(0.3), 
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.withOpacity(0.1),
        ),
        child: Center(
          child: Icon(
            Icons.layers_outlined,
            color: Colors.grey.withOpacity(0.3),
            size: w * 0.4,
          ),
        ),
      );
    }
    
    // Calculate how many cards to show below based on pile size
    const totalCards = 52; 
    final count = pile.length;
    final percentage = count / totalCards;
    
    int cardsBelow = 0;
    if (count > 1) {
        if (percentage <= 0.08) cardsBelow = 1;       // 0.1% - 8%
        else if (percentage <= 0.16) cardsBelow = 2;  // 8% - 16%
        else cardsBelow = 3;                          // > 16%
    }
    
    // Ensure we don't try to show more cards than exist
    if (cardsBelow > count - 1) cardsBelow = count - 1;
    
    List<Widget> stackChildren = [];
    
    // 0. Halo animation (if active)
    if (showHalo) {
      stackChildren.add(
        Positioned(
          left: -w * 0.25,
          top: -h * 0.25,
          width: w * 1.5,
          height: h * 1.5,
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.0, end: 1.4),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: (1.4 - value) / 0.4, // Fade out as it grows
                  child: Container(
                    width: w * value,
                    height: h * value,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.8),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }
    
    // 1. Add cards below (rendered first so they are at the bottom)
    for (int i = cardsBelow; i >= 1; i--) {
        final cardIndex = count - 1 - i;
        final card = pile[cardIndex];
        
        final random = Random(card.hashCode);
        final angleDegrees = -3 + random.nextDouble() * 6;
        final angleRadians = angleDegrees * (pi / 180);
        
        // Small random offset for "messy pile" effect
        final offsetX = -2 + random.nextDouble() * 4;
        final offsetY = -2 + random.nextDouble() * 4;

        stackChildren.add(
            Positioned(
                left: offsetX,
                top: offsetY,
                child: Transform.rotate(
                    angle: angleRadians,
                    child: CartaWidget(
                        carta: card,
                        width: w,
                        height: h,
                    ),
                ),
            )
        );
    }
    
    // 2. Add top card (DragTarget)
    stackChildren.add(
        DragTarget(
          onWillAcceptWithDetails: (data) => true,
          onAcceptWithDetails: (data) {
            final carta = data.data as Carta;
            _handleCardDiscard(carta, index);
          },
          builder: (context, candidateData, rejectedData) {
            final topCard = pile.last;
            
            final random = Random(topCard.hashCode);
            final angleDegrees = -3 + random.nextDouble() * 6;
            final angleRadians = angleDegrees * (pi / 180);

            return Transform.rotate(
              angle: angleRadians,
              child: CartaWidget(
                carta: topCard,
                width: w,
                height: h,
                matchDetails: matchDetails, // Pass match details for animation
              ),
            );
          },
        )
    );

    return Stack(
        clipBehavior: Clip.none,
        children: stackChildren,
    );
  }

  Widget _buildPlayersInfo() {
    final onlineProvider = Provider.of<OnlineGameProvider>(context, listen: false);
    final isOnline = onlineProvider.isOnline;

    List<JugadorInfo> players = [];

    // Map online players to JugadorInfo
    players = onlineProvider.players.map((p) {
      // Calculate total remaining cards (hand + personal deck)
      final totalCards = p.handSize + p.personalDeckSize;
      
      return JugadorInfo(
        id: p.id,
        alias: p.alias,
        avatar: p.avatar,
        cartasRestantes: totalCards,
        penalizaciones: p.penalties,
      );
    }).toList();

    if (players.isEmpty) {
      return const Center(child: Text('No hay información de jugadores'));
    }
    
    // Calculate card height to determine player info box height
    final size = MediaQuery.of(context).size;
    const double topMargin = 4.0;
    const double bottomMargin = 4.0;
    const double verticalSpacing = 36.0;
    const double cardSpacing = 12.0;
    final availableHeight = size.height - topMargin - bottomMargin - verticalSpacing;
    final cardHeight = (availableHeight - (cardSpacing * 3)) / 4;
    
    // Each player info box is smaller than half the height of a card
    final playerBoxHeight = cardHeight / 2.5;
    
    // Sort players by remaining cards for display order
    final sortedPlayers = List<JugadorInfo>.from(players);
    sortedPlayers.sort((a, b) {
      final compare = a.cartasRestantes.compareTo(b.cartasRestantes);
      if (compare != 0) return compare;
      
      // Tie-breaker: Maintain previous relative order if possible
      if (_lastSortedIds.contains(a.id) && _lastSortedIds.contains(b.id)) {
        return _lastSortedIds.indexOf(a.id).compareTo(_lastSortedIds.indexOf(b.id));
      }
      
      return a.alias.compareTo(b.alias); // Fallback Tie-breaker
    });
    
    // Update last sorted ids for next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _lastSortedIds = sortedPlayers.map((p) => p.id).toList();
      }
    });

    // Calculate total height needed for the stack
    final itemHeight = playerBoxHeight + 8.0; // Height + vertical margin (4*2)
    final totalStackHeight = itemHeight * players.length;

    return SizedBox(
      height: totalStackHeight,
      child: Stack(
        children: players.map((jugador) {
          final avatarState = _calculateAvatarState(jugador, players);
          
          // Find the target index in the sorted list
          final targetIndex = sortedPlayers.indexWhere((p) => p.id == jugador.id);
          final topPosition = targetIndex * itemHeight;

          return AnimatedPositioned(
            key: ValueKey(jugador.id),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOutCubic,
            top: topPosition,
            left: 0,
            right: 0,
            height: itemHeight,
            child: _buildPlayerInfoItem(jugador, playerBoxHeight, avatarState),
          );
        }).toList(),
      ),
    );
  }

  int _calculateAvatarState(JugadorInfo jugador, List<JugadorInfo> allPlayers) {
    if (allPlayers.length <= 1) return 2; // Solo o esperando

    int myCards = jugador.cartasRestantes;
    
    // Check if winning (strictly less cards than everyone else)
    bool isWinning = allPlayers.every((p) => p.id == jugador.id || p.cartasRestantes > myCards);
    if (isWinning) return 1;

    // Check if losing (strictly more cards than everyone else)
    bool isLosing = allPlayers.every((p) => p.id == jugador.id || p.cartasRestantes < myCards);
    if (isLosing) return 3;

    return 2;
  }

  Widget _buildPlayerInfoItem(JugadorInfo jugador, double availableHeight, int avatarState) {
    final onlineProvider = Provider.of<OnlineGameProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCurrentUser = jugador.id == onlineProvider.currentUser?.id;
    
    // Scale elements
    // Reduced avatar size further to fit in box (0.315 -> 0.28)
    print('GameScreen: Rendering player ${jugador.alias} with avatar: ${jugador.avatar}');
    final avatarRadius = (availableHeight * 0.28).clamp(10.0, 20.0);
    final fontSizeStats = (availableHeight * 0.18).clamp(10.0, 14.0);
    final iconSize = (availableHeight * 0.18).clamp(12.0, 16.0);
    
    return Container(
      height: availableHeight,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? (isDark ? AppTheme.primary.withOpacity(0.3) : AppTheme.primary.withOpacity(0.1))
            : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser ? AppTheme.primary : (isDark ? Colors.white24 : Colors.black12),
          width: isCurrentUser ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2C) : Colors.white, // Solid background
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: isCurrentUser ? AppTheme.primary : Colors.transparent, 
                  width: 2
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1), 
                    blurRadius: 4, 
                    offset: const Offset(0, 2)
                )
              ]
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6), // 8 - 2
              child: Image.asset(
                AvatarHelper.getAvatarPath(jugador.avatar ?? 'default', avatarState),
                width: avatarRadius * 2,
                height: avatarRadius * 2,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: avatarRadius * 2,
                  height: avatarRadius * 2,
                  color: Colors.grey[200],
                  child: Icon(Icons.person, size: avatarRadius, color: Colors.grey),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 4), // Reduced spacing between avatar and stats
          
          // Stats Column
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Cards Row
              Row(
                children: [
                  // Icon removed as requested
                  Text(
                    '${jugador.cartasRestantes}',
                    style: TextStyle(
                        fontSize: fontSizeStats, 
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey[300] : Colors.black87
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 2),
              
              // Penalties Row
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: iconSize, color: jugador.penalizaciones > 0 ? AppTheme.error : Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    '${jugador.penalizaciones}',
                    style: TextStyle(
                        fontSize: fontSizeStats, 
                        color: jugador.penalizaciones > 0 ? AppTheme.error : Colors.grey[600], 
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHandCard(int index, List<Carta> hand, double w, double h, {int maxChars = 5, bool useVariableFont = true}) {
    if (index >= hand.length) {
      // Empty slot - invisible
      return SizedBox(
        width: w,
        height: h,
      );
    }
    
    final carta = hand[index];
    
    // Deterministic random rotation based on card hash so it doesn't jitter on rebuilds
    final random = Random(carta.hashCode);
    final angleDegrees = -3 + random.nextDouble() * 6; // -3 to 3 degrees
    final angleRadians = angleDegrees * (pi / 180);
    
    return Draggable(
      data: carta,
      feedback: Transform.rotate(
        angle: angleRadians,
        child: Material(
          color: Colors.transparent,
          child: CartaWidget(
            carta: carta,
            width: w * 1.1,
            height: h * 1.1,
            maxCharsInBoard: maxChars,
            useVariableFont: useVariableFont,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: Transform.rotate(
          angle: angleRadians,
          child: CartaWidget(
            carta: carta,
            width: w,
            height: h,
            maxCharsInBoard: maxChars,
            useVariableFont: useVariableFont,
          ),
        ),
      ),
      child: CartaWidget(
          carta: carta,
          width: w,
          height: h,
          onTap: () {
            // Optional: Select logic
          },
          maxCharsInBoard: maxChars,
          useVariableFont: useVariableFont,
        ),
    );
  }

  Widget _buildDeck(int count, int initialSize, double w, double h) {
    if (count == 0) {
      return SizedBox(width: w, height: h);
    }
    
    // Use stored initial size, fallback to count if 0 (e.g. hot reload without re-init)
    final initial = initialSize > 0 ? initialSize : count; 
    final percentage = count / initial;
    
    int cardsBelow = 0;
    if (count > 1) {
        if (percentage <= 0.08) cardsBelow = 1;
        else if (percentage <= 0.16) cardsBelow = 2;
        else cardsBelow = 3;
    }
    
    // Ensure we don't try to show more cards than exist
    if (cardsBelow > count - 1) cardsBelow = count - 1;
    
    List<Widget> stackChildren = [];
    
    // Helper for card back
    Widget buildCardBack() => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9), // Slightly less than container to fit inside border
        child: Image.asset(
          'assets/reverso_carta.png',
          fit: BoxFit.fill,
        ),
      ),
    );

    // 1. Add cards below
    for (int i = cardsBelow; i >= 1; i--) {
        // Deterministic random based on index + count to keep it stable but varied
        final random = Random(i * 999 + count); 
        final angleDegrees = -3 + random.nextDouble() * 6;
        final angleRadians = angleDegrees * (pi / 180);
        
        final offsetX = -2 + random.nextDouble() * 4;
        final offsetY = -2 + random.nextDouble() * 4;

        stackChildren.add(
            Positioned(
                left: offsetX,
                top: offsetY,
                child: buildCardBack(),
            )
        );
    }
    
    // 2. Top card + Badge
    final randomTop = Random(count);
    final angleDegreesTop = -3 + randomTop.nextDouble() * 6;
    final angleRadiansTop = angleDegreesTop * (pi / 180);

    stackChildren.add(
        GestureDetector(
          onTap: () {
            // TODO: Implementar robar carta
            print('Robar carta');
          },
            child: Stack(
                clipBehavior: Clip.none,
                children: [
                    buildCardBack(),
                    
                    // Count Badge
                    Positioned(
                        top: -w * 0.08,
                        right: -w * 0.08,
                        child: Container(
                          padding: EdgeInsets.all(w * 0.06),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: w * 0.025),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: w * 0.02,
                                offset: Offset(w * 0.01, w * 0.01),
                              ),
                            ],
                          ),
                          constraints: BoxConstraints(
                            minWidth: w * 0.25,
                            minHeight: w * 0.25,
                          ),
                          child: Center(
                            child: Text(
                              '$count',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: w * 0.15,
                              ),
                            ),
                          ),
                        ),
                    ),
                ]
            ),
        )
    );
    
    return Stack(
        clipBehavior: Clip.none,
        children: stackChildren
    );
  }
}
