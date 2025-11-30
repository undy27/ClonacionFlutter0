import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/online_game_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class OnlineGameListScreen extends StatefulWidget {
  const OnlineGameListScreen({super.key});

  @override
  State<OnlineGameListScreen> createState() => _OnlineGameListScreenState();
}

class _OnlineGameListScreenState extends State<OnlineGameListScreen> {
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _connectToServer();
  }

  Future<void> _connectToServer() async {
    final onlineProvider = Provider.of<OnlineGameProvider>(context, listen: false);
    
    if (!onlineProvider.isConnected) {
      setState(() => _isConnecting = true);
      await onlineProvider.connectToServer();
      setState(() => _isConnecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Multijugador Online"),
        actions: [
          Consumer<OnlineGameProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    children: [
                      Icon(
                        provider.isConnected 
                            ? Icons.wifi 
                            : Icons.wifi_off,
                        color: provider.isConnected 
                            ? Colors.green 
                            : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        provider.isConnected ? 'Conectado' : 'Desconectado',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<OnlineGameProvider>(
        builder: (context, onlineProvider, child) {
          if (_isConnecting || onlineProvider.isConnecting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Conectando al servidor...'),
                ],
              ),
            );
          }

          if (!onlineProvider.isConnected) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error al conectar al servidor',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (onlineProvider.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      onlineProvider.errorMessage!,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _connectToServer,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          // If already in a room, show room screen
          if (onlineProvider.currentRoomId != null) {
            return _buildGameRoomView(context, onlineProvider);
          }

          // Show room list/creation
          return _buildRoomListView(context, onlineProvider);
        },
      ),
      floatingActionButton: Consumer<OnlineGameProvider>(
        builder: (context, provider, child) {
          if (!provider.isConnected || provider.currentRoomId != null) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton(
            onPressed: () => _showCreateRoomDialog(context),
            backgroundColor: AppTheme.primary,
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Widget _buildRoomListView(BuildContext context, OnlineGameProvider provider) {
    // TODO: Fetch room list from server
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.gamepad, size: 64),
          const SizedBox(height: 16),
          Text(
            'Partidas Online',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Crea una nueva sala o únete a una existente',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGameRoomView(BuildContext context, OnlineGameProvider provider) {
    final isWaiting = provider.gameStatus == 'waiting';
    final isPlaying = provider.gameStatus == 'playing';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Room header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sala: ${provider.currentRoomId}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (isWaiting)
                        ElevatedButton(
                          onPressed: () => provider.startOnlineGame(),
                          child: const Text('Iniciar Juego'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Estado: ${isWaiting ? "Esperando..." : "Jugando"}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Players list
          Text(
            'Jugadores (${provider.players.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: provider.players.length,
              itemBuilder: (context, index) {
                final player = provider.players[index];
                return Card(
                  color: player.isCurrentPlayer 
                      ? AppTheme.primary.withOpacity(0.2)
                      : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(player.alias[0]),
                    ),
                    title: Text(player.alias),
                    subtitle: Text('${player.handSize} cartas'),
                    trailing: player.isCurrentPlayer
                        ? const Icon(Icons.play_arrow, color: AppTheme.primary)
                        : null,
                  ),
                );
              },
            ),
          ),

          // Game controls
          if (isPlaying) ...[
            const Divider(),
            Text(
              'Turno: ${provider.currentTurn}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (provider.isMyTurn)
              Text(
                '¡Es tu turno!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to game screen
                Navigator.pushNamed(context, '/game');
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Ir al Juego'),
            ),
          ],

          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              provider.leaveRoom();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Salir de la Sala'),
          ),
        ],
      ),
    );
  }

  void _showCreateRoomDialog(BuildContext context) {
    final nameController = TextEditingController();
    int maxPlayers = 4;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Crear Sala Online'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la sala',
                hintText: 'Mi Partida',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: maxPlayers,
              decoration: const InputDecoration(
                labelText: 'Máximo de jugadores',
              ),
              items: [2, 3, 4, 5, 6].map((n) {
                return DropdownMenuItem(
                  value: n,
                  child: Text('$n jugadores'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) maxPlayers = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El nombre no puede estar vacío')),
                );
                return;
              }

              Navigator.pop(dialogContext);
              Provider.of<OnlineGameProvider>(context, listen: false)
                  .createOnlineRoom(name, maxPlayers);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }
}
