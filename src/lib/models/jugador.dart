import 'carta.dart';

class Jugador {
  final String id;
  final String usuarioId;
  final String alias;
  final String avatar;
  List<Carta> mano;
  List<Carta> mazoRestante;
  List<Carta> cartasDescartadas;
  int penalizaciones;

  Jugador({
    required this.id,
    required this.usuarioId,
    required this.alias,
    required this.avatar,
    this.mano = const [],
    this.mazoRestante = const [],
    this.cartasDescartadas = const [],
    this.penalizaciones = 0,
  });

  factory Jugador.fromJson(Map<String, dynamic> json) {
    return Jugador(
      id: json['id'],
      usuarioId: json['usuario_id'],
      alias: json['alias'],
      avatar: json['avatar'] ?? 'default',
      mano: (json['mano'] as List?)
              ?.map((e) => Carta.fromJson(e))
              .toList() ??
          [],
      mazoRestante: (json['mazo_restante'] as List?)
              ?.map((e) => Carta.fromJson(e))
              .toList() ??
          [],
      cartasDescartadas: (json['cartas_descartadas'] as List?)
              ?.map((e) => Carta.fromJson(e))
              .toList() ??
          [],
      penalizaciones: json['penalizaciones'] ?? 0,
    );
  }
}
