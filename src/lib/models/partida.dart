class JugadorInfo {
  final String id;
  final String alias;
  final String? avatar;
  final int cartasRestantes;
  final int penalizaciones;
  
  JugadorInfo({
    required this.id, 
    required this.alias,
    this.avatar,
    this.cartasRestantes = 0,
    this.penalizaciones = 0,
  });
  
  factory JugadorInfo.fromJson(Map<String, dynamic> json) {
    return JugadorInfo(
      id: json['id'],
      alias: json['alias'],
      avatar: json['avatar'], // Puede ser null
      cartasRestantes: json['cartas_restantes'] ?? 0,
      penalizaciones: json['penalizaciones'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'alias': alias,
    'avatar': avatar,
    'cartas_restantes': cartasRestantes,
    'penalizaciones': penalizaciones,
  };
}

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
  final List<JugadorInfo> jugadores;

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
    this.jugadores = const [],
  });

  factory Partida.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      return null;
    }

    var jugadoresList = <JugadorInfo>[];
    if (json['jugadores'] != null) {
      jugadoresList = (json['jugadores'] as List)
          .map((i) => JugadorInfo.fromJson(i))
          .toList();
    }

    return Partida(
      id: json['id'],
      nombre: json['nombre'],
      creadorId: json['creador_id'],
      numJugadoresObjetivo: json['num_jugadores_objetivo'],
      ratingMin: json['rating_min'],
      ratingMax: json['rating_max'],
      estado: json['estado'] ?? 'esperando',
      ganadorId: json['ganador_id'],
      inicioPartida: parseDate(json['inicio_partida']),
      jugadores: jugadoresList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'creador_id': creadorId,
      'num_jugadores_objetivo': numJugadoresObjetivo,
      'rating_min': ratingMin,
      'rating_max': ratingMax,
      'estado': estado,
      'ganador_id': ganadorId,
      'inicio_partida': inicioPartida?.toIso8601String(),
      'jugadores': jugadores.map((j) => j.toJson()).toList(),
    };
  }
}
