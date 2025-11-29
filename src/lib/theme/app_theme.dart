import 'package:flutter/material.dart';

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

  // ==================== CLASSIC THEME ====================

  static ThemeData getTheme(AppThemeStyle style, Brightness brightness) {
    switch (style) {
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

enum AppThemeStyle {
  neoBrutalist,
  classic,
}
