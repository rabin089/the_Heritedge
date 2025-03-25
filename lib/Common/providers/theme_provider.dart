import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Default theme mode

  ThemeMode get themeMode => _themeMode; // Getter

  // Getter to check if the current theme is dark mode
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Toggle between light and dark mode
  void toggleTheme() {
    _themeMode = (_themeMode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notify UI to update
  }
}