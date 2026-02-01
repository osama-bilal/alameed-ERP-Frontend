import 'package:flutter/material.dart';
import '/core/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = AppTheme.currentTheme;

  ThemeMode get themeMode => _themeMode;

  ThemeData get themeData =>
      _themeMode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme;

  void setTheme(ThemeMode themeMode) {
    if (_themeMode != themeMode) {
      _themeMode = themeMode;
      AppTheme.setTheme(
        themeMode,
      ); // Keep static theme in sync if used elsewhere
      notifyListeners();
    }
  }
}
