import 'dart:convert';
import 'models/card.dart';
import 'models/player.dart';
import 'game_logic.dart';
import 'card_validator.dart';

enum GameStatus { waiting, playing, finished }

class GameRoom {
  final String id;
  final String name;
  final int maxPlayers;
  
  List<Player> players = [];
  GameStatus status = GameStatus.waiting;
  
  // Game state
  List<Card> deck = [];
  List<Card> remainingDeck = [];
  List<List<Card>> discardPiles = [[], [], [], []]; // 4 pilas
  
  GameRoom({
    required this.id,
    required this.name,
    required this.maxPlayers,
  });

  void addPlayer(Player player) {
    // Check if player already exists
    final existingIndex = players.indexWhere((p) => p.id == player.id);
    if (existingIndex != -1) {
      print('[Room $id] Player ${player.alias} reconnected/updated');
      // Update the existing player with the new socket/info
      players[existingIndex] = player;
      _broadcastGameState();
      return;
    }

    if (players.length < maxPlayers && status == GameStatus.waiting) {
      players.add(player);
      print('[Room $id] Player ${player.alias} joined (${players.length}/$maxPlayers)');
      
      if (players.length >= maxPlayers) {
        startGame();
      } else {
        _broadcastGameState();
      }
    }
  }

  void removePlayer(String playerId) {
    // If game is waiting, just remove
    if (status == GameStatus.waiting) {
      players.removeWhere((p) => p.id == playerId);
      print('[Room $id] Player $playerId left (${players.length} remaining)');
      if (players.isEmpty) {
        print('[Room $id] Empty room, should be cleaned up');
      } else {
        _broadcastGameState();
      }
    } 
    // If game is playing, mark as eliminated or handle forfeit
    else if (status == GameStatus.playing) {
      final playerIndex = players.indexWhere((p) => p.id == playerId);
      if (playerIndex != -1) {
        final player = players[playerIndex];
        print('[Room $id] Player ${player.alias} left during game');
        
        // Remove player completely or mark as eliminated?
        // Specs say "Abandona la partida... pierde".
        // If we remove them, we can't show them in the list.
        // But if they disconnected (socket closed), we can't send them messages anyway.
        // Let's remove them from the list to avoid sending messages to closed socket,
        // but check win condition for others.
        
        players.removeAt(playerIndex);
        
        // Check if only 1 player remains
        final activePlayers = players.where((p) => !p.isEliminated).toList();
        if (activePlayers.length == 1) {
           _endGame(activePlayers.first.id);
        } else if (activePlayers.isEmpty) {
           status = GameStatus.finished; // Everyone left
        } else {
           _broadcastGameState();
        }
      }
    }
  }

  void startGame() {
    if (players.length < 2) {
      print('[Room $id] Cannot start game with less than 2 players');
      return;
    }

    print('[Room $id] Starting game with ${players.length} players');
    status = GameStatus.playing;
    
    // Generate deck
    deck = GameLogic.generateDeck();
    remainingDeck = List.from(deck);
    remainingDeck.shuffle();

    // Las 4 primeras cartas van a los montones de descarte (boca arriba)
    for (int i = 0; i < 4; i++) {
      if (remainingDeck.isNotEmpty) {
        discardPiles[i].add(remainingDeck.removeAt(0));
      }
    }

    // Repartir las 48 cartas restantes entre los jugadores
    int cardsPerPlayer = 48 ~/ players.length;
    int remainingCards = 48 % players.length;

    for (var player in players) {
      int cardsForThisPlayer = cardsPerPlayer;
      if (remainingCards > 0) {
        cardsForThisPlayer++;
        remainingCards--;
      }
      
      // Las primeras 5 cartas van a la mano visible (slots 0-4)
      List<Card> initialHand = _drawCards(5);
      for (int i = 0; i < initialHand.length; i++) {
        player.hand[i] = initialHand[i];
      }
      // El resto va al mazo personal (boca abajo)
      player.personalDeck = _drawCards(cardsForThisPlayer - 5);
      
      print('[Room $id] ${player.alias}: ${player.hand.length} visible, ${player.personalDeck.length} face-down');
    }

    print('[Room $id] Remaining deck: ${remainingDeck.length} cards');
    print('[Room $id] Discard piles initialized: ${discardPiles.map((p) => p.length).toList()}');
    _broadcastGameState();
  }

  List<Card> _drawCards(int count) {
    List<Card> drawn = [];
    for (int i = 0; i < count && remainingDeck.isNotEmpty; i++) {
      drawn.add(remainingDeck.removeAt(0));
    }
    return drawn;
  }

