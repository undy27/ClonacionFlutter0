import 'game_room.dart';

class RoomManager {
  static final RoomManager _instance = RoomManager._internal();
  factory RoomManager() => _instance;
  RoomManager._internal();

  final Map<String, GameRoom> _rooms = {};

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
}
