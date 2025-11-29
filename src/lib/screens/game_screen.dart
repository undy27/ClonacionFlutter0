import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
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
  @override
  void initState() {
    super.initState();
    // Game is started from WaitingRoomScreen, data should be ready
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
                      width: (cardWidth * 2) + 20, // 2 cards + spacing between them
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // First row: Piles 0 and 1
                          SizedBox(
                            height: cardHeight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildDiscardPile(0, gameProvider, cardWidth, cardHeight),
                                _buildDiscardPile(1, gameProvider, cardWidth, cardHeight),
                              ],
                            ),
                          ),
                          const SizedBox(height: cardSpacing),
                          // Second row: Piles 2 and 3
                          SizedBox(
                            height: cardHeight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildDiscardPile(2, gameProvider, cardWidth, cardHeight),
                                _buildDiscardPile(3, gameProvider, cardWidth, cardHeight),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Spacing between discard piles and player info - EXACTLY 20px
                  const SizedBox(width: 20),
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
                          _buildHandCard(0, gameProvider, cardWidth, cardHeight),
                          SizedBox(width: cardSpacingHorizontal),
                          _buildHandCard(1, gameProvider, cardWidth, cardHeight),
                          SizedBox(width: cardSpacingHorizontal),
                          _buildHandCard(2, gameProvider, cardWidth, cardHeight),
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
                          _buildHandCard(3, gameProvider, cardWidth, cardHeight),
                          SizedBox(width: cardSpacingHorizontal),
                          _buildHandCard(4, gameProvider, cardWidth, cardHeight),
                          SizedBox(width: cardSpacingHorizontal),
                          _buildDeck(gameProvider, cardWidth, cardHeight),
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

  Widget _buildDiscardPile(int index, GameProvider provider, double w, double h) {
    final pile = provider.montonesDescarte[index];
    
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
            bool success = provider.intentarDescarte(carta, index);
            if (!success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("¡Descarte inválido!"),
                  backgroundColor: AppTheme.error,
                  duration: Duration(milliseconds: 600),
                ),
              );
            }
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
                matchDetails: provider.getLastMatchDetails(index),
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
    // Get all players from current partida
    final partida = provider.currentPartida;
    if (partida == null || partida.jugadores.isEmpty) {
      return const Center(child: Text('No hay información de jugadores'));
    }
    
    // TODO: Sort players by remaining cards (ascending)
    // For now, just display them
    final players = partida.jugadores;
    
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
    
    // Scale all elements based on available height
    // Reduced factors to fit in smaller box and avoid overflow
    final avatarRadius = (availableHeight * 0.20).clamp(8.0, 16.0); // Reduced further
    final fontSize = (availableHeight * 0.14 * 0.9).clamp(8.0, 11.0);
    final iconSize = (availableHeight * 0.11).clamp(8.0, 12.0);
    final padding = (availableHeight * 0.08).clamp(2.0, 5.0); // Reduced padding base
    
    return Container(
      height: availableHeight,
      margin: EdgeInsets.symmetric(vertical: padding * 0.5, horizontal: padding * 0.5),
      padding: EdgeInsets.symmetric(horizontal: padding * 0.5, vertical: padding),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? (isDark ? AppTheme.primary.withOpacity(0.3) : AppTheme.primary.withOpacity(0.1))
            : (isDark ? AppTheme.darkSurface : Colors.white),
        borderRadius: BorderRadius.circular(padding * 1.5),
        border: Border.all(
          color: isCurrentUser 
              ? (isDark ? AppTheme.primary : AppTheme.primary)
              : (isDark ? AppTheme.darkBorder : AppTheme.border),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: isDark ? AppTheme.primary : AppTheme.primary,
            child: Text(
              jugador.alias.isNotEmpty ? jugador.alias[0].toUpperCase() : '?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: avatarRadius * 0.8,
              ),
            ),
          ),
          SizedBox(width: padding * 0.5), // Minimal spacing
          // Name and info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  jugador.alias,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: padding * 0.2),
                Row(
                  children: [
                    Icon(Icons.style, size: iconSize, color: Colors.grey[600]),
                    SizedBox(width: padding * 0.5),
                    Flexible(
                      child: Text(
                        '${provider.mano.length}', 
                        style: TextStyle(
                          fontSize: fontSize * 0.85,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: padding * 0.2), // Minimal spacing
          // Penalties indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: padding * 0.5, vertical: padding * 0.2),
            decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(padding),
              border: Border.all(color: AppTheme.error, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded, size: iconSize, color: AppTheme.error),
                SizedBox(width: padding * 0.2),
                Text(
                  '0', 
                  style: TextStyle(
                    color: AppTheme.error,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize * 0.9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandCard(int index, GameProvider provider, double w, double h) {
    if (index >= provider.mano.length) {
      // Empty slot - invisible
      return SizedBox(
        width: w,
        height: h,
      );
    }
    
    final carta = provider.mano[index];
    
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

  Widget _buildDeck(GameProvider provider, double w, double h) {
    if (provider.mazoRestante.isEmpty) {
      return SizedBox(width: w, height: h);
    }
    
    final count = provider.mazoRestante.length;
    // Use stored initial size, fallback to count if 0 (e.g. hot reload without re-init)
    final initial = provider.initialDeckSize > 0 ? provider.initialDeckSize : count; 
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
