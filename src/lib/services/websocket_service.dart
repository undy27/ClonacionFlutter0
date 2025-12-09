import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/carta.dart';

enum ConnectionStatus { disconnected, connecting, connected, error }

class GameStateUpdate {
  final String roomId;
  final String status;
  final List<PlayerInfo> players;
  final List<Carta?> myHand;
  final List<List<Carta>> discardPiles;
  final int remainingDeckSize;
  final int maxPlayers;

  GameStateUpdate({
    required this.roomId,
    required this.status,
    required this.players,
    required this.myHand,
    required this.discardPiles,
    required this.remainingDeckSize,
    required this.maxPlayers,
  });

  factory GameStateUpdate.fromJson(Map<String, dynamic> json) {
    return GameStateUpdate(
      roomId: json['roomId'] as String,
      status: json['status'] as String,
      players: (json['players'] as List)
          .map((p) => PlayerInfo.fromJson(p))
          .toList(),
      myHand: (json['myHand'] as List)
          .map((c) => c != null ? Carta.fromJson(c) : null)
          .toList(),
      discardPiles: (json['discardPiles'] as List)
          .map((pile) => (pile as List)
              .map((c) => Carta.fromJson(c))
              .toList())
          .toList(),
      remainingDeckSize: json['remainingDeckSize'] as int,
      maxPlayers: (json['maxPlayers'] as int?) ?? 4, // Default 4 si no viene
    );
  }
}

class PlayerInfo {
  final String id;
  final String alias;
  final String? avatar;
  final int handSize;
  final int personalDeckSize;
  final int penalties;

  PlayerInfo({
    required this.id,
    required this.alias,
    this.avatar,
    required this.handSize,
    this.personalDeckSize = 0, // Default 0 si no está presente
    required this.penalties,
  });

  factory PlayerInfo.fromJson(Map<String, dynamic> json) {
    return PlayerInfo(
      id: json['id'] as String,
      alias: json['alias'] as String,
      avatar: json['avatar'] as String?,
      handSize: json['handSize'] as int,
      personalDeckSize: (json['personalDeckSize'] as int?) ?? 0, // Null-safe
      penalties: json['penalties'] as int,
    );
  }
}

class WebSocketService extends ChangeNotifier {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  ConnectionStatus _status = ConnectionStatus.disconnected;
  String? _errorMessage;
  
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _gameStateController = StreamController<GameStateUpdate>.broadcast();

  ConnectionStatus get status => _status;
  String? get errorMessage => _errorMessage;
  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  Stream<GameStateUpdate> get gameStateUpdates => _gameStateController.stream;

  Future<void> connect(String serverUrl) async {
    if (_status == ConnectionStatus.connected || _status == ConnectionStatus.connecting) {
      debugPrint('[WebSocketService] Already connected or connecting');
      return;
    }

    _status = ConnectionStatus.connecting;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('[WebSocketService] Connecting to $serverUrl');
      _channel = WebSocketChannel.connect(Uri.parse(serverUrl));

      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onDone: () {
          debugPrint('[WebSocketService] Connection closed');
          _status = ConnectionStatus.disconnected;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('[WebSocketService] Error: $error');
          _status = ConnectionStatus.error;
          _errorMessage = error.toString();
          notifyListeners();
        },
      );

      _status = ConnectionStatus.connected;
      debugPrint('[WebSocketService] Connected successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('[WebSocketService] Connection failed: $e');
      _status = ConnectionStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final type = data['type'] as String;

      debugPrint('[WebSocketService] Received: $type');

      // Broadcast raw message
      _messageController.add(data);

      // Handle specific message types
      switch (type) {
        case 'GAME_STATE':
          final state = GameStateUpdate.fromJson(data['state']);
          _gameStateController.add(state);
          break;
        case 'ERROR':
          debugPrint('[WebSocketService] Server error: ${data['message']}');
          break;
        case 'GAME_OVER':
          debugPrint('[WebSocketService] Game over: ${data['winner']}');
          break;
      }
    } catch (e) {
      debugPrint('[WebSocketService] Error parsing message: $e');
    }
  }

  void send(Map<String, dynamic> message) {
    if (_status != ConnectionStatus.connected) {
      debugPrint('[WebSocketService] Cannot send, not connected');
      return;
    }

    try {
      final encoded = jsonEncode(message);
      _channel?.sink.add(encoded);
      debugPrint('[WebSocketService] Sent: ${message['type']}');
    } catch (e) {
      debugPrint('[WebSocketService] Error sending message: $e');
    }
  }

  // High-level methods for game actions
  void createRoom(String roomId, String roomName, int maxPlayers) {
    send({
      'type': 'CREATE_ROOM',
      'roomId': roomId,
      'roomName': roomName,
      'maxPlayers': maxPlayers,
    });
  }

  void joinRoom(String roomId, String playerId, String alias, String avatar) {
    print('[WebSocketService] Sending JOIN: alias=$alias, avatar=$avatar');
    send({
      'type': 'JOIN',
      'roomId': roomId,
      'playerId': playerId,
      'alias': alias,
      'avatar': avatar,
    });
  }

  void startGame() {
    send({'type': 'START_GAME'});
  }

  void playCard(int cardIndex, int pileIndex) {
    send({
      'type': 'PLAY_CARD',
      'cardIndex': cardIndex,
      'pileIndex': pileIndex,
    });
  }

  void drawCard(int slotIndex) {
    send({'type': 'DRAW_CARD', 'slotIndex': slotIndex});
  }

  void disconnect() {
    debugPrint('[WebSocketService] Disconnecting');
    _channel?.sink.close();
    _channel = null;
    _status = ConnectionStatus.disconnected;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    _messageController.close();
    _gameStateController.close();
    super.dispose();
  }
}
