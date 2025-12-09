import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../lib/room_manager.dart';
import '../lib/game_room.dart';
import '../lib/models/player.dart';

void main() async {
  final roomManager = RoomManager();
  final router = Router();

  // Health Check
  router.get('/health', (Request request) {
    return Response.ok('Game Server is running');
  });

  // List available rooms
  router.get('/rooms', (Request request) {
    // Get user rating from query parameter (default 1500 if not provided)
    final userRatingStr = request.url.queryParameters['rating'];
    final userRating = userRatingStr != null ? int.tryParse(userRatingStr) ?? 1500 : 1500;
    
    // Filter and map rooms
    final rooms = roomManager.getAvailableRooms()
        .where((room) => userRating >= room.minRating && userRating <= room.maxRating)
        .map((room) => {
          'id': room.id,
          'name': room.name,
          'players': room.players.length,
          'maxPlayers': room.maxPlayers,
          'minRating': room.minRating,
          'maxRating': room.maxRating,
        }).toList();
    
    return Response.ok(
      jsonEncode({'rooms': rooms}),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // WebSocket endpoint
  router.get('/ws', webSocketHandler((WebSocketChannel webSocket) {
    print('[Server] New WebSocket connection');
    
    Player? currentPlayer;
    GameRoom? currentRoom;

    webSocket.stream.listen(
      (message) {
        try {
          final data = jsonDecode(message as String);
          final type = data['type'] as String;

          switch (type) {
            case 'CREATE_ROOM':
              _handleCreateRoom(webSocket, data, roomManager);
              break;

            case 'JOIN':
              final result = _handleJoin(webSocket, data, roomManager);
              if (result != null) {
                currentPlayer = result['player'];
                currentRoom = result['room'];
              }
              break;

            case 'START_GAME':
              if (currentRoom != null) {
                currentRoom!.startGame();
              }
              break;

            case 'PLAY_CARD':
              if (currentRoom != null && currentPlayer != null) {
                final cardIndex = data['cardIndex'] as int;
                final pileIndex = data['pileIndex'] as int;
                currentRoom!.handlePlayCard(currentPlayer!.id, cardIndex, pileIndex);
              }
              break;

            case 'DRAW_CARD':
              if (currentRoom != null && currentPlayer != null) {
                final slotIndex = data['slotIndex'] as int;
                currentRoom!.handleDrawCard(currentPlayer!.id, slotIndex);
              }
              break;

            default:
              print('[Server] Unknown message type: $type');
          }
        } catch (e, stack) {
          print('[Server] Error handling message: $e');
          print(stack);
          webSocket.sink.add(jsonEncode({
            'type': 'ERROR',
            'message': 'Server error: ${e.toString()}',
          }));
        }
      },
      onDone: () {
        print('[Server] Client disconnected');
        if (currentRoom != null && currentPlayer != null) {
          currentRoom!.removePlayer(currentPlayer!.id);
          roomManager.cleanupEmptyRooms();
        }
      },
      onError: (error) {
        print('[Server] WebSocket error: $error');
      },
    );
  }));

  // Server configuration
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_corsHeaders())
      .addHandler(router);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);

  print('🎮 Game Server listening on http://${server.address.host}:${server.port}');
}

void _handleCreateRoom(WebSocketChannel socket, Map<String, dynamic> data, RoomManager manager) {
  final roomId = data['roomId'] as String;
  final roomName = data['roomName'] as String;
  final maxPlayers = data['maxPlayers'] as int? ?? 4;
  final minRating = data['minRating'] as int? ?? 0;
  final maxRating = data['maxRating'] as int? ?? 9999;

  try {
    final room = manager.createRoom(
      id: roomId,
      name: roomName,
      maxPlayers: maxPlayers,
      minRating: minRating,
      maxRating: maxRating,
    );

    socket.sink.add(jsonEncode({
      'type': 'ROOM_CREATED',
      'roomId': room.id,
    }));
  } catch (e) {
    socket.sink.add(jsonEncode({
      'type': 'ERROR',
      'message': e.toString(),
    }));
  }
}

Map<String, dynamic>? _handleJoin(WebSocketChannel socket, Map<String, dynamic> data, RoomManager manager) {
  final roomId = data['roomId'] as String;
  final playerId = data['playerId'] as String;
  final alias = data['alias'] as String;
  final avatar = data['avatar'] as String? ?? 'default';
  
  // Check if player is already in another room and remove them
  final existingRoom = manager.findRoomWithPlayer(playerId);
  if (existingRoom != null && existingRoom.id != roomId) {
    print('[Server] Player $playerId found in another room ${existingRoom.id}, removing...');
    existingRoom.removePlayer(playerId);
    
    // Only remove the existing room if it becomes empty
    if (existingRoom.players.isEmpty) {
      manager.removeRoom(existingRoom.id);
    }
  }

  final room = manager.getRoom(roomId);
  if (room == null) {
    socket.sink.add(jsonEncode({
      'type': 'ERROR',
      'message': 'Room not found',
    }));
    return null;
  }

  final player = Player(
    id: playerId,
    alias: alias,
    avatar: avatar,
    socket: socket,
  );

  room.addPlayer(player);

  socket.sink.add(jsonEncode({
    'type': 'JOINED',
    'roomId': roomId,
    'playerId': playerId,
  }));

  return {'player': player, 'room': room};
}

Middleware _corsHeaders() {
  return (Handler innerHandler) {
    return (Request request) async {
      final response = await innerHandler(request);
      return response.change(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept',
      });
    };
  };
}
