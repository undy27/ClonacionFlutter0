import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class Carta {
  final String id;
  final List<List<int>> multiplicaciones; // 3 pairs of [a, b]
  final List<int> division; // [i, j] representing i/j
  final List<int> resultados; // 3 integers

  Carta({
    required this.id,
    required this.multiplicaciones,
    required this.division,
    required this.resultados,
  });

  factory Carta.fromJson(Map<String, dynamic> json) {
    return Carta(
      id: json['id'] as String? ?? const Uuid().v4(),
      multiplicaciones: (json['multiplicaciones'] as List)
          .map((e) => List<int>.from(e))
          .toList(),
      division: List<int>.from(json['division']),
      resultados: List<int>.from(json['resultados']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'multiplicaciones': multiplicaciones,
      'division': division,
      'resultados': resultados,
    };
  }

  @override
  String toString() {
    return 'Carta(id: $id, mult: $multiplicaciones, div: $division, res: $resultados)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Carta && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
