import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = "app_theme";
  static const String _accentKey = "accent_color";

  Future<void> saveThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? true; // default dark
  }

  Future<void> saveAccentColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentKey, colorValue);
  }

  Future<int> getAccentColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_accentKey) ?? 0xFFFF9800;
  }
}