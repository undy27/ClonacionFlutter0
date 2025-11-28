import 'package:flutter/material.dart';
import '../models/partida.dart';
import '../theme/app_theme.dart';

class PartidaListItem extends StatelessWidget {
  final Partida partida;
  final VoidCallback onTap;

  const PartidaListItem({
    super.key,
    required this.partida,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border, width: 2),
          boxShadow: AppTheme.smallHardShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  partida.nombre,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  "Creado por: ${partida.creadorId}", // In a real app, resolve to alias
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${partida.jugadoresIds.length}/${partida.numJugadoresObjetivo}",
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 18),
                ),
                Text(
                  "Avg Rating: 1500", // Placeholder
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
