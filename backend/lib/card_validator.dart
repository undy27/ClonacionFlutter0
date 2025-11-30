import 'models/card.dart';

class CardValidator {
  /// Valida si una carta puede ser descartada sobre otra según las reglas del juego
  static bool canPlayCard(Card cardToPlay, Card topCard) {
    // Obtener todos los valores calculados de ambas cartas
    final playMults = _getMultiplicationResults(cardToPlay.multiplicaciones);
    final topMults = _getMultiplicationResults(topCard.multiplicaciones);
    
    final playDiv = _getDivisionResult(cardToPlay.division);
    final topDiv = _getDivisionResult(topCard.division);
    
    final playResults = cardToPlay.resultados;
    final topResults = topCard.resultados;

    // Regla 1: Multiplicación de cardToPlay coincide con multiplicación de topCard
    //          (i*j=x*y) AND (i,j)≠(x,y) AND (i,j)≠(y,x)
    for (int i = 0; i < cardToPlay.multiplicaciones.length; i++) {
      for (int j = 0; j < topCard.multiplicaciones.length; j++) {
        if (playMults[i] == topMults[j]) {
          final playPair = cardToPlay.multiplicaciones[i];
          final topPair = topCard.multiplicaciones[j];
          // Verificar que no sean el mismo par ni el par invertido
          if (!(playPair[0] == topPair[0] && playPair[1] == topPair[1]) &&
              !(playPair[0] == topPair[1] && playPair[1] == topPair[0])) {
            return true;
          }
        }
      }
    }

    // Regla 2: Multiplicación de cardToPlay coincide con división de topCard
    for (final playMult in playMults) {
      if (playMult == topDiv) return true;
    }

    // Regla 3: Multiplicación de cardToPlay coincide con resultado de topCard
    for (final playMult in playMults) {
      if (topResults.contains(playMult)) return true;
    }

    // Regla 4: Multiplicación de topCard coincide con resultado de cardToPlay
    for (final topMult in topMults) {
      if (playResults.contains(topMult)) return true;
    }

    // Regla 5: División de cardToPlay coincide con multiplicación de topCard
    if (topMults.contains(playDiv)) return true;

    // Regla 6: División de cardToPlay coincide con resultado de topCard
    if (topResults.contains(playDiv)) return true;

    // Regla 7: División de topCard coincide con resultado de cardToPlay
    if (playResults.contains(topDiv)) return true;

    // Regla 8: División de cardToPlay coincide con división de topCard
    if (playDiv == topDiv) return true;

    return false;
  }

  /// Calcula los resultados de todas las multiplicaciones de una carta
  static List<int> _getMultiplicationResults(List<List<int>> multiplicaciones) {
    return multiplicaciones.map((pair) => pair[0] * pair[1]).toList();
  }

  /// Calcula el resultado de la división de una carta
  static int _getDivisionResult(List<int> division) {
    return division[0] ~/ division[1]; // División entera
  }

  /// Obtiene detalles de qué coincidió para debugging
  static Map<String, dynamic> getMatchDetails(Card cardToPlay, Card topCard) {
    final details = <String, List<int>>{
      'matchedMults': [],
      'matchedResults': [],
    };
    bool matchedDiv = false;

    final playMults = _getMultiplicationResults(cardToPlay.multiplicaciones);
    final topMults = _getMultiplicationResults(topCard.multiplicaciones);
    final playDiv = _getDivisionResult(cardToPlay.division);
    final topDiv = _getDivisionResult(topCard.division);

    // Verificar multiplicaciones
    for (int i = 0; i < playMults.length; i++) {
      for (int j = 0; j < topMults.length; j++) {
        if (playMults[i] == topMults[j]) {
          final playPair = cardToPlay.multiplicaciones[i];
          final topPair = topCard.multiplicaciones[j];
          if (!(playPair[0] == topPair[0] && playPair[1] == topPair[1]) &&
              !(playPair[0] == topPair[1] && playPair[1] == topPair[0])) {
            details['matchedMults']!.add(i);
          }
        }
      }
    }

    // Verificar división
    if (playDiv == topDiv || 
        topMults.contains(playDiv) || 
        playMults.contains(topDiv) ||
        topCard.resultados.contains(playDiv) ||
        cardToPlay.resultados.contains(topDiv)) {
      matchedDiv = true;
    }

    // Verificar resultados
    for (int i = 0; i < cardToPlay.resultados.length; i++) {
      if (topMults.contains(cardToPlay.resultados[i]) ||
          topCard.resultados.contains(cardToPlay.resultados[i]) ||
          cardToPlay.resultados[i] == topDiv) {
        details['matchedResults']!.add(i);
      }
    }

    return {
      'matchedMults': details['matchedMults'],
      'matchedDiv': matchedDiv,
      'matchedResults': details['matchedResults'],
      'hasMatch': details['matchedMults']!.isNotEmpty || matchedDiv || details['matchedResults']!.isNotEmpty,
    };
  }
}
