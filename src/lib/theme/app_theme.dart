import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Neo-Brutalist Color Palette
  static const Color primary = Color(0xFF8B5CF6); // Violet
  static const Color secondary = Color(0xFF10B981); // Emerald
  static const Color accent = Color(0xFFF59E0B); // Amber
  static const Color background = Color(0xFFF3F4F6); // Cool Gray
  static const Color surface = Colors.white;
  static const Color text = Colors.black;
  static const Color error = Color(0xFFEF4444); // Red
  static const Color border = Colors.black;

  // Neo-Brutalist Shadow
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

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
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
      textTheme: GoogleFonts.spaceMonoTextTheme().copyWith(
        displayLarge: GoogleFonts.lexendMega(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: text,
        ),
        displayMedium: GoogleFonts.lexendMega(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: text,
        ),
        bodyLarge: GoogleFonts.spaceMono(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: text,
        ),
        bodyMedium: GoogleFonts.spaceMono(
          fontSize: 14,
          color: text,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: text,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.lexendMega(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: text,
        ),
        iconTheme: const IconThemeData(color: text),
        shape: const Border(bottom: BorderSide(color: border, width: 3)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.lexendMega(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: border, width: 3),
          ),
        ).copyWith(
           shadowColor: WidgetStateProperty.all(Colors.transparent), 
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border, width: 3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 3),
        ),
        labelStyle: GoogleFonts.spaceMono(
          color: text,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
