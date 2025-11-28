import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario.dart';
import '../models/partida.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  // ==================== USUARIOS ====================
  
  /// Obtiene un usuario por su alias
  Future<Usuario?> getUsuarioByAlias(String alias) async {
    try {
      final response = await client
          .from('usuarios')
          .select()
          .eq('alias', alias)
          .maybeSingle();
      
      if (response == null) return null;
      return Usuario.fromJson(response);
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
      final response = await client
          .from('usuarios')
          .insert({
            'id': id,
            'alias': alias,
            'avatar': avatar,
          })
          .select()
          .single();
      
      return Usuario.fromJson(response);
    } catch (e) {
      print('Error al crear usuario: $e');
      return null;
    }
  }

  /// Actualiza el tema de cartas del usuario
  Future<bool> updateTemaCartas(String usuarioId, String tema) async {
    try {
      await client
          .from('usuarios')
          .update({'tema_cartas': tema})
          .eq('id', usuarioId);
      return true;
    } catch (e) {
      print('Error al actualizar tema de cartas: $e');
      return false;
    }
  }

  // ==================== PARTIDAS ====================
  
  /// Obtiene todas las partidas en estado "esperando"
  Future<List<Partida>> getPartidasDisponibles() async {
    try {
      final response = await client
          .from('partidas')
          .select()
          .eq('estado', 'esperando')
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((partida) => Partida.fromJson(partida))
          .toList();
    } catch (e) {
      print('Error al obtener partidas: $e');
      return [];
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
    try {
      final response = await client
          .from('partidas')
          .insert({
            'id': id,
            'nombre': nombre,
            'creador_id': creadorId,
            'num_jugadores_objetivo': numJugadoresObjetivo,
            'rating_min': ratingMin,
            'rating_max': ratingMax,
            'estado': 'esperando',
          })
          .select()
          .single();
      
      return Partida.fromJson(response);
    } catch (e) {
      print('Error al crear partida: $e');
      return null;
    }
  }

  /// Actualiza el estado de una partida
  Future<bool> updatePartidaEstado(String partidaId, String estado) async {
    try {
      await client
          .from('partidas')
          .update({'estado': estado})
          .eq('id', partidaId);
      return true;
    } catch (e) {
      print('Error al actualizar estado de partida: $e');
      return false;
    }
  }

  /// Marca una partida como iniciada
  Future<bool> startPartida(String partidaId) async {
    try {
      await client
          .from('partidas')
          .update({
            'estado': 'en_curso',
            'inicio_partida': DateTime.now().toIso8601String(),
          })
          .eq('id', partidaId);
      return true;
    } catch (e) {
      print('Error al iniciar partida: $e');
      return false;
    }
  }

  /// Marca una partida como finalizada
  Future<bool> finalizarPartida(String partidaId, String ganadorId) async {
    try {
      await client
          .from('partidas')
          .update({
            'estado': 'finalizada',
            'ganador_id': ganadorId,
          })
          .eq('id', partidaId);
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
      final response = await client
          .from('usuarios')
          .select()
          .order('rating', ascending: false)
          .order('victorias', ascending: false)
          .limit(limit);
      
      return (response as List)
          .map((usuario) => Usuario.fromJson(usuario))
          .toList();
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

      final response = await client
          .from('usuarios')
          .select()
          .not(campo, 'is', null)
          .order(campo, ascending: true)
          .limit(limit);
      
      return (response as List)
          .map((usuario) => Usuario.fromJson(usuario))
          .toList();
    } catch (e) {
      print('Error al obtener récords: $e');
      return [];
    }
  }

  // ==================== REALTIME ====================
  
  /// Suscripción a cambios en las partidas (para actualizar lista en tiempo real)
  RealtimeChannel subscribeToPartidas(Function(List<Partida>) onUpdate) {
    return client
        .channel('partidas_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'partidas',
          callback: (payload) async {
            // Recargar todas las partidas disponibles
            final partidas = await getPartidasDisponibles();
            onUpdate(partidas);
          },
        )
        .subscribe();
  }

  /// Cancela una suscripción
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await client.removeChannel(channel);
  }
}
