import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/carta.dart';
import '../widgets/carta_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/sound_manager.dart';

class CardThemeScreen extends StatefulWidget {
  const CardThemeScreen({super.key});

  @override
  State<CardThemeScreen> createState() => _CardThemeScreenState();
}

class _CardThemeScreenState extends State<CardThemeScreen> {
  String _selectedTheme = 'moderno'; // Default theme
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTheme = prefs.getString('tema_cartas') ?? 'moderno';
      _isLoading = false;
    });
  }

  Future<void> _saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tema_cartas', theme);
    setState(() {
      _selectedTheme = theme;
    });

    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tema guardado: ${theme == 'clasico' ? 'Clásico' : 'Moderno'}',
            style: const TextStyle(fontFamily: 'SpaceMono'),
          ),
          backgroundColor: AppTheme.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Sample card for preview
  Carta get _sampleCard => Carta(
        multiplicaciones: [
          [3, 7],
          [10, 4],
          [6, 6]
        ],
        division: [24, 8],
        resultados: [21, 40, 36],
      );

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'ESTILO DE CARTA',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            SoundManager().playMenuButton();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Instructions
            Text(
              'Selecciona tu estilo de carta preferido',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Theme: Moderno
            _buildThemeOption(
              theme: 'moderno',
              title: 'Tema Moderno',
              description: 'Diseño basado en círculos interconectados con colores vibrantes',
            ),
            const SizedBox(height: 40),

            // Theme: Clasico
            _buildThemeOption(
              theme: 'clasico',
              title: 'Tema Clásico',
              description: 'Diseño tipo grid con líneas divisorias',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required String theme,
    required String title,
    required String description,
  }) {
    final isSelected = _selectedTheme == theme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _saveTheme(theme),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? AppTheme.success 
                : (isDark ? AppTheme.darkBorder : AppTheme.border),
            width: isSelected ? 4 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.success.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppTheme.smallHardShadow,
        ),
        child: Column(
          children: [
            // Title with selection indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.success,
                    size: 28,
                  ),
                if (isSelected) const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isSelected ? AppTheme.success : Theme.of(context).textTheme.titleLarge?.color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Card Preview
            Center(
              child: CartaWidget(
                carta: _sampleCard,
                tema: theme,
                width: 200,
                height: 270,
                isVisible: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
