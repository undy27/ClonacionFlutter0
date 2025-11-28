import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:postgres/postgres.dart';
import '../models/usuario.dart';
import '../models/partida.dart';
import '../config/supabase_config.dart';

class PostgresService {
  static final PostgresService _instance = PostgresService._internal();
  factory PostgresService() => _instance;
  PostgresService._internal();

  PostgreSQLConnection? _connection;

  // Obtener o crear conexión
  Future<PostgreSQLConnection> _getConnection() async {
    if (_connection != null && !_connection!.isClosed) {
      return _connection!;
    }
    
    _connection = PostgreSQLConnection(
      SupabaseConfig.host,
      SupabaseConfig.port,
      SupabaseConfig.database,
      username: SupabaseConfig.username,
      password: SupabaseConfig.password,
      useSSL: true,
    );
    
    await _connection!.open();
    return _connection!;
  }

  // Cerrar conexión
  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }

  // ==================== AUTH ====================

  Future<void> initAuthTables() async {
    try {
      final conn = await _getConnection();
      // Try to add columns if they don't exist
      // Note: This might fail if user doesn't have permissions, but worth a try for dev
      try {
        await conn.query('ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255)');
      } catch (_) {}
      try {
        await conn.query('ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS is_guest BOOLEAN DEFAULT FALSE');
      } catch (_) {}
      try {
        await conn.query('ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS is_dark_mode BOOLEAN DEFAULT FALSE');
      } catch (_) {}
    } catch (e) {
      print('Error initializing auth tables: $e');
    }
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Usuario?> login(String alias, String password) async {
    try {
      final conn = await _getConnection();
      final hashedPassword = _hashPassword(password);
      
      final result = await conn.query(
        'SELECT * FROM usuarios WHERE alias = @alias AND password_hash = @password LIMIT 1',
        substitutionValues: {
          'alias': alias,
          'password': hashedPassword,
        },
        allowReuse: false,
      );
      
      if (result.isEmpty) return null;
      return Usuario.fromJson(result.first.toColumnMap());
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<Usuario?> register(String alias, String password) async {
    try {
      final conn = await _getConnection();
      final hashedPassword = _hashPassword(password);
      final id = DateTime.now().millisecondsSinceEpoch.toString(); 

      final result = await conn.query(
        '''
          INSERT INTO usuarios (id, alias, password_hash, is_guest)
          VALUES (@id, @alias, @password, FALSE)
          RETURNING *
        ''',
        substitutionValues: {
          'id': id,
          'alias': alias,
          'password': hashedPassword,
        },
        allowReuse: false,
      );
      
      if (result.isEmpty) return null;
      return Usuario.fromJson(result.first.toColumnMap());
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }

  Future<Usuario?> createGuest(String alias) async {
    try {
      final conn = await _getConnection();
      final id = "guest_${DateTime.now().millisecondsSinceEpoch}";

      final result = await conn.query(
        '''
          INSERT INTO usuarios (id, alias, is_guest)
          VALUES (@id, @alias, TRUE)
          RETURNING *
        ''',
        substitutionValues: {
          'id': id,
          'alias': alias,
        },
        allowReuse: false,
      );
      
      if (result.isEmpty) return null;
      return Usuario.fromJson(result.first.toColumnMap());
    } catch (e) {
      print('Guest creation error: $e');
      return null;
    }
  }

  // ==================== USUARIOS ====================
  
  /// Obtiene un usuario por su alias
  Future<Usuario?> getUsuarioByAlias(String alias) async {
    try {
      final conn = await _getConnection();
      final result = await conn.query(
        'SELECT * FROM usuarios WHERE alias = @alias LIMIT 1',
        substitutionValues: {'alias': alias},
        allowReuse: false,
      );
      
      if (result.isEmpty) return null;
      
      return Usuario.fromJson(result.first.toColumnMap());
    } catch (e) {
      print('Error al obtener usuario: $e');
      return null;
    }
  }

  /// Crea un nuevo usuario
  Future<Usuario?> createUsuario({
    required String id,
    required String alias,
    String avatar = 'default',
  }) async {
    try {
      final conn = await _getConnection();
      final result = await conn.query(
        '''
          INSERT INTO usuarios (id, alias, avatar)
          VALUES (@id, @alias, @avatar)
          RETURNING *
        ''',
        substitutionValues: {
          'id': id,
          'alias': alias,
          'avatar': avatar,
        },
        allowReuse: false,
      );
      
      if (result.isEmpty) return null;
      
      return Usuario.fromJson(result.first.toColumnMap());
    } catch (e) {
      print('Error al crear usuario: $e');
      return null;
    }
  }

  /// Actualiza el tema de cartas del usuario
  Future<bool> updateTemaCartas(String usuarioId, String tema) async {
    try {
      final conn = await _getConnection();
      await conn.query(
        '''
          UPDATE usuarios 
          SET tema_cartas = @tema 
          WHERE id = @usuarioId
        ''',
        substitutionValues: {
          'tema': tema,
          'usuarioId': usuarioId,
        },
        allowReuse: false,
      );
      return true;
    } catch (e) {
      print('Error al actualizar tema de cartas: $e');
      return false;
    }
  }

  /// Actualiza la preferencia de modo oscuro del usuario
  Future<bool> updateThemePreference(String usuarioId, bool isDark) async {
    try {
      final conn = await _getConnection();
      await conn.query(
        'UPDATE usuarios SET is_dark_mode = @isDark WHERE id = @uid',
        substitutionValues: {'isDark': isDark, 'uid': usuarioId},
        allowReuse: false,
      );
      return true;
    } catch (e) {
      print('Error updating theme preference: $e');
      return false;
    }
  }

  // ==================== PARTIDAS ====================
  
  // ==================== PARTIDAS ====================
  
  Future<List<Map<String, dynamic>>> _getJugadoresPartida(PostgreSQLConnection conn, String partidaId) async {
    final result = await conn.query(
      '''
      SELECT DISTINCT u.id, u.alias 
      FROM partidas_jugadores pj
      JOIN usuarios u ON pj.usuario_id = u.id
      WHERE pj.partida_id = @id
      ''',
      substitutionValues: {'id': partidaId},
      allowReuse: false,
    );
    return result.map((r) => {'id': r[0], 'alias': r[1]}).toList();
  }

  /// Obtiene todas las partidas en estado "esperando"
  Future<List<Partida>> getPartidasDisponibles() async {
    try {
      final conn = await _getConnection();
      final result = await conn.query(
        '''
          SELECT DISTINCT p.*, p.created_at FROM partidas p
          INNER JOIN partidas_jugadores pj ON p.id = pj.partida_id
          WHERE p.estado = @estado 
          ORDER BY p.created_at DESC
        ''',
        substitutionValues: {'estado': 'esperando'},
        allowReuse: false,
      );
      
      List<Partida> partidas = [];
      for (var row in result) {
        var map = row.toColumnMap();
        var jugadores = await _getJugadoresPartida(conn, map['id']);
        map['jugadores'] = jugadores;
        partidas.add(Partida.fromJson(map));
      }
      return partidas;
    } catch (e) {
      print('Error al obtener partidas: $e');
      return [];
    }
  }

  /// Verifica si un usuario tiene una partida activa (creada por él o unido)
  Future<Partida?> getPartidaActivaByUsuario(String usuarioId) async {
    try {
      final conn = await _getConnection();
      final result = await conn.query(
        '''
          SELECT p.* FROM partidas p
          JOIN partidas_jugadores pj ON p.id = pj.partida_id
          WHERE pj.usuario_id = @usuarioId 
          AND (p.estado = 'esperando' OR p.estado = 'en_curso')
          LIMIT 1
        ''',
        substitutionValues: {'usuarioId': usuarioId},
        allowReuse: false,
      );
      
      if (result.isEmpty) return null;
      
      var map = result.first.toColumnMap();
      var jugadores = await _getJugadoresPartida(conn, map['id']);
      map['jugadores'] = jugadores;
      
      return Partida.fromJson(map);
    } catch (e) {
      print('Error al verificar partida activa: $e');
      return null;
    }
  }

  /// Obtiene una partida por su ID
  Future<Partida?> getPartidaById(String id) async {
    try {
      final conn = await _getConnection();
      final result = await conn.query(
        'SELECT * FROM partidas WHERE id = @id LIMIT 1',
        substitutionValues: {'id': id},
        allowReuse: false,
      );
      
      if (result.isEmpty) return null;
      
      var map = result.first.toColumnMap();
      var jugadores = await _getJugadoresPartida(conn, map['id']);
      map['jugadores'] = jugadores;
      
      return Partida.fromJson(map);
    } catch (e) {
      print('Error al obtener partida: $e');
      return null;
    }
  }

  /// Crea una nueva partida
  Future<Partida?> createPartida({
    required String id,
    required String nombre,
    required String creadorId,
    required int numJugadoresObjetivo,
    required int ratingMin,
    required int ratingMax,
  }) async {
    PostgreSQLConnection? conn;
    try {
      conn = PostgreSQLConnection(
        SupabaseConfig.host,
        SupabaseConfig.port,
        SupabaseConfig.database,
        username: SupabaseConfig.username,
        password: SupabaseConfig.password,
        useSSL: true,
      );
      await conn.open();

      final result = await conn.query(
        '''
          INSERT INTO partidas (
            id, nombre, creador_id, num_jugadores_objetivo, 
            rating_min, rating_max, estado
          )
          VALUES (
            @id, @nombre, @creadorId, @numJugadores,
            @ratingMin, @ratingMax, 'esperando'
          )
          RETURNING *
        ''',
        substitutionValues: {
          'id': id,
          'nombre': nombre,
          'creadorId': creadorId,
          'numJugadores': numJugadoresObjetivo,
          'ratingMin': ratingMin,
          'ratingMax': ratingMax,
        },
        allowReuse: false,
      );
      
      if (result.isEmpty) return null;

      await conn.query(
        'INSERT INTO partidas_jugadores (partida_id, usuario_id) VALUES (@pid, @uid)',
        substitutionValues: {'pid': id, 'uid': creadorId},
        allowReuse: false,
      );
      
      // Get creator alias
      final creatorRes = await conn.query(
        'SELECT alias FROM usuarios WHERE id = @uid', 
        substitutionValues: {'uid': creadorId},
        allowReuse: false
      );
      String creatorAlias = creatorRes.isNotEmpty ? creatorRes.first[0] as String : 'Unknown';

      var map = result.first.toColumnMap();
      map['jugadores'] = [{'id': creadorId, 'alias': creatorAlias}];
      
      return Partida.fromJson(map);
    } catch (e) {
      print('Error al crear partida: $e');
      return null;
    } finally {
      await conn?.close();
    }
  }

  Future<bool> joinPartida(String partidaId, String usuarioId) async {
    print("PostgresService.joinPartida: User $usuarioId joining Game $partidaId");
    PostgreSQLConnection? conn;
    try {
      conn = PostgreSQLConnection(
        SupabaseConfig.host,
        SupabaseConfig.port,
        SupabaseConfig.database,
        username: SupabaseConfig.username,
        password: SupabaseConfig.password,
        useSSL: true,
      );
      await conn.open();

      // Check if already joined
      final check = await conn.query(
        'SELECT * FROM partidas_jugadores WHERE partida_id = @pid AND usuario_id = @uid',
        substitutionValues: {'pid': partidaId, 'uid': usuarioId},
        allowReuse: false,
      );
      if (check.isNotEmpty) return true;

      await conn.query(
        'INSERT INTO partidas_jugadores (partida_id, usuario_id) VALUES (@pid, @uid)',
        substitutionValues: {'pid': partidaId, 'uid': usuarioId},
        allowReuse: false,
      );
      return true;
    } catch (e) {
      print('Error joining game: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }

  Future<bool> leavePartida(String partidaId, String usuarioId) async {
    PostgreSQLConnection? conn;
    try {
      conn = PostgreSQLConnection(
        SupabaseConfig.host,
        SupabaseConfig.port,
        SupabaseConfig.database,
        username: SupabaseConfig.username,
        password: SupabaseConfig.password,
        useSSL: true,
      );
      await conn.open();

      await conn.query(
        'DELETE FROM partidas_jugadores WHERE partida_id = @pid AND usuario_id = @uid',
        substitutionValues: {'pid': partidaId, 'uid': usuarioId},
        allowReuse: false,
      );
      
      // Check if game is empty, if so, delete it
      final countRes = await conn.query(
        'SELECT COUNT(*) FROM partidas_jugadores WHERE partida_id = @pid',
        substitutionValues: {'pid': partidaId},
        allowReuse: false,
      );
      
      if (countRes.isNotEmpty && (countRes.first[0] as int) == 0) {
         await conn.query(
           'DELETE FROM partidas WHERE id = @pid',
           substitutionValues: {'pid': partidaId},
           allowReuse: false,
         );
      }

      return true;
    } catch (e) {
      print('Error leaving game: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }

  /// Actualiza el estado de una partida
  Future<bool> updatePartidaEstado(String partidaId, String estado) async {
    try {
      final conn = await _getConnection();
      await conn.query(
        '''
          UPDATE partidas 
          SET estado = @estado 
          WHERE id = @partidaId
        ''',
        substitutionValues: {
          'estado': estado,
          'partidaId': partidaId,
        },
        allowReuse: false,
      );
      return true;
    } catch (e) {
      print('Error al actualizar estado de partida: $e');
      return false;
    }
  }

  /// Marca una partida como iniciada
  Future<bool> startPartida(String partidaId) async {
    try {
      final conn = await _getConnection();
      final result = await conn.query(
        '''
          UPDATE partidas 
          SET estado = 'en_curso', inicio_partida = NOW() 
          WHERE id = @partidaId AND estado = 'esperando'
        ''',
        substitutionValues: {'partidaId': partidaId},
        allowReuse: false,
      );
      // If affected rows > 0, we started it. If 0, it was already started or didn't exist.
      // But for the provider logic, we just want to know if it's done.
      // Actually, checking affected rows would be better to know if *we* started it, 
      // but returning true is fine as long as no error occurred.
      return true;
    } catch (e) {
      print('Error al iniciar partida: $e');
      return false;
    }
  }

  /// Marca una partida como finalizada
  Future<bool> finalizarPartida(String partidaId, String ganadorId) async {
    try {
      final conn = await _getConnection();
      await conn.query(
        '''
          UPDATE partidas 
          SET estado = 'finalizada', ganador_id = @ganadorId 
          WHERE id = @partidaId
        ''',
        substitutionValues: {
          'ganadorId': ganadorId,
          'partidaId': partidaId,
        },
        allowReuse: false,
      );
      return true;
    } catch (e) {
      print('Error al finalizar partida: $e');
      return false;
    }
  }

  // ==================== RANKING ====================
  
  /// Obtiene el ranking global de usuarios
  Future<List<Usuario>> getRankingGlobal({int limit = 50}) async {
    try {
      final conn = await _getConnection();
      final result = await conn.query(
        '''
          SELECT * FROM usuarios 
          ORDER BY rating DESC, victorias DESC 
          LIMIT @limit
        ''',
        substitutionValues: {'limit': limit},
        allowReuse: false,
      );
      
      return result.map((row) {
        return Usuario.fromJson(row.toColumnMap());
      }).toList();
    } catch (e) {
      print('Error al obtener ranking: $e');
      return [];
    }
  }

  /// Obtiene los récords de tiempo por categoría
  Future<List<Usuario>> getRecordsTiempo({
    required int numJugadores,
    int limit = 10,
  }) async {
    try {
      String campo;
      switch (numJugadores) {
        case 2:
          campo = 'mejor_tiempo_victoria_2j';
          break;
        case 3:
          campo = 'mejor_tiempo_victoria_3j';
          break;
        case 4:
          campo = 'mejor_tiempo_victoria_4j';
          break;
        default:
          return [];
      }

      final conn = await _getConnection();
      final result = await conn.query(
        '''
          SELECT * FROM usuarios 
          WHERE $campo IS NOT NULL 
          ORDER BY $campo ASC 
          LIMIT @limit
        ''',
        substitutionValues: {'limit': limit},
        allowReuse: false,
      );
      
      return result.map((row) {
        return Usuario.fromJson(row.toColumnMap());
      }).toList();
    } catch (e) {
      print('Error al obtener récords: $e');
      return [];
    }
  }
}
