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
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final playerCount = room['players'] as int;
              final maxPlayers = room['maxPlayers'] as int;
              final isFull = playerCount >= maxPlayers;
              final fillPercentage = playerCount / maxPlayers;
              
              return GestureDetector(
                onTap: isFull ? null : () async {
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
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppTheme.darkBorder : AppTheme.border,
                      width: 3,
                    ),
                    boxShadow: AppTheme.hardShadow,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Name and status badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                room['name'] ?? 'Sala sin nombre',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            // Delete button if user is creator
                            if (room['creatorId'] == provider.currentUser?.id)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Eliminar partida'),
                                      content: const Text('¿Estás seguro de que quieres eliminar esta partida?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                                          child: const Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                                  );
                                  
                                  if (confirmed == true) {
                                    await provider.deleteRoom(room['id']);
                                  }
                                },
                                tooltip: 'Eliminar partida',
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isFull ? Colors.red : AppTheme.secondary,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isFull ? Colors.red[700]! : AppTheme.secondary[700]!,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                isFull ? 'LLENA' : 'ABIERTA',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Player count with visual bar
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.primary,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.people,
                                color: AppTheme.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '$playerCount',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                      Text(
                                        ' / $maxPlayers',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'jugadores',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  // Player fill bar
                                  Stack(
                                    children: [
                                      Container(
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.grey[800] : Colors.grey[300],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      FractionallySizedBox(
                                        widthFactor: fillPercentage,
                                        child: Container(
                                          height: 8,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppTheme.primary,
                                                AppTheme.secondary,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Rating requirement with colorful badge
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.withOpacity(0.2),
                                Colors.orange.withOpacity(0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.amber,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.emoji_events,
                                color: Colors.amber.shade700,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Rating requerido: ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
                              Text(
                                '${room['minRating']} - ${room['maxRating']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        if (!isFull) ...[
                          const SizedBox(height: 12),
                          // Join button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.login,
                                size: 16,
                                color: AppTheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Toca para unirte',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: AppTheme.primary,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
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
