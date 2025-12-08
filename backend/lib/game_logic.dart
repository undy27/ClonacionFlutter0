import 'dart:math';
import 'models/card.dart';

class GameLogic {
  static List<Card> generateDeck() {
    List<Card> deck = [];
    Random random = Random();

    // 1. Generate Superior Rows (Multiplications)
    List<List<int>> basePairs = [];
    
    // All combinations (110 pairs with restrictions)
    for (int i = 0; i <= 10; i++) {
      for (int j = 0; j <= 10; j++) {
        if (i == 10 && j == 10) continue;
        if (i == 0 && j % 2 != 0) continue;
        if (j == 0 && i % 2 != 0) continue;
        basePairs.add([i, j]);
      }
    }

    // Generate Extra Pairs (46 total) according to specs:
    // a) 42 pairs with unique products
    List<List<int>> extraPairs = [];
    int attempts = 0;
    
    print('[GameLogic] Generating 42 extra pairs with unique products');
    while (extraPairs.length < 42 && attempts < 10000) {
      attempts++;
      int i = random.nextInt(11);
      int j = random.nextInt(11);
      
      if (i == 10 && j == 10) continue;
      if (i == 0 && j % 2 != 0) continue;
      if (j == 0 && i % 2 != 0) continue;
      
      int prod = i * j;
      bool productExists = extraPairs.any((p) => (p[0] * p[1]) == prod);
      if (!productExists) {
        extraPairs.add([i, j]);
      }
    }
    
    // b) 4 additional random pairs
    print('[GameLogic] Generating 4 additional random pairs');
    while (extraPairs.length < 46) {
      int i = random.nextInt(11);
      int j = random.nextInt(11);
      if (i == 10 && j == 10) continue;
      if (i == 0 && j % 2 != 0) continue;
      if (j == 0 && i % 2 != 0) continue;
      extraPairs.add([i, j]);
    }

    List<List<int>> allSuperiorPairs = [...basePairs, ...extraPairs];
    allSuperiorPairs.shuffle();

    // 2. Generate Middle Rows (Divisions)
    List<List<int>> middlePairs = [];
    for (int i = 1; i <= 81; i++) {
      for (int j = 1; j <= 9; j++) {
        if (i % j == 0) {
          int res = i ~/ j;
          if (res >= 1 && res <= 9) {
            middlePairs.add([i, j]);
          }
        }
      }
    }
    middlePairs.shuffle();
    List<List<int>> selectedMiddlePairs = middlePairs.take(52).toList();

    // 3. Generate Inferior Rows (Results)
    Set<int> uniqueResults = {};
    for (int i = 0; i <= 10; i++) {
      for (int j = 0; j <= 10; j++) {
        if (i == 10 && j == 10) continue;
        uniqueResults.add(i * j);
      }
    }
    
    List<int> resultsList = uniqueResults.toList();
    List<int> concatenatedList = [];
    for (int k = 0; k < 4; k++) {
      concatenatedList.addAll(resultsList);
    }
    
    // Remove 12 unique values (one instance of each)
    List<int> toRemoveCandidates = List.from(resultsList);
    toRemoveCandidates.shuffle();
    List<int> valuesToRemove = toRemoveCandidates.take(12).toList();
    
    List<int> finalResults = [];
    for (int val in concatenatedList) {
      if (valuesToRemove.contains(val)) {
        valuesToRemove.remove(val);
      } else {
        finalResults.add(val);
      }
    }
    
    while (finalResults.length > 156) {
      finalResults.removeLast();
    }
    // Ensure no card has duplicate results in its inferior row
    bool validDistribution = false;
    int shuffleAttempts = 0;
    
    while (!validDistribution && shuffleAttempts < 100) {
      finalResults.shuffle(random);
      validDistribution = true;
      for (int i = 0; i < 52; i++) {
        int a = finalResults[i * 3];
        int b = finalResults[i * 3 + 1];
        int c = finalResults[i * 3 + 2];
        if (a == b || a == c || b == c) {
          validDistribution = false;
          break;
        }
      }
      shuffleAttempts++;
    }

    if (!validDistribution) {
       print('[GameLogic] WARNING: Forced swap to fix duplicates after $shuffleAttempts shuffles.');
       // Emergency fix: Linear scan swap
       for (int i = 0; i < 52; i++) {
          int i1 = i * 3;
          int i2 = i * 3 + 1;
          int i3 = i * 3 + 2;
          
          if (finalResults[i1] == finalResults[i2] || 
              finalResults[i1] == finalResults[i3] || 
              finalResults[i2] == finalResults[i3]) {
              
               int swapTarget = random.nextInt(finalResults.length);
               int temp = finalResults[i3];
               finalResults[i3] = finalResults[swapTarget];
               finalResults[swapTarget] = temp;
          }
       }
    }

    // Assemble Cards
    for (int i = 0; i < 52; i++) {
      List<List<int>> row1 = [
        allSuperiorPairs[i * 3],
        allSuperiorPairs[i * 3 + 1],
        allSuperiorPairs[i * 3 + 2],
      ];
      
      List<int> row2 = selectedMiddlePairs[i];
      
      List<int> row3 = [
        finalResults[i * 3],
        finalResults[i * 3 + 1],
        finalResults[i * 3 + 2],
      ];

      deck.add(Card(
        multiplicaciones: row1,
        division: row2,
        resultados: row3,
      ));
    }

    print('[GameLogic] Deck generated successfully: ${deck.length} cards');
    return deck;
  }

  // Valida si una carta puede ser descartada en un montón
  static bool canPlayCard(Card card, Card topCard) {
    // Lógica de validación según las reglas del juego
    // Por ahora simplificamos: cualquier carta puede ir en cualquier sitio
    // TODO: Implementar reglas de coincidencia
    return true;
  }
}
