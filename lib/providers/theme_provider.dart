import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  Color _accentColor = const Color(0xFF5B67F1);
  ThemeMode _themeMode = ThemeMode.light;

  Color get accentColor => _accentColor;
  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt('accent_color');
    final isDark = prefs.getBool('is_dark') ?? false;

    if (colorValue != null) {
      _accentColor = Color(colorValue);
    }
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setAccentColor(Color color) async {
    _accentColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accent_color', color.value);
    notifyListeners();
  }

  void toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark', _themeMode == ThemeMode.dark);
    notifyListeners();
  }

  LinearGradient get primaryGradient => LinearGradient(
        colors: [
          _accentColor,
          _accentColor.withValues(alpha: 0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
