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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Carta &&
        _listEquals(other.division, division) &&
        _listEquals(other.resultados, resultados) &&
        _nestedListEquals(other.multiplicaciones, multiplicaciones);
  }

  @override
  int get hashCode {
    return Object.hash(
      _listHash(division),
      _listHash(resultados),
      _nestedListHash(multiplicaciones),
    );
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _nestedListEquals<T>(List<List<T>>? a, List<List<T>>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!_listEquals(a[i], b[i])) return false;
    }
    return true;
  }
  
  int _listHash(List<dynamic> list) {
    return Object.hashAll(list);
  }
  
  int _nestedListHash(List<List<dynamic>> list) {
    return Object.hashAll(list.map((e) => _listHash(e)));
  }
}
