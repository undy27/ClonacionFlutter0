import 'package:postgres/postgres.dart';
import '../lib/config/supabase_config.dart';

void main() async {
  print('Iniciando migración de autenticación...');

  final connection = PostgreSQLConnection(
    SupabaseConfig.host,
    SupabaseConfig.port,
    SupabaseConfig.database,
    username: SupabaseConfig.username,
    password: SupabaseConfig.password,
    useSSL: true,
  );

  try {
    await connection.open();
    print('Conexión establecida.');

    // Add password_hash
    try {
      await connection.query('ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255)', allowReuse: false);
      print('Columna password_hash verificada/creada.');
    } catch (e) {
      print('Error con password_hash: $e');
    }

    // Add is_guest
    try {
      await connection.query('ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS is_guest BOOLEAN DEFAULT FALSE', allowReuse: false);
      print('Columna is_guest verificada/creada.');
    } catch (e) {
      print('Error con is_guest: $e');
    }

  } catch (e) {
    print('Error general: $e');
  } finally {
    await connection.close();
    print('Conexión cerrada.');
  }
}
