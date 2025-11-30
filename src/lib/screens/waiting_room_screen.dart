import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/game_provider.dart';
import '../providers/online_game_provider.dart';

class WaitingRoomScreen extends StatefulWidget {
  const WaitingRoomScreen({super.key});

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  Timer? _timer;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      final provider = Provider.of<GameProvider>(context, listen: false);
      await provider.checkGameStatus();
      
      // Cuando la partida está en curso, conectar al servidor
      if (provider.currentPartida?.estado == 'en_curso' && mounted && !_isConnecting) {
        timer.cancel();
        _isConnecting = true;
        await _connectToServerAndJoinRoom();
      }
    });
  }

  Future<void> _connectToServerAndJoinRoom() async {
    if (!mounted) return;
    
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final onlineProvider = Provider.of<OnlineGameProvider>(context, listen: false);
    final partida = gameProvider.currentPartida;
    final user = gameProvider.currentUser;
    
    if (partida == null || user == null) return;

    try {
      // Conectar al servidor
      final connected = await onlineProvider.connectToServer();
      if (!connected || !mounted) return;

      // Crear la sala si soy creador
      if (partida.creadorId == user.id) {
        onlineProvider.createOnlineRoom(
          partida.id,
          partida.nombre,
          partida.numJugadoresObjetivo,
        );
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Unirse a la sala
      onlineProvider.joinRoom(partida.id, user.id, user.alias);
      
      // Esperar a que TODOS los jugadores se unan
      debugPrint('[WaitingRoom] Esperando a que todos se unan al servidor...');
      int waitAttempts = 0;
      while (waitAttempts < 20 && mounted) {
        await Future.delayed(const Duration(milliseconds: 300));
        // Verificar que hay el número correcto de jugadores en el servidor
        if (onlineProvider.players.length >= partida.numJugadoresObjetivo) {
          debugPrint('[WaitingRoom] Todos los jugadores conectados (${onlineProvider.players.length}/${partida.numJugadoresObjetivo})');
          break;
        }
        waitAttempts++;
      }
      
      // Solo el creador inicia el juego
      if (partida.creadorId == user.id && mounted) {
        debugPrint('[WaitingRoom] Creador iniciando juego...');
        await Future.delayed(const Duration(milliseconds: 300)); // Pequeño delay extra
        onlineProvider.startOnlineGame();
      }
      
      // TODOS esperan a que el servidor inicie el juego (status = 'playing')
      debugPrint('[WaitingRoom] Esperando a que el servidor inicie el juego...');
      int attempts = 0;
      while (attempts < 20 && mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (onlineProvider.gameStatus == 'playing') {
          debugPrint('[WaitingRoom] Juego iniciado, navegando a GameScreen');
          break;
        }
        attempts++;
      }
      
      // Navegar a la pantalla de juego
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/game');
      }
    } catch (e) {
      debugPrint('[WaitingRoom] Error connecting to server: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al conectar: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final partida = gameProvider.currentPartida;

    if (partida == null) {
      return const Scaffold(
        body: Center(child: Text("Error: No hay partida seleccionada")),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "SALA DE ESPERA",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // TODO: Implement leave game logic properly
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Game Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.border, 
                  width: 3
                ),
                boxShadow: AppTheme.hardShadow,
              ),
              child: Column(
                children: [
                  Text(
                    partida.nombre,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoBadge(
                        context,
                        Icons.people,
                        "${partida.jugadores.length}/${partida.numJugadoresObjetivo}",
                      ),
                      const SizedBox(width: 16),
                      _buildInfoBadge(
                        context,
                        Icons.star,
                        "${partida.ratingMin}-${partida.ratingMax}",
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Players List
            Text(
              "JUGADORES UNIDOS",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: partida.jugadores.length,
                itemBuilder: (context, index) {
                  final jugador = partida.jugadores[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppTheme.darkBorder : AppTheme.border, 
                        width: 2
                      ),
                      boxShadow: AppTheme.smallHardShadow,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.primary,
                          child: Text(
                            jugador.alias.isNotEmpty ? jugador.alias.substring(0, 1).toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          jugador.id == gameProvider.currentUser?.id 
                              ? '${jugador.alias} (Tú)' 
                              : jugador.alias,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const Spacer(),
                        if (jugador.id == partida.creadorId)
                          const Icon(Icons.star, color: AppTheme.accent),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Status Message (Replaces Start Button)
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.secondary),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2)
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "Esperando jugadores... (${partida.jugadores.length}/${partida.numJugadoresObjetivo})",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
               "La partida comenzará automáticamente cuando se llene.",
               style: TextStyle(
                 fontStyle: FontStyle.italic, 
                 fontSize: 12,
                 color: Theme.of(context).textTheme.bodyMedium?.color
               ),
               textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(BuildContext context, IconData icon, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.border
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
