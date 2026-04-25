import 'package:flutter/material.dart';
import 'package:vyra/services/settings_service.dart';

class ThemeProvider extends ChangeNotifier {
  static final ThemeProvider _instance = ThemeProvider._internal();
  static ThemeProvider get instance => _instance;
  ThemeProvider._internal();

  factory ThemeProvider() => _instance;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  Future<void> loadTheme() async {
    _isDarkMode = await SettingsService().isDarkMode();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await SettingsService().setDarkMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    await SettingsService().setDarkMode(_isDarkMode);
    notifyListeners();
  }
}
