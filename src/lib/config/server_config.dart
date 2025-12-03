class ServerConfig {
  // URLs del servidor
  static const String _internetUrl = 'ws://clonacion.duckdns.org/ws';
  static const String _localUrl = 'ws://192.168.1.149:8085/ws'; // Ajustar puerto si es necesario, usuario dijo 192.168.1.149
  
  // URL base para endpoints HTTP
  static const String _internetBaseUrl = 'http://clonacion.duckdns.org';
  static const String _localBaseUrl = 'http://192.168.1.149:8085';

  // Getter dinámico
  static String getGameServerUrl(bool useInternet) => useInternet ? _internetUrl : _localUrl;
  static String getBaseUrl(bool useInternet) => useInternet ? _internetBaseUrl : _localBaseUrl;

  // Deprecated: Mantener compatibilidad temporal si algo usa acceso directo
  static const String gameServerUrl = _internetUrl;
  static const String gameServerBaseUrl = _internetBaseUrl;
}
