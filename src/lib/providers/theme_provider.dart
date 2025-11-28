import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // Default to light if system is not explicit, or handle in UI
      return false; 
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode');
    if (isDark != null) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    } else {
      _themeMode = ThemeMode.light; // Default explicit light
    }
    notifyListeners();
  }

  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  void syncFromUser(bool isDark) {
    if (isDarkMode != isDark) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('isDarkMode', isDark);
      });
    }
  }
}
