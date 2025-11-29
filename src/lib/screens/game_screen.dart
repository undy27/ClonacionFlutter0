import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/carta_widget.dart';
import '../theme/app_theme.dart';
import 'package:animate_do/animate_do.dart';
import '../models/partida.dart';
import '../models/carta.dart';

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
    const double verticalSpacing = 36.0; // Between upper and lower zones
    const double cardSpacing = 12.0; // Between rows of cards (vertical)
    const double cardSpacingHorizontal = 10.0; // Between cards in the same row
    
    // Available space after fixed margins
    final availableHeight = size.height - topMargin - bottomMargin - verticalSpacing;
    
    // Calculate card size based on available height
    // Upper zone: 2 rows of cards + spacing between them
    // Lower zone: 2 rows of cards + spacing between them
    // Total: 4 card heights + 3 spacings
    final cardHeight = (availableHeight - (cardSpacing * 3)) / 4;
    
    // Calculate width based on aspect ratio
    double calculatedCardWidth = cardHeight / 1.5;
    
    // Ensure width fits in screen with fixed spacing
    final availableWidth = size.width - leftMargin - rightMargin;
    // We need to fit 3 cards with 2 spaces of cardSpacingHorizontal
    final maxCardWidth = (availableWidth - (cardSpacingHorizontal * 2)) / 3;
    
    if (calculatedCardWidth > maxCardWidth) {
      calculatedCardWidth = maxCardWidth;
    }
    
    final cardWidth = calculatedCardWidth;
    
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
            
            // Vertical spacing between zones
            const SizedBox(height: verticalSpacing),
              
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
    if (provider.montonesDescarte.length <= index || provider.montonesDescarte[index].isEmpty) {
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
    
    return DragTarget(
      onWillAcceptWithDetails: (data) => true,
      onAcceptWithDetails: (data) {
        final carta = data.data as Carta;
        bool success = provider.intentarDescarte(carta, index);
        if (!success) {
          // TODO: Trigger shake animation and penalty countdown
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
        final topCard = provider.montonesDescarte[index].last;
        return CartaWidget(
          carta: topCard,
          width: w,
          height: h,
        );
      },
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
      // Empty slot
      return Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3), width: 2),
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.withOpacity(0.05),
        ),
        child: Center(
          child: Icon(
            Icons.add_card_outlined,
            color: Colors.grey.withOpacity(0.3),
            size: w * 0.3,
          ),
        ),
      );
    }
    
    final carta = provider.mano[index];
    
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
        child: CartaWidget(
          carta: carta,
          width: w,
          height: h,
        ),
      ),
    );
  }

  Widget _buildDeck(GameProvider provider, double w, double h) {
    if (provider.mazoRestante.isEmpty) {
      return SizedBox(width: w, height: h);
    }
    
    return GestureDetector(
      onTap: () {
        // TODO: Implement draw card logic
        print('Deck tapped - implement draw card');
      },
      child: Stack(
        children: [
          // Stack effect - multiple cards behind (shifted slightly right/bottom)
          ...List.generate(3, (i) {
            return Positioned(
              left: (i + 1) * 2.0,
              top: (i + 1) * 2.0,
              child: Container(
                width: w,
                height: h,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 2),
                ),
              ),
            );
          }),
          // Top card with counter - ALIGNED AT 0,0
          Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 3),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.layers,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${provider.mazoRestante.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18, // Reduced from 20
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
