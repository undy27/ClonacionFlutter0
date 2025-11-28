class Carta {
  final List<List<int>> multiplicaciones; // 3 pairs of [a, b]
  final List<int> division; // [i, j] representing i/j
  final List<int> resultados; // 3 integers

  Carta({
    required this.multiplicaciones,
    required this.division,
    required this.resultados,
  });

  factory Carta.fromJson(Map<String, dynamic> json) {
    return Carta(
      multiplicaciones: (json['multiplicaciones'] as List)
          .map((e) => List<int>.from(e))
          .toList(),
      division: List<int>.from(json['division']),
      resultados: List<int>.from(json['resultados']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'multiplicaciones': multiplicaciones,
      'division': division,
      'resultados': resultados,
    };
  }

  @override
  String toString() {
    return 'Carta(mult: $multiplicaciones, div: $division, res: $resultados)';
  }
}
