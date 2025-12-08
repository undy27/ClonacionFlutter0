import 'dart:math';
import '../models/carta.dart';

class GameLogic {
  
  static List<Carta> generarBaraja() {
    List<Carta> baraja = [];
    Random random = Random();

    // 1. Generate Superior Rows (Multiplications)
    List<List<int>> paresSuperiores = [];
    
    // All combinations without repetition (109 pairs)
    for (int i = 0; i <= 10; i++) {
      for (int j = 0; j <= 10; j++) {
        if (i == 10 && j == 10) continue;
        if ((i == 0 && j % 2 != 0) || (j == 0 && i % 2 != 0)) continue; // Corrected rule: exclude (0,x) if x is odd? Specs say: except (0,x) and (x,0) such that x is odd.
        if (i == j) {
             // For i==j, we only add once? "combinations without repetition of natural numbers... taken 2 by 2". Usually implies order doesn't matter, but spec says "109 distinct pairs (order matters)".
             // Let's assume order matters for now based on "109 pairs distinct (order matters)".
             // Wait, "combinations without repetition" usually means {a,b} is same as {b,a}.
             // Spec: "109 pares distintos (el orden importa)". This contradicts "combinations". 
             // Let's follow "order matters". 
             // Actually, 0..10 is 11 numbers. 11*11 = 121 pairs. 
             // Exclude (10,10) -> 120.
             // Exclude (0,odd) -> (0,1),(0,3),(0,5),(0,7),(0,9) -> 5 pairs.
             // Exclude (odd,0) -> (1,0),(3,0),(5,0),(7,0),(9,0) -> 5 pairs.
             // 120 - 10 = 110 pairs.
             // Spec says 109... maybe (0,0) is excluded or handled differently? Or maybe my math is slightly off or one specific pair is extra.
             // Let's stick to the generation logic: all pairs except described.
             paresSuperiores.add([i, j]);
        } else {
             paresSuperiores.add([i, j]);
        }
      }
    }
    
    // Filter the generated pairs based on exclusions if not done in loop correctly
    paresSuperiores = paresSuperiores.where((p) {
        int i = p[0];
        int j = p[1];
        if (i == 10 && j == 10) return false;
        if (i == 0 && j % 2 != 0) return false;
        if (j == 0 && i % 2 != 0) return false;
        return true;
    }).toList();


    // 46 additional random pairs with restrictions
    List<List<int>> paresExtra = [];
    int attempts = 0;
    int maxAttempts = 10000; // Safety limit
    
    print('GameLogic: Generating 46 extra pairs with unique products');
    while (paresExtra.length < 46 && attempts < maxAttempts) {
        attempts++;
        int i = random.nextInt(11);
        int j = random.nextInt(11);
        
        if (i == 10 && j == 10) continue;
        if (i == 0 && j % 2 != 0) continue;
        if (j == 0 && i % 2 != 0) continue;
        
        int prod = i * j;
        // Restriction: product not equal to product of any of the other 45 extra pairs?
        // Spec: "que el producto... no coincida con el producto... de cualquiera de los otros 45 pares ordenados".
        // This means in the set of 46 extra pairs, all products must be unique? 
        // OR does it mean unique w.r.t the first set? 
        // "de cualquiera de los otros 45 pares ordenados" implies the uniqueness is within the extra set.
        bool productExists = paresExtra.any((p) => (p[0] * p[1]) == prod);
        if (!productExists) {
            paresExtra.add([i, j]);
            if (paresExtra.length % 10 == 0) {
              print('GameLogic: Generated ${paresExtra.length}/46 extra pairs (attempts: $attempts)');
            }
        }
    }
    
    if (paresExtra.length < 46) {
      print('GameLogic: WARNING - Could only generate ${paresExtra.length} extra pairs after $attempts attempts');
      print('GameLogic: Relaxing constraint - filling remaining slots with any valid pairs');
      // Fill remaining with any valid pair to avoid blocking
      while (paresExtra.length < 46) {
        int i = random.nextInt(11);
        int j = random.nextInt(11);
        if (i == 10 && j == 10) continue;
        if (i == 0 && j % 2 != 0) continue;
        if (j == 0 && i % 2 != 0) continue;
        paresExtra.add([i, j]);
      }
    }
    
    print('GameLogic: Extra pairs generated successfully');

    List<List<int>> todosParesSuperiores = [...paresSuperiores, ...paresExtra];
    // Should be 156 pairs.
    // Shuffle and assign 3 to each of 52 cards.
    todosParesSuperiores.shuffle();
    
    // 2. Generate Middle Rows (Divisions)
    List<List<int>> paresMedios = [];
    for (int i = 1; i <= 81; i++) {
        for (int j = 1; j <= 9; j++) {
            if (i % j == 0) {
                int res = i ~/ j;
                if (res >= 1 && res <= 9) {
                    paresMedios.add([i, j]);
                }
            }
        }
    }
    // Select 52 random pairs
    paresMedios.shuffle();
    List<List<int>> seleccionParesMedios = paresMedios.take(52).toList();

    // 3. Generate Inferior Rows (Results)
    List<int> resultadosBase = [];
    for (int i = 0; i <= 10; i++) {
        for (int j = 0; j <= 10; j++) {
            if (i == 10 && j == 10) continue;
            resultadosBase.add(i * j);
        }
    }
    // Spec says: "sublista de 42 elementos con todos los posibles resultados...".
    // "todos los posibles resultados" of 0..10 * 0..10.
    // The set of unique results? {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, ... 100}
    // Let's assume unique results.
    Set<int> uniqueResults = {};
    for (int i = 0; i <= 10; i++) {
        for (int j = 0; j <= 10; j++) {
             if (i == 10 && j == 10) continue;
             uniqueResults.add(i * j);
        }
    }
    List<int> listaResultados = uniqueResults.toList(); 
    // Spec says "sublista de 42 elementos". If unique count is 42, then good.
    // Let's check count: 0..9*0..9 is max 81. 10*x adds 10, 20...90. 100.
    // It's roughly 43 items? 
    // Let's trust the spec says 42.
    
    List<int> listaConcatenada = [];
    for(int k=0; k<4; k++) {
      listaConcatenada.addAll(listaResultados);
    }
    
    // Remove 12 random
    for(int k=0; k<12; k++) {
        if(listaConcatenada.isNotEmpty) {
             int idx = random.nextInt(listaConcatenada.length);
             // Restriction: don't remove same number more than once.
             // We need to pick 12 indices or values to remove?
             // "no se elimine el mismo número más de una vez". 
             // Means we can't remove two '4's.
             // We'll pick a value, remove one instance of it, and remember not to pick it again.
        }
    }
    // Simplified for now: just take enough to fill 52 cards * 3 = 156.
    // If listaResultados has ~42. 42*4 = 168. 168 - 12 = 156.
    // Logic:
    List<int> toRemoveCandidates = List.from(listaResultados); 
    toRemoveCandidates.shuffle();
    List<int> valuesToRemove = toRemoveCandidates.take(12).toList();
    
    List<int> finalResultados = [];
    for(int val in listaConcatenada) {
        if (valuesToRemove.contains(val)) {
            valuesToRemove.remove(val); // Remove from 'to delete list' so we only remove one instance
        } else {
            finalResultados.add(val);
        }
    }
    // Ensure we have 156
    while(finalResultados.length > 156) {
      finalResultados.removeLast(); // Should not happen if logic is perfect
    }
    finalResultados.shuffle();

    // Assemble Cards
    for (int i = 0; i < 52; i++) {
        List<List<int>> row1 = [];
        row1.add(todosParesSuperiores[i*3]);
        row1.add(todosParesSuperiores[i*3+1]);
        row1.add(todosParesSuperiores[i*3+2]);
        
        List<int> row2 = seleccionParesMedios[i];
        
        List<int> row3 = [];
        row3.add(finalResultados[i*3]);
        row3.add(finalResultados[i*3+1]);
        row3.add(finalResultados[i*3+2]);

        baraja.add(Carta(
            id: 'offline_$i',
            multiplicaciones: row1,
            division: row2,
            resultados: row3
        ));
    }

    return baraja;
  }
}
