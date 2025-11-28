import 'package:flutter/material.dart';
import '../models/partida.dart';
import '../services/game_logic.dart';
import '../models/carta.dart';

class GameProvider with ChangeNotifier {
  final List<Partida> _partidas = [];
  Partida? _currentPartida;
  
  List<Carta> _baraja = [];
  // For simplicity, just managing local player state for now
  List<Carta> _mano = [];
  List<Carta> _mazoRestante = [];
  List<List<Carta>> _montonesDescarte = [[], [], [], []];
  List<Carta> _cartasDescartadas = []; // Cartas que el jugador ha descartado exitosamente (historial personal)
  
  List<Partida> get partidas => _partidas;
  Partida? get currentPartida => _currentPartida;
  List<Carta> get mano => _mano;
  List<Carta> get mazoRestante => _mazoRestante;
  List<List<Carta>> get montonesDescarte => _montonesDescarte;
  List<Carta> get cartasDescartadas => _cartasDescartadas;

  void createPartida(String nombre, int jugadores, int minRating, int maxRating) {
    final newPartida = Partida(
      id: DateTime.now().toString(),
      nombre: nombre,
      creadorId: 'user_1', // Mock
      numJugadoresObjetivo: jugadores,
      ratingMin: minRating,
      ratingMax: maxRating,
      jugadoresIds: ['user_1'],
    );
    _partidas.add(newPartida);
    notifyListeners();
  }
  
  void joinPartida(String partidaId) {
     // Mock join
  }

  void startGame() {
     _baraja = GameLogic.generarBaraja();
     _cartasDescartadas = [];
     
     // Mock dealing
     // 48 cards to players (assume 2 players for now -> 24 each? No, 48 total distributed)
     // Specs: "reparten aleatoriamente 48 cartas entre todos los jugadores"
     // "4 cartas restantes... 4 montones"
     
     _montonesDescarte = [
         [_baraja[48]],
         [_baraja[49]],
         [_baraja[50]],
         [_baraja[51]],
     ];
     
     // Deal 5 to hand, 19 to remaining (for 2 players)
     _mano = _baraja.sublist(0, 5);
     _mazoRestante = _baraja.sublist(5, 24); // 19 cards
     
     notifyListeners();
  }

  bool intentarDescarte(Carta cartaMano, int montonIndex) {
      Carta cartaMonton = _montonesDescarte[montonIndex].last;
      
      if (_validarDescarte(cartaMano, cartaMonton)) {
          _montonesDescarte[montonIndex].add(cartaMano);
          _mano.remove(cartaMano);
          _cartasDescartadas.add(cartaMano); // Track personal discard history
          
          if (_mazoRestante.isNotEmpty) {
              _mano.add(_mazoRestante.removeAt(0));
          }
          notifyListeners();
          return true;
      } else {
          // Handle penalty logic
          return false;
      }
  }

  bool _validarDescarte(Carta mano, Carta monton) {
      // Implement all 8 rules
      // 1. Top(Mano) vs Top(Monton)
      for(var pm in mano.multiplicaciones) {
          for(var pmd in monton.multiplicaciones) {
              if ((pm[0]*pm[1] == pmd[0]*pmd[1]) && 
                  !((pm[0]==pmd[0] && pm[1]==pmd[1]) || (pm[0]==pmd[1] && pm[1]==pmd[0]))) {
                  return true;
              }
          }
      }
      
      // 2. Top(Mano) vs Mid(Monton)
      for(var pm in mano.multiplicaciones) {
           double div = monton.division[0] / monton.division[1];
           if (pm[0]*pm[1] == div) return true;
      }

      // 3. Top(Mano) vs Bot(Monton)
      for(var pm in mano.multiplicaciones) {
          for(var res in monton.resultados) {
              if (pm[0]*pm[1] == res) return true;
          }
      }

      // 4. Bot(Mano) vs Top(Monton)
       for(var res in mano.resultados) {
          for(var pmd in monton.multiplicaciones) {
              if (res == pmd[0]*pmd[1]) return true;
          }
      }

      // 5. Mid(Mano) vs Top(Monton)
      double divMano = mano.division[0] / mano.division[1];
       for(var pmd in monton.multiplicaciones) {
           if (divMano == pmd[0]*pmd[1]) return true;
       }

      // 6. Mid(Mano) vs Bot(Monton)
      for(var res in monton.resultados) {
          if (divMano == res) return true;
      }

      // 7. Bot(Mano) vs Mid(Monton)
      double divMonton = monton.division[0] / monton.division[1];
      for(var res in mano.resultados) {
          if (res == divMonton) return true;
      }

      // 8. Mid(Mano) vs Mid(Monton)
      if (divMano == divMonton) return true;

      return false;
  }
}
