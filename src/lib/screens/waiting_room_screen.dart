import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/online_game_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/avatar_helper.dart';

import '../services/sound_manager.dart';

class WaitingRoomScreen extends StatefulWidget {
  const WaitingRoomScreen({super.key});

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  bool _hasNavigated = false;
  String _randomPhrase = '';

  @override
  void initState() {
    super.initState();
    _loadRandomPhrase();
    
    // Check game status on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<OnlineGameProvider>(context, listen: false);
      if (provider.gameStatus == 'playing' && !_hasNavigated) {
        _hasNavigated = true;
        Navigator.pushReplacementNamed(context, '/game');
      }
    });
  }

  Future<void> _loadRandomPhrase() async {
    try {
      final content = await rootBundle.loadString('assets/textos/frases_sala_espera.md');
      final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
      if (lines.isNotEmpty) {
        final random = Random();
        setState(() {
          _randomPhrase = lines[random.nextInt(lines.length)];
        });
      }
    } catch (e) {
      debugPrint('Error loading phrases: $e');
      setState(() {
        _randomPhrase = 'La práctica hace al maestro';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<OnlineGameProvider, AuthProvider>(
      builder: (context, provider, authProvider, child) {
        // Auto-navigate if game starts
        if (provider.gameStatus == 'playing' && !_hasNavigated) {
           _hasNavigated = true;
           WidgetsBinding.instance.addPostFrameCallback((_) {
             Navigator.pushReplacementNamed(context, '/game');
           });
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final players = provider.players;
        final maxPlayers = provider.maxPlayers;
        final currentUser = authProvider.currentUser;

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
                SoundManager().playMenuButton();
                provider.leaveRoom();
                Navigator.pop(context);
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Players List
                Text(
                  "JUGADORES UNIDOS",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                
                // Players
                ...players.map((player) {
                  final isMe = player.id == provider.currentUser?.id;
                  final rating = isMe ? (currentUser?.rating ?? 1500) : 1500;
                  final wins = isMe ? (currentUser?.victorias ?? 0) : 0;
                  final losses = isMe ? (currentUser?.derrotas ?? 0) : 0;
                  
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
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              AvatarHelper.getAvatarPath(player.avatar ?? 'default', 0),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  player.alias.isNotEmpty ? player.alias[0].toUpperCase() : '?',
                                  style: TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isMe ? '${player.alias} (Tú)' : player.alias,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star, size: 14, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$rating',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(Icons.emoji_events, size: 14, color: Colors.green),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$wins',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(Icons.close, size: 14, color: Colors.red),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$losses',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 32),

                // Sheep animation
                Image.asset(
                  'assets/ovejas/OVEJA-COMIENDO.gif',
                  width: 150,
                  height: 150,
                  errorBuilder: (_, __, ___) => const SizedBox(height: 150),
                ),

                const SizedBox(height: 24),

                // Random phrase
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.5)),
                  ),
                  child: Text(
                    _randomPhrase,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),

                const Spacer(),

                // Status Message
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
                        "Esperando jugadores... (${players.length}/$maxPlayers)",
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
      },
    );
  }
}
