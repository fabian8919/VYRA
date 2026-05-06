import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _darkModeKey = 'settings_dark_mode';
  static const String _notificationsKey = 'settings_notifications_enabled';
  static const String _privateProfileKey = 'settings_private_profile';
  static const String _showActivityKey = 'settings_show_activity_status';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Dark mode
  Future<bool> isDarkMode() async {
    final prefs = await _preferences;
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await _preferences;
    await prefs.setBool(_darkModeKey, value);
  }

  // Notifications
  Future<bool> areNotificationsEnabled() async {
    final prefs = await _preferences;
    return prefs.getBool(_notificationsKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await _preferences;
    await prefs.setBool(_notificationsKey, value);
  }

  // Private profile
  Future<bool> isPrivateProfile() async {
    final prefs = await _preferences;
    return prefs.getBool(_privateProfileKey) ?? false;
  }

  Future<void> setPrivateProfile(bool value) async {
    final prefs = await _preferences;
    await prefs.setBool(_privateProfileKey, value);
  }

  // Show activity status
  Future<bool> showActivityStatus() async {
    final prefs = await _preferences;
    return prefs.getBool(_showActivityKey) ?? true;
  }

  Future<void> setShowActivityStatus(bool value) async {
    final prefs = await _preferences;
    await prefs.setBool(_showActivityKey, value);
  }

  // Clear all settings
  Future<void> clearAll() async {
    final prefs = await _preferences;
    await prefs.remove(_darkModeKey);
    await prefs.remove(_notificationsKey);
    await prefs.remove(_privateProfileKey);
    await prefs.remove(_showActivityKey);
  }
}
