import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/websocket_service.dart';
import '../models/carta.dart';
import '../models/usuario.dart';
import '../config/server_config.dart';
import 'package:http/http.dart' as http;

enum OnlineGameMode { offline, online }

class OnlineGameProvider with ChangeNotifier {
  final WebSocketService _wsService = WebSocketService();
  
  OnlineGameMode _mode = OnlineGameMode.offline;
  String? _currentRoomId;
  Usuario? _currentUser;
  
  // Game state from server
  List<Carta?> _myHand = [];
  List<List<Carta>> _discardPiles = [[], [], [], []];
  List<PlayerInfo> _players = [];
  int _remainingDeckSize = 0;
  int _maxPlayers = 4;
  String _gameStatus = 'waiting';
  
  bool _isConnecting = false;
  String? _errorMessage;
  bool _isEliminated = false;
  Map<String, dynamic>? _winner;
  
  StreamSubscription? _gameStateSubscription;
  StreamSubscription? _messageSubscription;

  // Stream controller for card played events (animations)
  final _cardPlayedController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get cardPlayedStream => _cardPlayedController.stream;

  final _penaltyController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get penaltyStream => _penaltyController.stream;

  final _gameOverController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get gameOverStream => _gameOverController.stream;

  // Getters
  OnlineGameMode get mode => _mode;
  bool get isOnline => _mode == OnlineGameMode.online;
  bool get isConnected => _wsService.status == ConnectionStatus.connected;
  bool get isConnecting => _isConnecting;
  String? get errorMessage => _errorMessage;
  String? get currentRoomId => _currentRoomId;
  
  List<Carta?> get myHand => _myHand;
  List<List<Carta>> get discardPiles => _discardPiles;
  List<PlayerInfo> get players => _players;
  int get remainingDeckSize => _remainingDeckSize;
  int get maxPlayers => _maxPlayers;
  String get gameStatus => _gameStatus;
  Usuario? get currentUser => _currentUser;
  bool get isEliminated => _isEliminated;
  Map<String, dynamic>? get winner => _winner;
  
  OnlineGameProvider() {
    _setupListeners();
  }

  void _setupListeners() {
    // Listen for game state updates
    _gameStateSubscription = _wsService.gameStateUpdates.listen((state) {
      _myHand = state.myHand;
      _discardPiles = state.discardPiles;
      _players = state.players;
      _remainingDeckSize = state.remainingDeckSize;
      _maxPlayers = state.maxPlayers;
      _gameStatus = state.status;
      _currentRoomId = state.roomId;
      
      debugPrint('[OnlineGameProvider] Game state updated: ${state.players.length} players, ${_myHand.length} cards in hand');
      debugPrint('[OnlineGameProvider] Players list: ${_players.map((p) => "${p.alias}(${p.handSize}+${p.personalDeckSize})").toList()}');
      debugPrint('[OnlineGameProvider] Discard piles: ${_discardPiles.map((p) => p.length).toList()}');
      notifyListeners();
    });

    // Listen for other messages
    _messageSubscription = _wsService.messages.listen((message) {
      final type = message['type'] as String;
      
      switch (type) {
        case 'ROOM_CREATED':
          _currentRoomId = message['roomId'] as String;
          debugPrint('[OnlineGameProvider] Room created: $_currentRoomId');
          
          // Auto-join the room we just created
          if (_currentUser != null) {
            debugPrint('[OnlineGameProvider] Auto-joining created room');
            joinRoom(_currentRoomId!, _currentUser!.id, _currentUser!.alias);
          }
          notifyListeners();
          break;
          
        case 'JOINED':
          _currentRoomId = message['roomId'] as String;
          debugPrint('[OnlineGameProvider] Joined room: $_currentRoomId');
          notifyListeners();
          break;
          
        case 'CARD_PLAYED':
          debugPrint('[OnlineGameProvider] Received CARD_PLAYED event');
          _cardPlayedController.add(message);
          break;
          
        case 'PENALTY':
          debugPrint('[OnlineGameProvider] Received PENALTY event');
          _penaltyController.add(message);
          break;
          
        case 'ERROR':
          _errorMessage = message['message'] as String;
          debugPrint('[OnlineGameProvider] Server error: $_errorMessage');
          
          // Retrocompatibilidad/Robustez: Si el servidor envía ERROR por descarte inválido, tratarlo como penalización
          if (_errorMessage != null && _errorMessage!.contains('Descarte inválido')) {
            _penaltyController.add({
              'playerId': _currentUser?.id, // Error message is sent to the specific player socket
              'message': _errorMessage
            });
          }
          
          notifyListeners();
          break;
          
        case 'ELIMINATED':
          _isEliminated = true;
          _errorMessage = message['message'] as String;
          debugPrint('[OnlineGameProvider] Eliminated: $_errorMessage');
          notifyListeners();
          break;

        case 'GAME_OVER':
          final winner = message['winner'] as Map<String, dynamic>;
          _winner = winner;
          _gameStatus = 'finished';
          debugPrint('[OnlineGameProvider] Game over! Winner: ${winner['alias']}');
          _gameOverController.add(message);
          notifyListeners();
          break;
      }
    });
  }

