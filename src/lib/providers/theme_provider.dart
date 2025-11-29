import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  AppThemeStyle _themeStyle = AppThemeStyle.neoBrutalist;

  ThemeMode get themeMode => _themeMode;
  AppThemeStyle get themeStyle => _themeStyle;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
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
      _themeMode = ThemeMode.light;
    }
    
    final styleString = prefs.getString('themeStyle');
    if (styleString != null) {
      if (styleString == 'clasico' || styleString == 'classic') {
        _themeStyle = AppThemeStyle.classic;
      } else {
        _themeStyle = AppThemeStyle.neoBrutalist;
      }
    }
    
    notifyListeners();
  }

  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  void setThemeStyle(AppThemeStyle style) async {
    _themeStyle = style;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeStyle', style == AppThemeStyle.classic ? 'clasico' : 'neo_brutalista');
  }

  void syncFromUser(bool isDark, String themeInterface) {
    bool changed = false;
    
    // Sync Dark Mode
    if (isDarkMode != isDark) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      changed = true;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('isDarkMode', isDark);
      });
    }
    
    // Sync Theme Style
    AppThemeStyle newStyle = (themeInterface == 'clasico' || themeInterface == 'classic') 
        ? AppThemeStyle.classic 
        : AppThemeStyle.neoBrutalist;
        
    if (_themeStyle != newStyle) {
      _themeStyle = newStyle;
      changed = true;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('themeStyle', themeInterface);
      });
    }
    
    if (changed) notifyListeners();
  }
}
