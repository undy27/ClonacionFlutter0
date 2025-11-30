// Modelo de carta del juego
class Card {
  final List<List<int>> multiplicaciones; // 3 pares [i,j]
  final List<int> division; // [dividend, divisor]
  final List<int> resultados; // 3 resultados

  Card({
    required this.multiplicaciones,
    required this.division,
    required this.resultados,
  });

  Map<String, dynamic> toJson() => {
    'multiplicaciones': multiplicaciones,
    'division': division,
    'resultados': resultados,
  };

  factory Card.fromJson(Map<String, dynamic> json) => Card(
    multiplicaciones: (json['multiplicaciones'] as List)
        .map((e) => (e as List).cast<int>())
        .toList(),
    division: (json['division'] as List).cast<int>(),
    resultados: (json['resultados'] as List).cast<int>(),
  );

  @override
  String toString() => 'Card(mults: $multiplicaciones, div: $division, res: $resultados)';
}
