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
      } else if (styleString == 'glassmorphism') {
        _themeStyle = AppThemeStyle.glassmorphism;
      } else if (styleString == 'claymorphism') {
        _themeStyle = AppThemeStyle.claymorphism;
      } else if (styleString == 'skeuomorphism') {
        _themeStyle = AppThemeStyle.skeuomorphism;
      } else {
        _themeStyle = AppThemeStyle.neoBrutalist;
      }
    }
    
    _variableFontSize = prefs.getBool('variableFontSize') ?? true;
    _musicEnabled = prefs.getBool('musicEnabled') ?? true;
    _soundEffectsEnabled = prefs.getBool('soundEffectsEnabled') ?? true;
    _backgroundMusic = prefs.getString('backgroundMusic') ?? 'M.1.mp3';
    
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
    String styleStr = 'neo_brutalista';
    if (style == AppThemeStyle.classic) styleStr = 'clasico';
    else if (style == AppThemeStyle.glassmorphism) styleStr = 'glassmorphism';
    else if (style == AppThemeStyle.claymorphism) styleStr = 'claymorphism';
    else if (style == AppThemeStyle.skeuomorphism) styleStr = 'skeuomorphism';
    
    await prefs.setString('themeStyle', styleStr);
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
    AppThemeStyle newStyle = AppThemeStyle.neoBrutalist;
    if (themeInterface == 'clasico' || themeInterface == 'classic') {
      newStyle = AppThemeStyle.classic;
    } else if (themeInterface == 'glassmorphism') {
      newStyle = AppThemeStyle.glassmorphism;
    } else if (themeInterface == 'claymorphism') {
      newStyle = AppThemeStyle.claymorphism;
    } else if (themeInterface == 'skeuomorphism') {
      newStyle = AppThemeStyle.skeuomorphism;
    }
        
    if (_themeStyle != newStyle) {
      _themeStyle = newStyle;
      changed = true;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('themeStyle', themeInterface);
      });
    }
    
    if (changed) notifyListeners();
  }

  // Game Settings
  bool _variableFontSize = true;
  bool _musicEnabled = true;
  bool _soundEffectsEnabled = true;
  String _backgroundMusic = 'M.1.mp3'; // Default background music

  bool get variableFontSize => _variableFontSize;
  bool get musicEnabled => _musicEnabled;
  bool get soundEffectsEnabled => _soundEffectsEnabled;
  String get backgroundMusic => _backgroundMusic;

  void toggleVariableFontSize() async {
    _variableFontSize = !_variableFontSize;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('variableFontSize', _variableFontSize);
  }
  
  void toggleMusic() async {
    _musicEnabled = !_musicEnabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('musicEnabled', _musicEnabled);
  }
  
  void toggleSoundEffects() async {
    _soundEffectsEnabled = !_soundEffectsEnabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEffectsEnabled', _soundEffectsEnabled);
  }
  
  void setBackgroundMusic(String musicFile) async {
    _backgroundMusic = musicFile;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('backgroundMusic', musicFile);
  }
}