  void setUser(Usuario? user) {
    _currentUser = user;
  }

  Future<bool> connectToServer() async {
    if (isConnected) return true;
    
    _isConnecting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final useInternet = _currentUser?.useInternetServer ?? true;
      await _wsService.connect(ServerConfig.getGameServerUrl(useInternet));
      _mode = OnlineGameMode.online;
      _isConnecting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al conectar: $e';
      _isConnecting = false;
      notifyListeners();
      return false;
    }
  }

  void createOnlineRoom(String roomId, String roomName, int maxPlayers) {
    if (!isConnected || _currentUser == null) {
      _errorMessage = 'Debes estar conectado y autenticado';
      notifyListeners();
      return;
    }

    _wsService.createRoom(roomId, roomName, maxPlayers);
  }

  void joinRoom(String roomId, String playerId, String alias) {
    print('[OnlineGameProvider] joinRoom: roomId=$roomId, isConnected=$isConnected, _currentUser is ${_currentUser != null ? "set (id=${_currentUser!.id}, alias=${_currentUser!.alias})" : "null"}');
    if (!isConnected || _currentUser == null) {
      _errorMessage = 'Debes estar conectado y autenticado';
      notifyListeners();
      return;
    }

    print('[OnlineGameProvider] Joining room $roomId with avatar: ${_currentUser!.avatar}');
    _wsService.joinRoom(roomId, _currentUser!.id, _currentUser!.alias, _currentUser!.avatar);
  }

  void startOnlineGame() {
    if (!isConnected) return;
    _wsService.startGame();
  }

  void playCard(int cardIndex, int pileIndex) {
    if (!isConnected) return;
    _wsService.playCard(cardIndex, pileIndex);
  }

  void drawCard() {
    if (!isConnected) return;
    _wsService.drawCard();
  }

  void leaveRoom() {
    _currentRoomId = null;
    _myHand.clear();
    _discardPiles = [[], [], [], []];
    _players.clear();
    _players.clear();
    _gameStatus = 'waiting';
    _isEliminated = false;
    _winner = null;
    notifyListeners();
  }

  void disconnect() {
    _wsService.disconnect();
    _mode = OnlineGameMode.offline;
    leaveRoom();
  }

  List<Map<String, dynamic>> _availableRooms = [];
  List<Map<String, dynamic>> get availableRooms => _availableRooms;

  Future<void> fetchRooms() async {
    try {
      final useInternet = _currentUser?.useInternetServer ?? true;
      final baseUrl = ServerConfig.getBaseUrl(useInternet);
      final response = await http.get(Uri.parse('$baseUrl/rooms'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newRooms = List<Map<String, dynamic>>.from(data['rooms']);
        
        // Simple comparison to avoid unnecessary notifies
        if (jsonEncode(newRooms) != jsonEncode(_availableRooms)) {
          _availableRooms = newRooms;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error fetching rooms: $e');
    }
  }

  @override
  void dispose() {
    _gameStateSubscription?.cancel();
    _messageSubscription?.cancel();
    _cardPlayedController.close();
    _wsService.disconnect();
    super.dispose();
  }
}
