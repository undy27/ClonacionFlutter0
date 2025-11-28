import 'package:flutter/material.dart';
import '../models/partida.dart';
import '../services/game_logic.dart';
import '../models/carta.dart';
import '../models/usuario.dart';
import '../services/postgres_service.dart';

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
  
  List<Partida> get partidas => _partidas;
  Partida? get currentPartida => _currentPartida;
  List<Carta> get mano => _mano;
  List<Carta> get mazoRestante => _mazoRestante;
  List<List<Carta>> get montonesDescarte => _montonesDescarte;
  List<Carta> get cartasDescartadas => _cartasDescartadas;
  Usuario? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadPartidasDisponibles() async {
    try {
      final partidas = await PostgresService().getPartidasDisponibles();
      _partidas.clear();
      _partidas.addAll(partidas);
      notifyListeners();
    } catch (e) {
      print("Error loading games: $e");
    }
  }

  void updateUser(Usuario? user) {
    _currentUser = user;
    // notifyListeners(); // Avoid loops if called from build
  }

  Future<bool> createPartida(String nombre, int jugadores, int minRating, int maxRating) async {
    if (_currentUser == null) {
      print("Error: No user logged in");
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final currentUserId = _currentUser!.id;
      
      // 1. Check if user already has an active game
      final activeGame = await PostgresService().getPartidaActivaByUsuario(currentUserId);
      if (activeGame != null) {
         print("Leaving previous game: ${activeGame.id} (${activeGame.estado}) to create new one.");
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
    } catch (e) {
      print("Error creating game: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> joinPartida(String partidaId) async {
    print("GameProvider.joinPartida called for $partidaId by ${_currentUser?.id}");
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
      print("Error joining game: $e");
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
        _initializeLocalGame();
        return true;
      }
      return false;
    } catch (e) {
      print("Error starting game: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _initializeLocalGame() {
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
             
             print("Game full! Creator: ${updatedPartida.creadorId}, Me: ${_currentUser!.id}");

             // Any player can trigger the start now, DB handles concurrency
             print("Game is full, attempting to start game...");
             await startPartida();
        } 
        // If game became 'en_curso' (started by someone else or us), init local
        else if (wasWaiting && updatedPartida.estado == 'en_curso') {
             print("Game started! Initializing local game...");
             _initializeLocalGame();
        }
      }
    } catch (e) {
      print("Error checking game status: $e");
    }
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
