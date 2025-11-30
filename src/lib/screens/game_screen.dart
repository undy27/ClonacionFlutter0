import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/online_game_provider.dart';
import '../models/carta.dart';
import '../models/partida.dart';
import '../services/websocket_service.dart'; // Para PlayerInfo
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
  StreamSubscription? _cardPlayedSubscription;

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
          final matchDetailsMap = data['matchDetails'] as Map<String, dynamic>;
          final matchDetails = MatchDetails.fromJson(matchDetailsMap);
          
          debugPrint('[GameScreen] Animation event received for pile $pileIndex. Has match: ${matchDetails.hasMatch}');
          
          setState(() {
            _pileAnimations[pileIndex] = matchDetails;
          });
          
          // Clear animation after duration (optional, but good for cleanup)
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (mounted) {
              setState(() {
                _pileAnimations.remove(pileIndex);
              });
            }
          });
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
    final isOnlineMode = onlineProvider.currentRoomId != null;
    
    if (isOnlineMode) {
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
    } else {
      // En modo offline, usar lógica local
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      bool success = gameProvider.intentarDescarte(carta, pileIndex);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Descarte inválido!"),
            backgroundColor: AppTheme.error,
            duration: Duration(milliseconds: 600),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final onlineProvider = Provider.of<OnlineGameProvider>(context);
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Detectar modo online según si hay roomId activo
    final isOnlineMode = onlineProvider.currentRoomId != null;
    
    // Obtener datos del provider correcto
    final List<Carta> myHand = isOnlineMode ? onlineProvider.myHand : gameProvider.mano;
    final List<List<Carta>> discardPiles = isOnlineMode ? onlineProvider.discardPiles : gameProvider.montonesDescarte;
    
    int myDeckSize = 0;
    if (isOnlineMode) {
      final myPlayer = onlineProvider.players.firstWhere(
        (p) => p.id == gameProvider.currentUser?.id, 
        orElse: () => PlayerInfo(id: '', alias: '', handSize: 0, personalDeckSize: 0, penalties: 0)
      );
      myDeckSize = myPlayer.personalDeckSize;
      debugPrint('[GameScreen] MyPlayer: ${myPlayer.alias}, DeckSize: $myDeckSize, Players: ${onlineProvider.players.length}');
    }

    debugPrint('[GameScreen] Mode: ${isOnlineMode ? "ONLINE" : "OFFLINE"}, Hand: ${myHand.length}, Piles: ${discardPiles.map((p) => p.length).toList()}');
    
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
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
                                _buildDiscardPile(0, discardPiles, cardWidth, cardHeight, matchDetails: _pileAnimations[0]),
                                SizedBox(width: cardSpacingHorizontal),
                                _buildDiscardPile(1, discardPiles, cardWidth, cardHeight, matchDetails: _pileAnimations[1]),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: cardSpacing),
                          
                          // Row 2: Piles 3 & 4
                          SizedBox(
                            height: cardHeight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildDiscardPile(2, discardPiles, cardWidth, cardHeight, matchDetails: _pileAnimations[2]),
                                SizedBox(width: cardSpacingHorizontal),
                                _buildDiscardPile(3, discardPiles, cardWidth, cardHeight, matchDetails: _pileAnimations[3]),
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
                        child: _buildPlayersInfo(gameProvider),
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
                          _buildHandCard(0, myHand, cardWidth, cardHeight),
                          SizedBox(width: cardSpacingHorizontal),
                          _buildHandCard(1, myHand, cardWidth, cardHeight),
                          SizedBox(width: cardSpacingHorizontal),
                          _buildHandCard(2, myHand, cardWidth, cardHeight),
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
                          _buildHandCard(3, myHand, cardWidth, cardHeight),
                          SizedBox(width: cardSpacingHorizontal),
                          _buildHandCard(4, myHand, cardWidth, cardHeight),
                          SizedBox(width: cardSpacingHorizontal),
                          _buildDeck(
                            isOnlineMode ? myDeckSize : gameProvider.mazoRestante.length,
                            isOnlineMode ? 24 : gameProvider.initialDeckSize,
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
    );
  }

  Widget _buildDiscardPile(int index, List<List<Carta>> allPiles, double w, double h, {MatchDetails? matchDetails}) {
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

  Widget _buildPlayersInfo(GameProvider provider) {
    final onlineProvider = Provider.of<OnlineGameProvider>(context, listen: false);
    final isOnline = onlineProvider.isOnline;

    List<JugadorInfo> players = [];

    if (isOnline) {
      // Map online players to JugadorInfo
      players = onlineProvider.players.map((p) {
        // Calculate total remaining cards (hand + personal deck)
        final totalCards = p.handSize + p.personalDeckSize;
        
        return JugadorInfo(
          id: p.id,
          alias: p.alias,
          avatar: null, // Online players might not have avatars yet
          cartasRestantes: totalCards,
          penalizaciones: p.penalties,
        );
      }).toList();
    } else {
      // Offline mode
      final partida = provider.currentPartida;
      if (partida != null) {
        players = partida.jugadores;
      }
    }

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
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: players.map((jugador) => _buildPlayerInfoItem(jugador, provider, playerBoxHeight)).toList(),
    );
  }

  Widget _buildPlayerInfoItem(JugadorInfo jugador, GameProvider provider, double availableHeight) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCurrentUser = jugador.id == provider.currentUser?.id;
    
    // Scale elements
    // Reduced avatar size further to fit in box (0.315 -> 0.28)
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
              shape: BoxShape.circle,
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
            child: CircleAvatar(
              radius: avatarRadius,
              backgroundColor: Colors.grey[200],
              backgroundImage: AssetImage('assets/avatars/${jugador.avatar ?? 'default'}.png'),
              onBackgroundImageError: (_, __) {},
              child: (jugador.avatar == null || jugador.avatar == 'default') ? Icon(Icons.person, size: avatarRadius, color: Colors.grey) : null,
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

  Widget _buildHandCard(int index, List<Carta> hand, double w, double h) {
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
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.8,
          child: CartaWidget(
            carta: carta,
            width: w * 1.1,
            height: h * 1.1,
          ),
        ),
      ),
      childWhenDragging: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primary.withOpacity(0.5), width: 3),
          borderRadius: BorderRadius.circular(10),
          color: AppTheme.primary.withOpacity(0.1),
        ),
        child: const Center(
          child: Icon(Icons.touch_app, color: AppTheme.primary, size: 32),
        ),
      ),
      child: FadeInUp(
        duration: Duration(milliseconds: 300 + (index * 100)),
        child: Transform.rotate(
          angle: angleRadians,
          child: CartaWidget(
            carta: carta,
            width: w,
            height: h,
          ),
        ),
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
                child: Transform.rotate(
                    angle: angleRadians,
                    child: buildCardBack(),
                ),
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
          child: Transform.rotate(
            angle: angleRadiansTop,
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
          ),
        )
    );
    
    return Stack(
        clipBehavior: Clip.none,
        children: stackChildren
    );
  }
}
