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
    if (players.length < maxPlayers && status == GameStatus.waiting) {
      players.add(player);
      print('[Room $id] Player ${player.alias} joined (${players.length}/$maxPlayers)');
      _broadcastGameState();
    }
  }

  void removePlayer(String playerId) {
    players.removeWhere((p) => p.id == playerId);
    print('[Room $id] Player $playerId left (${players.length} remaining)');
    if (players.isEmpty) {
      print('[Room $id] Empty room, should be cleaned up');
    } else {
      _broadcastGameState();
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
      
      // Las primeras 5 cartas van a la mano visible (boca arriba)
      player.hand = _drawCards(5);
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
    
    if (cardIndex < 0 || cardIndex >= player.hand.length) {
      _sendError(player, 'Índice de carta inválido');
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

    Card cardToPlay = player.hand[cardIndex];
    Card topCard = discardPiles[pileIndex].last;

    // Validar si el descarte es válido
    bool isValid = CardValidator.canPlayCard(cardToPlay, topCard);

    if (!isValid) {
      print('[Room $id] ${player.alias} attempted INVALID discard on pile $pileIndex');
      player.penalties++;
      _sendError(player, 'Descarte inválido');
      _broadcastGameState(); // Broadcast para actualizar penalizaciones
      return;
    }

    // Obtener detalles del match para animaciones
    final matchDetails = CardValidator.getMatchDetails(cardToPlay, topCard);

    // Descarte válido
    Card card = player.hand.removeAt(cardIndex);
    discardPiles[pileIndex].add(card);

    print('[Room $id] ${player.alias} played VALID card on pile $pileIndex');

    // Enviar evento de carta jugada para animaciones
    _broadcastCardPlayed(player, card, pileIndex, matchDetails);

    // Voltear una carta del mazo personal si hay
    if (player.personalDeck.isNotEmpty) {
      Card newCard = player.personalDeck.removeAt(0);
      player.hand.add(newCard);
      print('[Room $id] ${player.alias} drew card from personal deck (${player.personalDeck.length} remaining)');
    }

    // Verificar si el jugador ganó (sin cartas en mano Y sin mazo personal)
    if (player.hand.isEmpty && player.personalDeck.isEmpty) {
      _endGame(playerId);
      return;
    }

    _broadcastGameState();
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
    final player = players.firstWhere((p) => p.id == playerId, orElse: () => throw Exception('Player not found'));
    
    if (remainingDeck.isEmpty) {
      _sendError(player, 'No hay más cartas en el mazo');
      return;
    }

    List<Card> drawn = _drawCards(1);
    player.hand.addAll(drawn);
    
    print('[Room $id] ${player.alias} drew a card');
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
      'status': status.toString().split('.').last,
      'players': players.map((p) => {
        'id': p.id,
        'alias': p.alias,
        'handSize': p.hand.length,
        'personalDeckSize': p.personalDeck.length,
        'penalties': p.penalties,
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
