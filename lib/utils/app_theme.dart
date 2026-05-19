/**
 * Student Numbers: 222093753, 223005951, 221045356, 221032445, 223082890,
 * Student Names  : DM Skitla, KL Boisa, TD Mokoena, KD Hlokoane, SD Tshabalala,
 * Question: app_theme.dart - App-Wide Theme, Colors and Styling Constants
 */

import 'package:flutter/material.dart';

class AppTheme {
  
  static const Color primary    = Color(0xFF1A3C6E);
  static const Color accent     = Color(0xFFF4A732);
  static const Color success    = Color(0xFF2E7D32);
  static const Color danger     = Color(0xFFC62828);
  static const Color pending    = Color(0xFFF57F17);
  static const Color background = Color(0xFFF5F7FA);
  static const Color cardWhite  = Color(0xFFFFFFFF);
  static const Color textDark   = Color(0xFF1C1C1E);
  static const Color textMuted  = Color(0xFF6B7280);

  static ThemeData get lightTheme {
    return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: background,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: primary),
    ),

    // Input Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: danger, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // Cards
  // Cards
   //cardTheme: CardTheme(
//color: Colors.white,
  //elevation: 2,
  //shape: RoundedRectangleBorder(
    //borderRadius: BorderRadius.circular(16),
  //),
//),

    // CheckBox
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? primary : null,
      ),
    ),
  );
  }
}
