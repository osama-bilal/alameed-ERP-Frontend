import 'package:flutter/material.dart';

class AppTheme {
  // --- Color Palette ---
  static final Color _lightBlueAccent = Colors.lightBlueAccent;
  static final Color _grey350 = Colors.grey[350]!;
  static final Color _white = Colors.white;
  static final Color _black = Colors.black;

  // --- Dark Color Palette ---
  static final Color _darkGrey = Color(0xFF212121); // Main dark background
  static final Color _darkSurface = Color(
    0xFF303030,
  ); // For cards, dialogs, etc.
  static final Color _offWhite = Colors.grey[300]!;
  static ThemeMode currentTheme = ThemeMode.light;
  
  static ThemeData get theme {
    if (currentTheme == ThemeMode.dark) {
      return darkTheme;
    }
    return lightTheme;
  }

  static void setTheme(ThemeMode theme) {
    currentTheme = theme;
  }

  // --- Main Theme Data ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamilyFallback: [
        "Roboto",
        "Noto Sans Symbols",
        "Noto Sans Arabic",
        "Noto Color Emoji",
        "Noto Sans Symbols 2 3",
      ],
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
          alignment: Alignment.center,
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

  // --- Dark Theme Data ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamilyFallback: [
        "Roboto",
        "Noto Sans Symbols",
        "Noto Sans Arabic",
        "Noto Color Emoji",
        "Noto Sans Symbols 2 3",
      ],
      // --- Color Scheme ---
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: _lightBlueAccent,
        onPrimary: _black,
        secondary: _lightBlueAccent.withValues(alpha: 0.7),
        onSecondary: _black,
        error: Colors.redAccent,
        onError: _white,
        surface: _darkSurface, // App background (now using surface)
        onSurface: _offWhite, // Text on background (now using onSurface)
        surfaceContainer: _darkSurface, // Card, Dialog, Sheet backgrounds
        surfaceTint: _lightBlueAccent,
      ),
      // --- Component Themes ---
      scaffoldBackgroundColor: _darkGrey,
      appBarTheme: AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: _offWhite, // For back button and action icons
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: "Noto Sans Arabic",
          color: _offWhite,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightBlueAccent,
          foregroundColor: _black, // Darker text on light blue button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: "Noto Sans Arabic",
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
          alignment: Alignment.center,
          textStyle: const TextStyle(
            fontFamily: "Noto Sans Arabic",
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: _lightBlueAccent, width: 2.0),
        ),
        hintStyle: TextStyle(color: Colors.grey[600]),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
