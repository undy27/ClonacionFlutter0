class ServerConfig {
  // URL del servidor de juego
  // En desarrollo local: 'ws://192.168.1.149:8080/ws'
  // En producción: 'ws://tu-dominio.com:8080/ws'
  static const String gameServerUrl = 'ws://clonacion.duckdns.org:8085/ws';
  
  // URL base para endpoints HTTP (si se necesitan)
  static const String gameServerBaseUrl = 'http://clonacion.duckdns.org:8085';
}
