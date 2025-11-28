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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partida.nombre,
                    style: Theme.of(context).textTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    "Creado por: ${partida.jugadores.firstWhere((j) => j.id == partida.creadorId, orElse: () => partida.jugadores.first).alias}",
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${partida.jugadores.length}/${partida.numJugadoresObjetivo}",
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 18,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
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
