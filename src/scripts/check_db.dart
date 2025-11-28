import 'package:postgres/postgres.dart';
import '../lib/config/supabase_config.dart';

void main() async {
  print('Verificando base de datos...');

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

    // Check usuarios table
    var res = await connection.query("SELECT column_name FROM information_schema.columns WHERE table_name = 'usuarios'");
    print('Columnas en usuarios: ${res.map((r) => r[0]).toList()}');

    // Check partidas table
    res = await connection.query("SELECT column_name FROM information_schema.columns WHERE table_name = 'partidas'");
    print('Columnas en partidas: ${res.map((r) => r[0]).toList()}');

    // Check partidas_jugadores table
    res = await connection.query("SELECT column_name FROM information_schema.columns WHERE table_name = 'partidas_jugadores'");
    print('Columnas en partidas_jugadores: ${res.map((r) => r[0]).toList()}');

    if (res.isEmpty) {
        print("¡ALERTA! La tabla partidas_jugadores NO existe.");
    }

  } catch (e) {
    print('Error: $e');
  } finally {
    await connection.close();
  }
}
