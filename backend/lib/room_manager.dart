import 'dart:async';
import 'game_room.dart';

class RoomManager {
  static final RoomManager _instance = RoomManager._internal();
  factory RoomManager() => _instance;
  RoomManager._internal() {
    // Start cleanup timer
    _startCleanupTimer();
  }

  final Map<String, GameRoom> _rooms = {};
  Timer? _cleanupTimer;

  void _startCleanupTimer() {
    // Run cleanup every 30 minutes
    _cleanupTimer = Timer.periodic(Duration(minutes: 30), (_) {
      cleanupOldRooms();
    });
  }

  GameRoom? getRoom(String roomId) => _rooms[roomId];

  GameRoom createRoom({
    required String id,
    required String name,
    required int maxPlayers,
  }) {
    if (_rooms.containsKey(id)) {
      throw Exception('Room with id $id already exists');
    }

    final room = GameRoom(
      id: id,
      name: name,
      maxPlayers: maxPlayers,
    );
    
    _rooms[id] = room;
    print('[RoomManager] Created room: $id ($name)');
    return room;
  }

  void removeRoom(String roomId) {
    _rooms.remove(roomId);
    print('[RoomManager] Removed room: $roomId');
  }

  List<GameRoom> getAllRooms() => _rooms.values.toList();

  List<GameRoom> getAvailableRooms() {
    return _rooms.values
        .where((room) => room.status == GameStatus.waiting && room.players.length < room.maxPlayers)
        .toList();
  }

  GameRoom? findRoomWithPlayer(String playerId) {
    try {
      return _rooms.values.firstWhere((room) => room.players.any((p) => p.id == playerId));
    } catch (e) {
      return null;
    }
  }

  void cleanupEmptyRooms() {
    final toRemove = <String>[];
    _rooms.forEach((id, room) {
      if (room.players.isEmpty) {
        toRemove.add(id);
      }
    });
    
    for (var id in toRemove) {
      removeRoom(id);
    }
  }

  /// Clean up old rooms based on age and activity
  void cleanupOldRooms() {
    final now = DateTime.now();
    final toRemove = <String>[];
    
    _rooms.forEach((id, room) {
      final age = now.difference(room.createdAt);
      final inactivity = now.difference(room.lastActivityAt);
      
      // Remove rooms older than 1 week
      if (age.inDays >= 7) {
        print('[RoomManager] Removing room $id: older than 7 days (${age.inDays} days)');
        toRemove.add(id);
      }
      // Mark as inactive rooms with >2 hours of inactivity
      else if (inactivity.inHours >= 2 && room.status == GameStatus.playing) {
        print('[RoomManager] Marking room $id as finished: inactive for ${inactivity.inHours} hours');
        room.status = GameStatus.finished;
        // Optionally remove it as well
        toRemove.add(id);
      }
    });
    
    for (var id in toRemove) {
      removeRoom(id);
    }
    
    if (toRemove.isNotEmpty) {
      print('[RoomManager] Cleaned up ${toRemove.length} old/inactive rooms');
    }
  }

  void dispose() {
    _cleanupTimer?.cancel();
  }
}
