class Usuario {
  final String id;
  final String alias;
  final String avatar;
  final int rating;
  final int partidasJugadas;
  final int victorias;
  final int derrotas;
  final String temaCartas;

  Usuario({
    required this.id,
    required this.alias,
    this.avatar = 'default',
    this.rating = 1500,
    this.partidasJugadas = 0,
    this.victorias = 0,
    this.derrotas = 0,
    this.temaCartas = 'clasico',
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      alias: json['alias'],
      avatar: json['avatar'] ?? 'default',
      rating: json['rating'] ?? 1500,
      partidasJugadas: json['partidas_jugadas'] ?? 0,
      victorias: json['victorias'] ?? 0,
      derrotas: json['derrotas'] ?? 0,
      temaCartas: json['tema_cartas'] ?? 'clasico',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alias': alias,
      'avatar': avatar,
      'rating': rating,
      'partidas_jugadas': partidasJugadas,
      'victorias': victorias,
      'derrotas': derrotas,
      'tema_cartas': temaCartas,
    };
  }
}
