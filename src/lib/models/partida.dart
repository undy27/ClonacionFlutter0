class Partida {
  final String id;
  final String nombre;
  final String creadorId;
  final int numJugadoresObjetivo;
  final int ratingMin;
  final int ratingMax;
  final String estado; // 'esperando', 'jugando', 'finalizada'
  final String? ganadorId;
  final DateTime? inicioPartida;
  final List<String> jugadoresIds; // Helper to track joined players

  Partida({
    required this.id,
    required this.nombre,
    required this.creadorId,
    required this.numJugadoresObjetivo,
    required this.ratingMin,
    required this.ratingMax,
    this.estado = 'esperando',
    this.ganadorId,
    this.inicioPartida,
    this.jugadoresIds = const [],
  });
}
