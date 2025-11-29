import 'package:flutter/material.dart';
import '../models/partida.dart';
import '../services/game_logic.dart';
import '../models/carta.dart';
import '../models/usuario.dart';
import '../services/postgres_service.dart';

class MatchDetails {
  final List<int> matchedMults; // Indices 0, 1, 2
  final bool matchedDiv;
  final List<int> matchedResults; // Indices 0, 1, 2
  
  MatchDetails({
    this.matchedMults = const [], 
    this.matchedDiv = false, 
    this.matchedResults = const []
  });
  
  bool get hasMatch => matchedMults.isNotEmpty || matchedDiv || matchedResults.isNotEmpty;
}

class GameProvider with ChangeNotifier {
  final List<Partida> _partidas = [];
  Partida? _currentPartida;
  Usuario? _currentUser;
  
  List<Carta> _baraja = [];
  // For simplicity, just managing local player state for now
  List<Carta> _mano = [];
  List<Carta> _mazoRestante = [];
  List<List<Carta>> _montonesDescarte = [[], [], [], []];
  List<Carta> _cartasDescartadas = []; // Cartas que el jugador ha descartado exitosamente (historial personal)
  
  // Store match details for the top card of each discard pile
  final Map<int, MatchDetails> _lastMatchDetails = {};
  
  List<Partida> get partidas => _partidas;
  Partida? get currentPartida => _currentPartida;
  List<Carta> get mano => _mano;
  List<Carta> get mazoRestante => _mazoRestante;
  List<List<Carta>> get montonesDescarte => _montonesDescarte;
  List<Carta> get cartasDescartadas => _cartasDescartadas;
  Usuario? get currentUser => _currentUser;
  
  MatchDetails? getLastMatchDetails(int montonIndex) => _lastMatchDetails[montonIndex];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadPartidasDisponibles() async {
    try {
      final partidas = await PostgresService().getPartidasDisponibles();
      _partidas.clear();
      _partidas.addAll(partidas);
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading games: $e");
    }
  }

  void updateUser(Usuario? user) {
    _currentUser = user;
    // notifyListeners(); // Avoid loops if called from build
  }

