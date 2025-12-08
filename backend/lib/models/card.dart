import 'dart:math';

// Modelo de carta del juego
class Card {
  final String id;
  final List<List<int>> multiplicaciones; // 3 pares [i,j]
  final List<int> division; // [dividend, divisor]
  final List<int> resultados; // 3 resultados

  Card({
    String? id,
    required this.multiplicaciones,
    required this.division,
    required this.resultados,
  }) : id = id ?? '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(10000).toString()}';

  Map<String, dynamic> toJson() => {
    'id': id,
    'multiplicaciones': multiplicaciones,
    'division': division,
    'resultados': resultados,
  };

  factory Card.fromJson(Map<String, dynamic> json) => Card(
    id: json['id'] as String?,
    multiplicaciones: (json['multiplicaciones'] as List)
        .map((e) => (e as List).cast<int>())
        .toList(),
    division: (json['division'] as List).cast<int>(),
    resultados: (json['resultados'] as List).cast<int>(),
  );

  @override
  String toString() => 'Card(mults: $multiplicaciones, div: $division, res: $resultados)';
}
