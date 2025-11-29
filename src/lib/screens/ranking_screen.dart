import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/postgres_service.dart';
import '../theme/app_theme.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PostgresService _postgresService = PostgresService();
  
  // Data for Global Ranking
  List<Usuario> _usuariosGlobal = [];
  bool _isLoadingGlobal = true;
  String? _errorGlobal;

  // Data for Records
  List<Usuario> _usuariosRecords = [];
  bool _isLoadingRecords = false;
  String? _errorRecords;
  int _selectedPlayersCount = 2; // 2, 3, or 4

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRankingGlobal();
    _loadRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRankingGlobal() async {
    setState(() {
      _isLoadingGlobal = true;
      _errorGlobal = null;
    });

    try {
      final usuarios = await _postgresService.getRankingGlobal(limit: 100);
      setState(() {
        _usuariosGlobal = usuarios;
        _isLoadingGlobal = false;
      });
    } catch (e) {
      setState(() {
        _errorGlobal = 'Error al cargar el ranking: $e';
        _isLoadingGlobal = false;
      });
    }
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoadingRecords = true;
      _errorRecords = null;
    });

    try {
      final usuarios = await _postgresService.getRecordsTiempo(numJugadores: _selectedPlayersCount);
      setState(() {
        _usuariosRecords = usuarios;
        _isLoadingRecords = false;
      });
    } catch (e) {
      setState(() {
        _errorRecords = 'Error al cargar récords: $e';
        _isLoadingRecords = false;
      });
    }
  }

  String _formatTime(int value) {
    final duration = Duration(seconds: value);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Ranking y Récords',
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
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => SystemSound.play(SystemSoundType.click),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'PUNTUACIONES'),
            Tab(text: 'RÉCORDS TIEMPO'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGlobalRanking(),
          _buildRecordsView(),
        ],
      ),
    );
  }

  Widget _buildGlobalRanking() {
    if (_isLoadingGlobal) {
      return Center(
        child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
      );
    }

    if (_errorGlobal != null) {
      return _buildErrorView(_errorGlobal!, _loadRankingGlobal);
    }

    if (_usuariosGlobal.isEmpty) {
      return _buildEmptyView('No hay jugadores en el ranking');
    }

    return RefreshIndicator(
      onRefresh: _loadRankingGlobal,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _usuariosGlobal.length,
        itemBuilder: (context, index) {
          final usuario = _usuariosGlobal[index];
          final posicion = index + 1;
          return _buildRankingItem(usuario, posicion, isTimeRecord: false);
        },
      ),
    );
  }

  Widget _buildRecordsView() {
    return Column(
      children: [
        // Filter Buttons
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [2, 3, 4].map((count) {
              final isSelected = _selectedPlayersCount == count;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      SystemSound.play(SystemSoundType.click);
                      setState(() {
                        _selectedPlayersCount = count;
                      });
                      _loadRecords();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.secondary : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? AppTheme.secondary : AppTheme.border,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$count Jugadores',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        
        // List
        Expanded(
          child: _buildRecordsList(),
        ),
      ],
    );
  }

  Widget _buildRecordsList() {
    if (_isLoadingRecords) {
      return Center(
        child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
      );
    }

    if (_errorRecords != null) {
      return _buildErrorView(_errorRecords!, _loadRecords);
    }

    if (_usuariosRecords.isEmpty) {
      return _buildEmptyView('No hay récords para $_selectedPlayersCount jugadores');
    }

    return RefreshIndicator(
      onRefresh: _loadRecords,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _usuariosRecords.length,
        itemBuilder: (context, index) {
          final usuario = _usuariosRecords[index];
          final posicion = index + 1;
          return _buildRankingItem(usuario, posicion, isTimeRecord: true);
        },
      ),
    );
  }

  Widget _buildErrorView(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppTheme.error),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_off_outlined,
            size: 64,
            color: AppTheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRankingItem(Usuario usuario, int posicion, {required bool isTimeRecord}) {
    Color? borderColor;
    IconData? medalIcon;
    Color? medalColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (posicion == 1) {
      borderColor = const Color(0xFFFFD700);
      medalIcon = Icons.workspace_premium;
      medalColor = const Color(0xFFFFD700);
    } else if (posicion == 2) {
      borderColor = const Color(0xFFC0C0C0);
      medalIcon = Icons.workspace_premium;
      medalColor = const Color(0xFFC0C0C0);
    } else if (posicion == 3) {
      borderColor = const Color(0xFFCD7F32);
      medalIcon = Icons.workspace_premium;
      medalColor = const Color(0xFFCD7F32);
    }

    // Determine value to display
    String valueDisplay;
    String labelDisplay;
    
    if (isTimeRecord) {
      int? time;
      if (_selectedPlayersCount == 2) time = usuario.mejorTiempoVictoria2j;
      else if (_selectedPlayersCount == 3) time = usuario.mejorTiempoVictoria3j;
      else if (_selectedPlayersCount == 4) time = usuario.mejorTiempoVictoria4j;
      
      valueDisplay = time != null ? _formatTime(time) : '--';
      labelDisplay = 'Tiempo';
    } else {
      valueDisplay = '${usuario.rating}';
      labelDisplay = 'Rating';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          SizedBox(
            width: 30,
            child: medalIcon != null
                ? Icon(medalIcon, color: medalColor, size: 24)
                : Text(
                    '$posicion',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primary,
            child: Text(
              usuario.alias.isNotEmpty ? usuario.alias[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usuario.alias,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  '${usuario.victorias}V / ${usuario.derrotas}D',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isTimeRecord ? AppTheme.secondary : AppTheme.primary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.border, 
                width: 2
              ),
            ),
            child: Column(
              children: [
                Text(
                  valueDisplay,
                  style: const TextStyle(
                    fontFamily: 'LexendMega',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
