import 'package:web_socket_channel/web_socket_channel.dart';
import 'card.dart';

// Representa un jugador en una partida
class Player {
  final String id; // Usuario ID
  final String alias;
  final String avatar;
  final WebSocketChannel socket;
  
  List<Card> hand = []; // Cartas visibles (máximo 5)
  List<Card> personalDeck = []; // Cartas boca abajo del jugador
  int penalties = 0;
  bool hasShoutedUno = false;

  Player({
    required this.id,
    required this.alias,
    required this.avatar,
    required this.socket,
  });

  Map<String, dynamic> toJson({bool includeHand = false}) => {
    'id': id,
    'alias': alias,
    'avatar': avatar,
    'handSize': hand.length,
    'personalDeckSize': personalDeck.length,
    'penalties': penalties,
    if (includeHand) 'hand': hand.map((c) => c.toJson()).toList(),
  };
}
