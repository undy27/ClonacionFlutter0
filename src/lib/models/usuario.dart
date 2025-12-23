class Usuario {
  final String id;
  final String alias;
  final String avatar;
  final int rating;
  final int partidasJugadas;
  final int victorias;
  final int derrotas;
  final int? mejorTiempoVictoria;
  final int? mejorTiempoVictoria2j;
  final int? mejorTiempoVictoria3j;
  final int? mejorTiempoVictoria4j;
  final String temaCartas;
  final String temaInterfaz;
  final bool isGuest;
  final bool isDarkMode;
  final bool useInternetServer;

  Usuario({
    required this.id,
    required this.alias,
    this.avatar = 'default',
    this.rating = 1500,
    this.partidasJugadas = 0,
    this.victorias = 0,
    this.derrotas = 0,
    this.mejorTiempoVictoria,
    this.mejorTiempoVictoria2j,
    this.mejorTiempoVictoria3j,
    this.mejorTiempoVictoria4j,
    this.temaCartas = 'clasico',
    this.temaInterfaz = 'neo_brutalista',
    this.isGuest = false,
    this.isDarkMode = false,
    this.useInternetServer = true,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    // Validate avatar - if it doesn't exist, assign a random one
    String avatarValue = json['avatar'] ?? 'default';
    
    // Handle 'default' avatar silently (assign random without logging)
    if (avatarValue == 'default') {
      avatarValue = _getRandomAvatar();
    } else if (!_isValidAvatar(avatarValue)) {
      // Only log for truly invalid avatars
      final originalAvatar = avatarValue;
      avatarValue = _getRandomAvatar();
      print('[Usuario] Avatar "$originalAvatar" not found, assigned random: $avatarValue');
    }
    
    return Usuario(
      id: json['id'],
      alias: json['alias'],
      avatar: avatarValue,
      rating: json['rating'] ?? 1500,
      partidasJugadas: json['partidas_jugadas'] ?? 0,
      victorias: json['victorias'] ?? 0,
      derrotas: json['derrotas'] ?? 0,
      mejorTiempoVictoria: json['mejor_tiempo_victoria'],
      mejorTiempoVictoria2j: json['mejor_tiempo_victoria_2j'],
      mejorTiempoVictoria3j: json['mejor_tiempo_victoria_3j'],
      mejorTiempoVictoria4j: json['mejor_tiempo_victoria_4j'],
      temaCartas: json['tema_cartas'] ?? 'clasico',
      temaInterfaz: json['tema_interfaz'] ?? 'neo_brutalista',
      isGuest: json['is_guest'] ?? false,
      isDarkMode: json['is_dark_mode'] ?? false,
      useInternetServer: json['use_internet_server'] ?? true,
    );
  }
  
  static bool _isValidAvatar(String avatar) {
    const availableAvatars = ['ainara', 'amy', 'androide', 'cientifico', 'fx'];
    return availableAvatars.contains(avatar);
  }
  
  static String _getRandomAvatar() {
    const availableAvatars = ['ainara', 'amy', 'androide', 'cientifico', 'fx'];
    final random = DateTime.now().millisecondsSinceEpoch % availableAvatars.length;
    return availableAvatars[random];
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
      'mejor_tiempo_victoria': mejorTiempoVictoria,
      'mejor_tiempo_victoria_2j': mejorTiempoVictoria2j,
      'mejor_tiempo_victoria_3j': mejorTiempoVictoria3j,
      'mejor_tiempo_victoria_4j': mejorTiempoVictoria4j,
      'tema_cartas': temaCartas,
      'tema_interfaz': temaInterfaz,
      'is_guest': isGuest,
      'is_dark_mode': isDarkMode,
      'use_internet_server': useInternetServer,
    };
  }
}
