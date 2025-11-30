class ServerConfig {
  // URL del servidor de juego
  // En desarrollo local: 'ws://localhost:8080/ws'
  // En producción: 'ws://tu-dominio.com:8080/ws'
  static const String gameServerUrl = 'ws://localhost:8080/ws';
  
  // URL base para endpoints HTTP (si se necesitan)
  static const String gameServerBaseUrl = 'http://localhost:8080';
}
