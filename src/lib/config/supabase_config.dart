class SupabaseConfig {
  // PostgreSQL Direct Connection Configuration
  // Esta conexión es directa a PostgreSQL, similar a como lo hace el backend Node.js
  
  // Connection string completa de PostgreSQL
  static const String databaseUrl = 'postgresql://postgres.dwrzqqeabgrrornmyyum:ClonBD1111A4@aws-1-eu-west-1.pooler.supabase.com:6543/postgres';
  
  // Parámetros de conexión parseados
  static const String host = 'aws-1-eu-west-1.pooler.supabase.com';
  static const int port = 6543;
  static const String database = 'postgres';
  static const String username = 'postgres.dwrzqqeabgrrornmyyum';
  static const String password = 'ClonBD1111A4';
}
