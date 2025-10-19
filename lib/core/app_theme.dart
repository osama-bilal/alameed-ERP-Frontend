import 'package:flutter/material.dart';

class AppTheme {
  // --- Color Palette ---
  static final Color _lightBlueAccent = Colors.lightBlueAccent;
  static final Color _grey350 = Colors.grey[350]!;
  static final Color _white = Colors.white;
  static final Color _black = Colors.black;

  // --- Main Theme Data ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: "Noto Sans Arabic",

      // --- Color Scheme ---
      // The creative touch starts here, defining how colors are used semantically.
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: _lightBlueAccent,
        onPrimary: _white,
        secondary: _lightBlueAccent.withValues(alpha: 0.8),
        onSecondary: _white,
        error: Colors.redAccent,
        onError: _white,
        surface: _grey350, // App background (now using surface)
        onSurface: _black, // Text on background (now using onSurface)
        surfaceContainer: _white, // Card, Dialog, Sheet backgrounds
        surfaceTint: _lightBlueAccent,
      ),

      // --- Component Themes ---
      scaffoldBackgroundColor: _grey350,

      appBarTheme: AppBarTheme(
        backgroundColor: _white,
        foregroundColor: _black, // For back button and action icons
        elevation: 1,
        shadowColor: Colors.black26,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: "Noto Sans Arabic",
          color: _black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      cardTheme: CardThemeData(
        color: _white, // Explicitly white for cards to stand out
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightBlueAccent,
          foregroundColor: _white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: "Noto Sans Arabic",
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _lightBlueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          textStyle: const TextStyle(
            fontFamily: "Noto Sans Arabic",
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: _lightBlueAccent, width: 2.0),
        ),
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: _white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
