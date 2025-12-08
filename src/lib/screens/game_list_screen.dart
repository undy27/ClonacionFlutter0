import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/online_game_provider.dart';
import '../widgets/create_game_dialog.dart';
import '../theme/app_theme.dart';
import '../services/sound_manager.dart';

class GameListScreen extends StatefulWidget {
  const GameListScreen({super.key});

  @override
  State<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  Timer? _timer;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectAndRefresh();
    });
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _refreshList());
  }

  Future<void> _connectAndRefresh() async {
    final provider = Provider.of<OnlineGameProvider>(context, listen: false);
    if (!provider.isConnected) {
      setState(() => _isConnecting = true);
      await provider.connectToServer();
      setState(() => _isConnecting = false);
    }
    _refreshList();
  }

  void _refreshList() {
    if (mounted) {
      final provider = Provider.of<OnlineGameProvider>(context, listen: false);
      // Only fetch if not in a room
      if (provider.currentRoomId == null) {
        provider.fetchRooms();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Partidas Online"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            SoundManager().playMenuButton();
            Navigator.pop(context);
          },
        ),
        actions: [
          Consumer<OnlineGameProvider>(
            builder: (context, provider, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(
                  provider.isConnected ? Icons.wifi : Icons.wifi_off,
                  color: provider.isConnected ? Colors.green : Colors.red,
                ),
              );
            },
          )
        ],
      ),
      body: Consumer<OnlineGameProvider>(
        builder: (context, provider, child) {
          if (_isConnecting || (provider.isConnecting && provider.availableRooms.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          }

          // if (provider.currentRoomId != null) {
          //   // This logic causes infinite navigation loops if GameListScreen is in the stack
          //   // We handle navigation explicitly in onTap and onCreate
          // }
          
          if (provider.availableRooms.isEmpty) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.games_outlined, size: 64, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                   const SizedBox(height: 16),
                   Text(
                     "No hay partidas online disponibles.\n¡Crea una nueva!",
                     textAlign: TextAlign.center,
                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
                       color: Theme.of(context).textTheme.bodyMedium?.color
                     ),
                   ),
                   if (!provider.isConnected)
                     Padding(
                       padding: const EdgeInsets.only(top: 16.0),
                       child: ElevatedButton(
                         onPressed: _connectAndRefresh,
                         child: const Text("Reconectar"),
                       ),
                     ),
                 ],
               ),
             );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.availableRooms.length,
            itemBuilder: (context, index) {
              final room = provider.availableRooms[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    room['name'] ?? 'Sala sin nombre',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    'Jugadores: ${room['players']}/${room['maxPlayers']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    if (provider.isConnected && provider.currentUser != null) {
                      _timer?.cancel(); // Stop polling
                      
                      provider.leaveRoom();
                      provider.joinRoom(
                        room['id'], 
                        provider.currentUser!.id, 
                        provider.currentUser!.alias
                      ); 
                      
                      await Navigator.pushNamed(context, '/waiting_room');
                      
                      // Restart polling when back
                      if (mounted) {
                        _refreshList();
                        _timer = Timer.periodic(const Duration(seconds: 3), (_) => _refreshList());
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("No estás conectado al servidor")),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          SoundManager().playMenuButton();
          final screenContext = context;
          showDialog(
            context: context,
            builder: (context) => CreateGameDialog(
              onCreate: (nombre, jugadores, minRating, maxRating) async {
                final provider = Provider.of<OnlineGameProvider>(screenContext, listen: false);
                if (provider.isConnected) {
                   // Clean up any previous room state
                   provider.leaveRoom();
                   
                   final roomId = DateTime.now().millisecondsSinceEpoch.toString();
                   // createOnlineRoom now auto-joins via ROOM_CREATED handler
                   provider.createOnlineRoom(roomId, nombre, jugadores);
                   
                   // Stop polling
                   _timer?.cancel();
                   
                   // Navigate to waiting room
                   await Navigator.of(screenContext).pushNamed('/waiting_room');
                   
                   //Restart polling when back
                   if (mounted) {
                     _refreshList();
                     _timer = Timer.periodic(const Duration(seconds: 3), (_) => _refreshList());
                   }
                } else {
                   ScaffoldMessenger.of(screenContext).showSnackBar(
                     const SnackBar(content: Text("No estás conectado al servidor")),
                   );
                }
              },
            ),
          );
        },
        backgroundColor: AppTheme.primary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.black, width: 2)
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
