import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/postgres_service.dart';
import '../theme/app_theme.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final PostgresService _postgresService = PostgresService();
  List<Usuario> _usuarios = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRanking();
  }

  Future<void> _loadRanking() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final usuarios = await _postgresService.getRankingGlobal(limit: 100);
      setState(() {
        _usuarios = usuarios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar el ranking: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Ranking Global',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadRanking,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_usuarios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: AppTheme.secondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay jugadores en el ranking',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRanking,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _usuarios.length,
        itemBuilder: (context, index) {
          final usuario = _usuarios[index];
          final posicion = index + 1;
          
          return _buildRankingItem(usuario, posicion);
        },
      ),
    );
  }

  Widget _buildRankingItem(Usuario usuario, int posicion) {
    Color? borderColor;
    IconData? medalIcon;
    Color? medalColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colores especiales para los top 3
    if (posicion == 1) {
      borderColor = const Color(0xFFFFD700); // Oro
      medalIcon = Icons.workspace_premium;
      medalColor = const Color(0xFFFFD700);
    } else if (posicion == 2) {
      borderColor = const Color(0xFFC0C0C0); // Plata
      medalIcon = Icons.workspace_premium;
      medalColor = const Color(0xFFC0C0C0);
    } else if (posicion == 3) {
      borderColor = const Color(0xFFCD7F32); // Bronce
      medalIcon = Icons.workspace_premium;
      medalColor = const Color(0xFFCD7F32);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? (isDark ? AppTheme.darkBorder : AppTheme.border),
          width: posicion <= 3 ? 3 : 2,
        ),
        boxShadow: AppTheme.smallHardShadow,
      ),
      child: Row(
        children: [
          // Posición
          SizedBox(
            width: 40,
            child: medalIcon != null
                ? Icon(medalIcon, color: medalColor, size: 32)
                : Text(
                    '$posicion',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 24,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(width: 16),
          
          // Avatar circular
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primary,
            child: Text(
              usuario.alias.isNotEmpty ? usuario.alias[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Información del jugador
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usuario.alias,
                  style: Theme.of(context).textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  '${usuario.victorias}V / ${usuario.derrotas}D',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),
          
          // Rating
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.border, 
                width: 2
              ),
            ),
            child: Text(
              '${usuario.rating}',
              style: const TextStyle(
                fontFamily: 'LexendMega',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