  void handlePlayCard(String playerId, int cardIndex, int pileIndex) {
    final player = players.firstWhere((p) => p.id == playerId, orElse: () => throw Exception('Player not found'));
    
    if (player.isEliminated) return;

    if (cardIndex < 0 || cardIndex >= 5) {
      _sendError(player, 'Índice de carta inválido');
      return;
    }

    if (player.hand[cardIndex] == null) {
      _sendError(player, 'Slot de carta vacío');
      return;
    }

    if (pileIndex < 0 || pileIndex >= 4) {
      _sendError(player, 'Índice de pila inválido');
      return;
    }

    if (discardPiles[pileIndex].isEmpty) {
      _sendError(player, 'Montón de descarte vacío (error interno)');
      return;
    }

    Card cardToPlay = player.hand[cardIndex]!; // Ya validamos que no es null
    Card topCard = discardPiles[pileIndex].last;

    // Validar si el descarte es válido
    bool isValid = CardValidator.canPlayCard(cardToPlay, topCard);

    if (!isValid) {
      print('[Room $id] ${player.alias} attempted INVALID discard on pile $pileIndex');
      player.penalties++;
      
        if (player.penalties > 3) {
        _eliminatePlayer(player);
      } else {
        // Calculate penalty duration based on specs: 4s, 6s, 8s
        int duration = 4;
        if (player.penalties == 2) duration = 6;
        if (player.penalties == 3) duration = 8;

        // Send specific PENALTY event so client can play sound and show countdown
        player.socket.sink.add(jsonEncode({
          'type': 'PENALTY',
          'message': 'Descarte inválido',
          'playerId': player.id,
          'penalties': player.penalties,
          'duration': duration
        }));
        _broadcastGameState(); // Broadcast para actualizar penalizaciones
      }
      return;
    }

    // Obtener detalles del match para animaciones
    final matchDetails = CardValidator.getMatchDetails(cardToPlay, topCard);

    // Descarte válido - poner slot a null
    Card card = player.hand[cardIndex]!;
    player.hand[cardIndex] = null;
    discardPiles[pileIndex].add(card);

    print('[Room $id] ${player.alias} played VALID card on pile $pileIndex');

    // Enviar evento de carta jugada para animaciones
    _broadcastCardPlayed(player, card, pileIndex, matchDetails);

    // Robo manual: Ya no se voltea carta automáticamente.
    // El cliente debe solicitar DRAW_CARD.

    // Verificar si el jugador ganó (sin cartas en mano Y sin mazo personal)
    if (player.hand.every((c) => c == null) && player.personalDeck.isEmpty) {
      _endGame(playerId);
      return;
    }

    _broadcastGameState();
  }
  
  void _eliminatePlayer(Player player) {
    player.isEliminated = true;
    print('[Room $id] Player ${player.alias} eliminated (max penalties)');
    
    // Notify player specifically
    player.socket.sink.add(jsonEncode({
      'type': 'ELIMINATED',
      'message': 'Has sido eliminado por exceso de penalizaciones',
    }));
    
    // Check if only 1 player remains active
    final activePlayers = players.where((p) => !p.isEliminated).toList();
    if (activePlayers.length == 1) {
      _endGame(activePlayers.first.id);
    } else {
      _broadcastGameState();
    }
  }

  void _broadcastCardPlayed(Player player, Card card, int pileIndex, Map<String, dynamic> matchDetails) {
    print('[Room $id] Broadcasting CARD_PLAYED event');
    for (var p in players) {
      p.socket.sink.add(jsonEncode({
        'type': 'CARD_PLAYED',
        'playerId': player.id,
        'card': card.toJson(),
        'pileIndex': pileIndex,
        'matchDetails': matchDetails,
      }));
    }
  }

  void handleDrawCard(String playerId) {
    if (status != GameStatus.playing) return;
    
    final player = players.firstWhere((p) => p.id == playerId, orElse: () => throw Exception('Player not found'));
    
    if (player.isEliminated) return;

    // Buscar primer slot vacío
    int? emptySlot;
    for (int i = 0; i < 5; i++) {
      if (player.hand[i] == null) {
        emptySlot = i;
        break;
      }
    }

    if (emptySlot == null) {
       _sendError(player, 'Tu mano está llena');
       return;
    }
    
    if (player.personalDeck.isEmpty) {
       _sendError(player, 'Tu mazo está vacío');
       return;
    }

    Card newCard = player.personalDeck.removeAt(0);
    player.hand[emptySlot] = newCard;
    
    print('[Room $id] ${player.alias} drew card (MANUAL) to slot $emptySlot from personal deck (${player.personalDeck.length} remaining)');
    _broadcastGameState();
  }

  void _broadcastGameState() {
    for (var player in players) {
      final state = _getGameStateForPlayer(player);
      player.socket.sink.add(jsonEncode({
        'type': 'GAME_STATE',
        'state': state,
      }));
    }
  }

  Map<String, dynamic> _getGameStateForPlayer(Player player) {
    return {
      'roomId': id,
      'maxPlayers': maxPlayers,
      'status': status.toString().split('.').last,
      'players': players.map((p) => {
        'id': p.id,
        'alias': p.alias,
        'avatar': p.avatar,
        'handSize': p.hand.length,
        'personalDeckSize': p.personalDeck.length,
        'penalties': p.penalties,
        'isEliminated': p.isEliminated,
      }).toList(),
      'myHand': player.hand.map((c) => c.toJson()).toList(),
      'discardPiles': discardPiles.map((pile) => 
        pile.map((c) => c.toJson()).toList()
      ).toList(),
      'remainingDeckSize': remainingDeck.length,
    };
  }

  void _sendError(Player player, String message) {
    player.socket.sink.add(jsonEncode({
      'type': 'ERROR',
      'message': message,
    }));
  }

  void _endGame(String winnerId) {
    status = GameStatus.finished;
    final winner = players.firstWhere((p) => p.id == winnerId);
    
    print('[Room $id] Game finished! Winner: ${winner.alias}');
    
    for (var player in players) {
      player.socket.sink.add(jsonEncode({
        'type': 'GAME_OVER',
        'winner': {
          'id': winner.id,
          'alias': winner.alias,
        },
      }));
    }
  }
}
