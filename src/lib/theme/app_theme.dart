import 'package:flutter/material.dart';

enum AppThemeStyle {
  neoBrutalist,
  classic,
  glassmorphism,
  claymorphism,
  skeuomorphism,
}

class AppTheme {

  // Neo-Brutalist Color Palette (Light)
  static const Color primary = Color(0xFF8B5CF6); // Violet
  static const Color secondary = Color(0xFF10B981); // Emerald
  static const Color accent = Color(0xFFF59E0B); // Amber
  static const Color success = Color(0xFF10B981); 
  static const Color warning = Color(0xFFEF4444); // Red
  static const Color background = Color(0xFFF3F4F6); // Cool Gray
  static const Color surface = Colors.white;
  static const Color text = Colors.black;
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Color(0xFF6B7280); // Gray
  static const Color error = Color(0xFFEF4444); 
  static const Color border = Colors.black;

  // Dark Mode Palette
  static const Color darkBackground = Colors.black;
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkText = Colors.white;
  static const Color darkBorder = Colors.white;

  // Shadows
  static List<BoxShadow> get hardShadow => [
        const BoxShadow(
          color: Colors.black,
          offset: Offset(4, 4),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ];
  
  static List<BoxShadow> get smallHardShadow => [
        const BoxShadow(
          color: Colors.black,
          offset: Offset(2, 2),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.black,
        onError: Colors.white,
      ),
      textTheme: _buildTextTheme(text),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: text,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'LexendMega',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: text,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        iconTheme: IconThemeData(color: text),
        shape: Border(bottom: BorderSide(color: border, width: 3)),
      ),
      elevatedButtonTheme: _buildElevatedButtonTheme(border, Colors.white),
      inputDecorationTheme: _buildInputDecorationTheme(surface, border, text),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: darkSurface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onError: Colors.black,
      ),
      textTheme: _buildTextTheme(darkText),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'LexendMega',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkText,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        iconTheme: IconThemeData(color: darkText),
        shape: Border(bottom: BorderSide(color: darkBorder, width: 3)),
      ),
      elevatedButtonTheme: _buildElevatedButtonTheme(darkBorder, Colors.white), // Keep text white on primary button
      inputDecorationTheme: _buildInputDecorationTheme(darkSurface, darkBorder, darkText),
    );
  }

  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'LexendMega',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
        inherit: false,
        textBaseline: TextBaseline.alphabetic,
      ),
      displayMedium: TextStyle(
        fontFamily: 'LexendMega',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
        inherit: false,
        textBaseline: TextBaseline.alphabetic,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'SpaceMono',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: textColor,
        inherit: false,
        textBaseline: TextBaseline.alphabetic,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'SpaceMono',
        fontSize: 14,
        color: textColor,
        inherit: false,
        textBaseline: TextBaseline.alphabetic,
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(Color borderColor, Color textColor) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: textColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontFamily: 'LexendMega',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor, width: 3),
        ),
      ).copyWith(
         shadowColor: WidgetStateProperty.all(Colors.transparent), 
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(Color fillColor, Color borderColor, Color textColor) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.all(16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 3),
      ),
      labelStyle: TextStyle(
        fontFamily: 'SpaceMono',
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      hintStyle: TextStyle(
        fontFamily: 'SpaceMono',
        color: textColor.withOpacity(0.5),
      ),
    );
  }


  // ==================== SKEUOMORPHISM THEME ====================

  static ThemeData get skeuoLightTheme {
    const textColor = Color(0xFF2D3748); // Gray 800
    const primary = Color(0xFF3182CE); // Blue 500
    const background = Color(0xFFE2E8F0); // Gray 200
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: Color(0xFFDD6B20), // Orange 500
        surface: Color(0xFFEDF2F7), // Gray 100
        background: background,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textColor,
        onBackground: textColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'LexendMega',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
          shadows: [
            Shadow(offset: Offset(1, 1), blurRadius: 0, color: Colors.white),
          ],
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFEDF2F7),
        elevation: 4,
        shadowColor: const Color(0xFFCBD5E0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white, width: 1),
        ),
        margin: const EdgeInsets.all(16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: primary.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          textStyle: const TextStyle(
            fontFamily: 'LexendMega',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            inherit: false,
            textBaseline: TextBaseline.alphabetic,
            shadows: [
              Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black26),
            ],
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFEDF2F7),
        contentPadding: const EdgeInsets.all(20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCBD5E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
        hintStyle: TextStyle(color: textColor.withOpacity(0.4)),
      ),
      textTheme: _buildSkeuoTextTheme(textColor),
    );
  }

  static ThemeData get skeuoDarkTheme {
    const textColor = Color(0xFFE2E8F0); // Gray 200
    const primary = Color(0xFF63B3ED); // Blue 300
    const background = Color(0xFF1A202C); // Gray 900
    const surface = Color(0xFF2D3748); // Gray 800
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: Color(0xFFF6AD55), // Orange 300
        surface: surface,
        background: background,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: textColor,
        onBackground: textColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'LexendMega',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
          shadows: [
            Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black),
          ],
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 4,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
        margin: const EdgeInsets.all(16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          elevation: 6,
          shadowColor: primary.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          textStyle: const TextStyle(
            fontFamily: 'LexendMega',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            inherit: false,
            textBaseline: TextBaseline.alphabetic,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2D3748),
        contentPadding: const EdgeInsets.all(20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4A5568), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
        hintStyle: TextStyle(color: textColor.withOpacity(0.4)),
      ),
      textTheme: _buildSkeuoTextTheme(textColor),
    );
  }

  static TextTheme _buildSkeuoTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'LexendMega',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
        inherit: false,
        textBaseline: TextBaseline.alphabetic,
        shadows: [
          Shadow(offset: Offset(1, 1), blurRadius: 2, color: textColor.withOpacity(0.3)),
        ],
      ),
      displayMedium: TextStyle(
        fontFamily: 'LexendMega',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
        inherit: false,
        textBaseline: TextBaseline.alphabetic,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
        inherit: false,
        textBaseline: TextBaseline.alphabetic,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        color: textColor,
        inherit: false,
        textBaseline: TextBaseline.alphabetic,
      ),
    );
  }

  // ==================== CLAYMORPHISM THEME ====================

  static ThemeData get clayLightTheme {
    const textColor = Color(0xFF4B5563); // Gray 600
    const primary = Color(0xFFFF8A65); // Deep Orange 300
    const background = Color(0xFFFFF7ED); // Orange 50
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: Color(0xFF4ADE80), // Green 400
        surface: Colors.white,
        background: background,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textColor,
        onBackground: textColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'LexendMega',
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: textColor,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 10,
        shadowColor: Color(0xFFFDBA74), // Sombra naranja suave
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        margin: const EdgeInsets.all(16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: primary.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          textStyle: const TextStyle(
            fontFamily: 'LexendMega',
            fontSize: 18,
            fontWeight: FontWeight.w900,
            inherit: false,
            textBaseline: TextBaseline.alphabetic,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: TextStyle(color: textColor.withOpacity(0.7), fontWeight: FontWeight.bold),
        hintStyle: TextStyle(color: textColor.withOpacity(0.4)),
      ),
      textTheme: _buildClayTextTheme(textColor),
    );
  }

  static ThemeData get clayDarkTheme {
    const textColor = Color(0xFFE5E7EB); // Gray 200
    const primary = Color(0xFFF87171); // Red 400
    const background = Color(0xFF374151); // Gray 700
    const surface = Color(0xFF4B5563); // Gray 600
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: Color(0xFF34D399), // Emerald 400
        surface: surface,
        background: background,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textColor,
        onBackground: textColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'LexendMega',
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: textColor,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        margin: const EdgeInsets.all(16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          textStyle: const TextStyle(
            fontFamily: 'LexendMega',
            fontSize: 18,
            fontWeight: FontWeight.w900,
            inherit: false,
            textBaseline: TextBaseline.alphabetic,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.all(24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: TextStyle(color: textColor.withOpacity(0.7), fontWeight: FontWeight.bold),
        hintStyle: TextStyle(color: textColor.withOpacity(0.4)),
      ),
      textTheme: _buildClayTextTheme(textColor),
    );
  }

  static TextTheme _buildClayTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'LexendMega',
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: textColor,
        inherit: false,
        textBaseline: TextBaseline.alphabetic,
      ),
      displayMedium: TextStyle(
        fontFamily: 'LexendMega',
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: textColor,
        inherit: false,
        textBaseline: TextBaseline.alphabetic,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'LexendMega',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: textColor,
        inherit: false,
        textBaseline: TextBaseline.alphabetic,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'LexendMega',
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textColor,
        inherit: false,
        textBaseline: TextBaseline.alphabetic,
      ),
    );
  }

  // ==================== GLASSMORPHISM THEME ====================

  static ThemeData get glassLightTheme {
    const textColor = Color(0xFF1F2937); // Gray 800
    const primary = Color(0xFF8B5CF6); // Violet
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFE0E7FF), // Indigo 100 - Fondo vibrante
      primaryColor: primary,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: const Color(0xFFEC4899), // Pink
        surface: const Color(0x50FFFFFF), // Vidrio transparente (30%)
        background: const Color(0xFFE0E7FF),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textColor,
        onBackground: textColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0x30FFFFFF), // Vidrio muy transparente
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'LexendMega',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      cardTheme: CardThemeData(
        color: const Color(0x40FFFFFF), // Vidrio transparente
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.6), width: 1.5), // Borde brillante
        ),
        margin: const EdgeInsets.all(12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary.withOpacity(0.9),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          textStyle: const TextStyle(
            fontFamily: 'LexendMega',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            inherit: false,
            textBaseline: TextBaseline.alphabetic,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x30FFFFFF),
        contentPadding: const EdgeInsets.all(20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primary.withOpacity(0.7), width: 2),
        ),
        labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
        hintStyle: TextStyle(color: textColor.withOpacity(0.4)),
      ),
      textTheme: _buildGlassTextTheme(textColor),
    );
  }

  static ThemeData get glassDarkTheme {
    const textColor = Colors.white;
    const primary = Color(0xFFA78BFA); // Violet 400
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900 - Fondo profundo
      primaryColor: primary,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: const Color(0xFFF472B6), // Pink 400
        surface: const Color(0x1FFFFFFF), // Blanco muy transparente (12%)
        background: const Color(0xFF0F172A),
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: textColor,
        onBackground: textColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0x10FFFFFF),
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'LexendMega',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      cardTheme: CardThemeData(
        color: const Color(0x1AFFFFFF), // 10% blanco
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        margin: const EdgeInsets.all(12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary.withOpacity(0.8),
          foregroundColor: Colors.black,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          textStyle: const TextStyle(
            fontFamily: 'LexendMega',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            inherit: false,
            textBaseline: TextBaseline.alphabetic,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x1AFFFFFF),
        contentPadding: const EdgeInsets.all(20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primary.withOpacity(0.5), width: 2),
        ),
        labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
        hintStyle: TextStyle(color: textColor.withOpacity(0.4)),
      ),
      textTheme: _buildGlassTextTheme(textColor),
    );
  }

  static TextTheme _buildGlassTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'LexendMega',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
        inherit: false,
        textBaseline: TextBaseline.alphabetic,
        shadows: [
          Shadow(
            color: textColor.withOpacity(0.1),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      displayMedium: TextStyle(
        fontFamily: 'LexendMega',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
        inherit: false,
        textBaseline: TextBaseline.alphabetic,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        color: textColor,
        inherit: false,
        textBaseline: TextBaseline.alphabetic,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        color: textColor,
        inherit: false,
        textBaseline: TextBaseline.alphabetic,
      ),
    );
  }

  // ==================== CLASSIC THEME ====================

  static ThemeData getTheme(AppThemeStyle style, Brightness brightness) {
    switch (style) {
      case AppThemeStyle.skeuomorphism:
        return brightness == Brightness.dark ? skeuoDarkTheme : skeuoLightTheme;
      case AppThemeStyle.claymorphism:
        return brightness == Brightness.dark ? clayDarkTheme : clayLightTheme;
      case AppThemeStyle.glassmorphism:
        return brightness == Brightness.dark ? glassDarkTheme : glassLightTheme;
      case AppThemeStyle.classic:
        return brightness == Brightness.dark ? classicDarkTheme : classicLightTheme;
      case AppThemeStyle.neoBrutalist:
      default:
        return brightness == Brightness.dark ? darkTheme : lightTheme;
    }
  }

  static ThemeData get classicLightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: const Color(0xFF1976D2), // Blue
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF1976D2),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            inherit: false,
            textBaseline: TextBaseline.alphabetic,
          ),
        ),
      ),
      textTheme: _buildClassicTextTheme(Colors.black87),
    );
  }

  static ThemeData get classicDarkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: const Color(0xFF1976D2),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            inherit: false,
            textBaseline: TextBaseline.alphabetic,
          ),
        ),
      ),
      textTheme: _buildClassicTextTheme(Colors.white),
    );
  }

  static TextTheme _buildClassicTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
        inherit: false,
        textBaseline: TextBaseline.alphabetic,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
        inherit: false,
        textBaseline: TextBaseline.alphabetic,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        color: textColor,
        inherit: false,
        textBaseline: TextBaseline.alphabetic,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        color: textColor,
        inherit: false,
        textBaseline: TextBaseline.alphabetic,
      ),
    );
  }
}