  Future<bool> createPartida(String nombre, int jugadores, int minRating, int maxRating) async {
    if (_currentUser == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final currentUserId = _currentUser!.id;
      
      // 1. Check if user already has an active game
      final activeGame = await PostgresService().getPartidaActivaByUsuario(currentUserId);
      if (activeGame != null) {
         await PostgresService().leavePartida(activeGame.id, currentUserId);
      }

      final uuid = DateTime.now().millisecondsSinceEpoch.toString();

      final newPartida = await PostgresService().createPartida(
        id: uuid,
        nombre: nombre,
        creadorId: currentUserId,
        numJugadoresObjetivo: jugadores,
        ratingMin: minRating,
        ratingMax: maxRating,
      );

      if (newPartida != null) {
        _currentPartida = newPartida;
        _partidas.insert(0, newPartida);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      debugPrint("GameProvider.createPartida: Error creating game: $e");
      debugPrint("GameProvider.createPartida: StackTrace: $stackTrace");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> joinPartida(String partidaId) async {
    if (_currentUser == null) return false;
    
    _isLoading = true;
    notifyListeners();

    try {
      final success = await PostgresService().joinPartida(partidaId, _currentUser!.id);
      if (success) {
        final partida = await PostgresService().getPartidaById(partidaId);
        if (partida != null) {
          _currentPartida = partida;
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("Error joining game: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startPartida() async {
    if (_currentPartida == null) return false;
    
    _isLoading = true;
    notifyListeners();

    try {
      // Try to start in DB
      final success = await PostgresService().startPartida(_currentPartida!.id);
      
      if (success) {
        // Force update local state immediately so UI reacts
        final updated = await PostgresService().getPartidaById(_currentPartida!.id);
        
        if (updated != null) {
            _currentPartida = updated;
        }
        
        _initializeLocalGame();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("GameProvider.startPartida: Error starting game: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _initializeLocalGame() {
        try {
          // Initialize game logic locally
          _baraja = GameLogic.generarBaraja();
          
          _cartasDescartadas = [];
          
          // Deal cards (Mock logic for now, should be synchronized)
          _montonesDescarte = [
             [_baraja[48]],
             [_baraja[49]],
             [_baraja[50]],
             [_baraja[51]],
          ];
          
          _mano = _baraja.sublist(0, 5);
          _mazoRestante = _baraja.sublist(5, 24); 
          
          notifyListeners();
        } catch (e, stackTrace) {
          debugPrint('_initializeLocalGame: ERROR - $e');
          debugPrint('_initializeLocalGame: StackTrace - $stackTrace');
          rethrow;
        }
  }

  Future<void> checkGameStatus() async {
    if (_currentPartida == null || _currentUser == null) return;

    try {
      final updatedPartida = await PostgresService().getPartidaById(_currentPartida!.id);
      if (updatedPartida != null) {
        bool wasWaiting = _currentPartida!.estado == 'esperando';
        _currentPartida = updatedPartida;
        notifyListeners();

        // Auto-start if full and we are the creator
        if (updatedPartida.estado == 'esperando' && 
            updatedPartida.jugadores.length >= updatedPartida.numJugadoresObjetivo) {
             
             // Any player can trigger the start now, DB handles concurrency
             await startPartida();
        } 
        // If game became 'en_curso' (started by someone else or us), init local
        else if (wasWaiting && updatedPartida.estado == 'en_curso') {
             _initializeLocalGame();
        }
      }
    } catch (e) {
      debugPrint("Error checking game status: $e");
    }
  }

  bool intentarDescarte(Carta cartaMano, int montonIndex) {
      Carta cartaMonton = _montonesDescarte[montonIndex].last;
      
      MatchDetails details = _calculateMatchDetails(cartaMano, cartaMonton);
      
      if (details.hasMatch) {
          _montonesDescarte[montonIndex].add(cartaMano);
          _mano.remove(cartaMano);
          _cartasDescartadas.add(cartaMano); // Track personal discard history
          _lastMatchDetails[montonIndex] = details; // Store details for animation
          
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

  MatchDetails _calculateMatchDetails(Carta mano, Carta monton) {
      List<int> matchedMults = [];
      bool matchedDiv = false;
      List<int> matchedResults = [];
      
      // 1. Top(Mano) vs Top(Monton)
      for(int i=0; i<mano.multiplicaciones.length; i++) {
          var pm = mano.multiplicaciones[i];
          for(var pmd in monton.multiplicaciones) {
              if ((pm[0]*pm[1] == pmd[0]*pmd[1]) && 
                  !((pm[0]==pmd[0] && pm[1]==pmd[1]) || (pm[0]==pmd[1] && pm[1]==pmd[0]))) {
                  matchedMults.add(i);
              }
          }
      }
      
      // 2. Top(Mano) vs Mid(Monton)
      double divMonton = monton.division[0] / monton.division[1];
      for(int i=0; i<mano.multiplicaciones.length; i++) {
           var pm = mano.multiplicaciones[i];
           if (pm[0]*pm[1] == divMonton) matchedMults.add(i);
      }

      // 3. Top(Mano) vs Bot(Monton)
      for(int i=0; i<mano.multiplicaciones.length; i++) {
          var pm = mano.multiplicaciones[i];
          for(var res in monton.resultados) {
              if (pm[0]*pm[1] == res) matchedMults.add(i);
          }
      }

      // 4. Bot(Mano) vs Top(Monton)
      for(int i=0; i<mano.resultados.length; i++) {
          var res = mano.resultados[i];
          for(var pmd in monton.multiplicaciones) {
              if (res == pmd[0]*pmd[1]) matchedResults.add(i);
          }
      }

      // 5. Mid(Mano) vs Top(Monton)
      double divMano = mano.division[0] / mano.division[1];
       for(var pmd in monton.multiplicaciones) {
           if (divMano == pmd[0]*pmd[1]) matchedDiv = true;
       }

      // 6. Mid(Mano) vs Bot(Monton)
      for(var res in monton.resultados) {
          if (divMano == res) matchedDiv = true;
      }

      // 7. Bot(Mano) vs Mid(Monton)
      for(int i=0; i<mano.resultados.length; i++) {
          var res = mano.resultados[i];
          if (res == divMonton) matchedResults.add(i);
      }

      // 8. Mid(Mano) vs Mid(Monton)
      if (divMano == divMonton) matchedDiv = true;
      
      // 9. Bot(Mano) vs Bot(Monton) (Added for completeness)
      for(int i=0; i<mano.resultados.length; i++) {
          var resMano = mano.resultados[i];
          for(var resMonton in monton.resultados) {
              if (resMano == resMonton) matchedResults.add(i);
          }
      }

      return MatchDetails(
        matchedMults: matchedMults.toSet().toList(),
        matchedDiv: matchedDiv,
        matchedResults: matchedResults.toSet().toList(),
      );
  }

}
