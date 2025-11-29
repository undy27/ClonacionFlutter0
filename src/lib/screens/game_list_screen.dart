import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/partida_list_item.dart';
import '../widgets/create_game_dialog.dart';
import '../theme/app_theme.dart';

class GameListScreen extends StatefulWidget {
  const GameListScreen({super.key});

  @override
  State<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _refreshList();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _refreshList());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _refreshList() {
    if (mounted) {
      Provider.of<GameProvider>(context, listen: false).loadPartidasDisponibles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Partidas"),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          if (gameProvider.isLoading && gameProvider.partidas.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (gameProvider.partidas.isEmpty) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.games_outlined, size: 64, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                   const SizedBox(height: 16),
                   Text(
                     "No hay partidas disponibles.\n¡Crea una nueva!",
                     textAlign: TextAlign.center,
                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
                       color: Theme.of(context).textTheme.bodyMedium?.color
                     ),
                   ),
                 ],
               ),
             );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: gameProvider.partidas.length,
            itemBuilder: (context, index) {
              final partida = gameProvider.partidas[index];
              return PartidaListItem(
                partida: partida,
                onTap: () async {
                   print("Tapped on game: ${partida.id}");
                   final success = await gameProvider.joinPartida(partida.id);
                   if (success && mounted) {
                      Navigator.pushNamed(context, '/waiting_room');
                   } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Error al unirse a la partida"),
                          backgroundColor: AppTheme.error,
                        ),
                      );
                   }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Capture the screen context before showing dialog
          final screenContext = context;
          
          showDialog(
            context: context,
            builder: (context) => CreateGameDialog(
              onCreate: (nombre, jugadores, minRating, maxRating) async {
                print('GameListScreen: onCreate called');
                final success = await Provider.of<GameProvider>(screenContext, listen: false)
                    .createPartida(nombre, jugadores, minRating, maxRating);
                
                print('GameListScreen: createPartida returned success=$success, screenContext.mounted=${screenContext.mounted}');
                
                if (success && screenContext.mounted) {
                  print('GameListScreen: Navigating to /waiting_room');
                  Navigator.of(screenContext).pushNamed('/waiting_room');
                  print('GameListScreen: Navigation called');
                } else if (screenContext.mounted) {
                  print('GameListScreen: Showing error snackbar');
                  ScaffoldMessenger.of(screenContext).showSnackBar(
                    const SnackBar(
                      content: Text("Error al crear la partida"),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                } else {
                  print('GameListScreen: ERROR - screenContext is not mounted!');
                }
                print('GameListScreen: onCreate finished');
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
