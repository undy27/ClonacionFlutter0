import 'package:postgres/postgres.dart';
import '../lib/config/supabase_config.dart';

void main() async {
  print('Iniciando migración robusta de partidas_jugadores...');

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

    // 1. Check if table exists
    var check = await connection.query(
      "SELECT to_regclass('public.partidas_jugadores')",
      allowReuse: false
    );
    
    if (check.isNotEmpty && check.first[0] != null) {
      print('La tabla partidas_jugadores YA EXISTE.');
    } else {
      print('La tabla no existe. Intentando crear...');
      try {
        await connection.query('''
          CREATE TABLE IF NOT EXISTS partidas_jugadores (
            partida_id VARCHAR(255) REFERENCES partidas(id),
            usuario_id VARCHAR(255) REFERENCES usuarios(id),
            joined_at TIMESTAMP DEFAULT NOW(),
            PRIMARY KEY (partida_id, usuario_id)
          )
        ''', allowReuse: false);
        print('Comando de creación enviado.');
      } catch (e) {
        print('Error al intentar crear (puede ser falso positivo): $e');
      }
    }

    // 2. Verify again
    check = await connection.query(
      "SELECT to_regclass('public.partidas_jugadores')", 
      allowReuse: false
    );
    
    if (check.isNotEmpty && check.first[0] != null) {
      print('VERIFICACIÓN: La tabla EXISTE correctamente.');
    } else {
      print('VERIFICACIÓN: La tabla NO se creó.');
    }

  } catch (e) {
    print('Error fatal: $e');
  } finally {
    await connection.close();
  }
}
