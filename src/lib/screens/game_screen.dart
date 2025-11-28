import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/carta_widget.dart';
import '../theme/app_theme.dart';
import 'package:animate_do/animate_do.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameProvider>(context, listen: false).startGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width / 5.5; // Adjusted for margins
    final cardHeight = cardWidth * 1.5;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Row 1: Player Info & Abandon
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Row(
                     children: [
                       const CircleAvatar(backgroundColor: AppTheme.primary, child: Text("P1")),
                       const SizedBox(width: 8),
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           const Text("Jugador 1", style: TextStyle(fontWeight: FontWeight.bold)),
                           Text("Descartadas: ${gameProvider.cartasDescartadas.length ?? 0}"), // Fix later
                         ],
                       )
                     ],
                   ),
                   ElevatedButton(
                     onPressed: () => Navigator.pop(context),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: AppTheme.error,
                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                     ),
                     child: const Text("ABANDONAR"),
                   )
                ],
              ),
            ),
            
            // Row 2: Discard Piles 1 & 2
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDiscardPile(0, gameProvider, cardWidth, cardHeight),
                  _buildDiscardPile(1, gameProvider, cardWidth, cardHeight),
                ],
              ),
            ),

             // Row 3: Discard Piles 3 & 4
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDiscardPile(2, gameProvider, cardWidth, cardHeight),
                  _buildDiscardPile(3, gameProvider, cardWidth, cardHeight),
                ],
              ),
            ),

            // Row 4 & 5: Player Hand & Deck
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  children: [
                    // First 3 cards
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(3, (index) {
                          if (index < gameProvider.mano.length) {
                             return Draggable(
                               data: gameProvider.mano[index],
                               feedback: Material(
                                 color: Colors.transparent,
                                 child: CartaWidget(
                                   carta: gameProvider.mano[index],
                                   width: cardWidth * 1.1,
                                   height: cardHeight * 1.1,
                                 ),
                               ),
                               childWhenDragging: Container(
                                   width: cardWidth,
                                   height: cardHeight,
                                   decoration: BoxDecoration(
                                     border: Border.all(color: Colors.grey.withOpacity(0.5), width: 2),
                                     borderRadius: BorderRadius.circular(10)
                                   ),
                               ),
                               child: FadeInUp(
                                 duration: const Duration(milliseconds: 300),
                                 child: CartaWidget(
                                   carta: gameProvider.mano[index],
                                   width: cardWidth,
                                   height: cardHeight,
                                 ),
                               ),
                             );
                          } else {
                             return SizedBox(width: cardWidth, height: cardHeight);
                          }
                      }),
                    ),
                    const SizedBox(height: 10),
                    // Last 2 cards + Deck
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ...List.generate(2, (index) {
                           int realIndex = index + 3;
                           if (realIndex < gameProvider.mano.length) {
                             return Draggable(
                               data: gameProvider.mano[realIndex],
                               feedback: Material(
                                 color: Colors.transparent,
                                 child: CartaWidget(
                                   carta: gameProvider.mano[realIndex],
                                   width: cardWidth * 1.1,
                                   height: cardHeight * 1.1,
                                 ),
                               ),
                               childWhenDragging: Container(
                                   width: cardWidth,
                                   height: cardHeight,
                                   decoration: BoxDecoration(
                                     border: Border.all(color: Colors.grey.withOpacity(0.5), width: 2),
                                     borderRadius: BorderRadius.circular(10)
                                   ),
                               ),
                               child: FadeInUp(
                                 duration: const Duration(milliseconds: 300),
                                 child: CartaWidget(
                                   carta: gameProvider.mano[realIndex],
                                   width: cardWidth,
                                   height: cardHeight,
                                 ),
                               ),
                             );
                           } else {
                              return SizedBox(width: cardWidth, height: cardHeight);
                           }
                        }),
                        // Deck
                        GestureDetector(
                           onTap: () {
                             // Logic to draw card to empty slot?
                             // Specs say: "pulsando sobre ella... y la arrastra hacia el hueco"
                             // Implementation of drag from deck to hand needed
                           },
                           child: Stack(
                             children: [
                               if (gameProvider.mazoRestante.isNotEmpty)
                                 ...List.generate(min(3, gameProvider.mazoRestante.length), (i) => 
                                   Positioned(
                                      left: i * 2.0,
                                      top: i * 2.0,
                                      child: Container(
                                        width: cardWidth,
                                        height: cardHeight,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Colors.black, width: 2),
                                        ),
                                      ),
                                   )
                                 ),
                                 Container(
                                    width: cardWidth,
                                    height: cardHeight,
                                    margin: const EdgeInsets.only(left: 6, top: 6), // Offset for stack effect
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.black, width: 2),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${gameProvider.mazoRestante.length}",
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                                      ),
                                    ),
                                 )
                             ],
                           ),
                        ),
                      ],
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
  
  int min(int a, int b) => a < b ? a : b;

  Widget _buildDiscardPile(int index, GameProvider provider, double w, double h) {
      if (provider.montonesDescarte[index].isEmpty) {
          return SizedBox(width: w, height: h);
      }
      return DragTarget(
        onWillAcceptWithDetails: (data) => true,
        onAcceptWithDetails: (data) {
           bool success = provider.intentarDescarte(data as dynamic, index);
           if (!success) {
               // Trigger shake animation and sound
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Descarte inválido!")));
           }
        },
        builder: (context, candidateData, rejectedData) {
           return CartaWidget(
               carta: provider.montonesDescarte[index].last,
               width: w,
               height: h,
           );
        },
      );
  }
}
