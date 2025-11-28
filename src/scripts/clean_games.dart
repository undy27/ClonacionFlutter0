import 'package:postgres/postgres.dart';
import '../lib/config/supabase_config.dart';

void main() async {
  print('Limpiando partidas...');

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
    await connection.query("DELETE FROM partidas_jugadores");
    await connection.query("DELETE FROM partidas");
    print('Todas las partidas han sido eliminadas.');
  } catch (e) {
    print('Error: $e');
  } finally {
    await connection.close();
  }
}
