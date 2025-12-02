import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/online_game_provider.dart';
import '../utils/avatar_helper.dart';

class WaitingRoomScreen extends StatefulWidget {
  const WaitingRoomScreen({super.key});

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    // Check game status on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<OnlineGameProvider>(context, listen: false);
      if (provider.gameStatus == 'playing' && !_hasNavigated) {
        _hasNavigated = true;
        Navigator.pushReplacementNamed(context, '/game');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnlineGameProvider>(
      builder: (context, provider, child) {
        // Auto-navigate if game starts
        if (provider.gameStatus == 'playing' && !_hasNavigated) {
           _hasNavigated = true;
           WidgetsBinding.instance.addPostFrameCallback((_) {
             Navigator.pushReplacementNamed(context, '/game');
           });
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final roomId = provider.currentRoomId ?? "Desconocida";
        final players = provider.players;
        final maxPlayers = provider.maxPlayers;

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
                provider.leaveRoom();
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
                        "Sala: $roomId",
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
                            "${players.length}/$maxPlayers",
                          ),
                          const SizedBox(width: 16),
                          _buildInfoBadge(
                            context,
                            Icons.wifi,
                            "Online",
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
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final player = players[index];
                      final isMe = player.id == provider.currentUser?.id;
                      
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
                            Text(
                              isMe ? '${player.alias} (Tú)' : player.alias,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Status Message / Start Button
                const SizedBox(height: 16),
                // Status Message
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
