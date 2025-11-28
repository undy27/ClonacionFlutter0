import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/partida_list_item.dart';
import '../theme/app_theme.dart';

class GameListScreen extends StatelessWidget {
  const GameListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Partidas"),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: gameProvider.partidas.length,
            itemBuilder: (context, index) {
              final partida = gameProvider.partidas[index];
              return PartidaListItem(
                partida: partida,
                onTap: () {
                   gameProvider.joinPartida(partida.id);
                   Navigator.pushNamed(context, '/game');
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show dialog to create game
          Provider.of<GameProvider>(context, listen: false).createPartida("Nueva Partida", 2, 0, 3000);
          Navigator.pushNamed(context, '/game');
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
