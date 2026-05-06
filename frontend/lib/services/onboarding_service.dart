import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingService {
  static final OnboardingService _instance = OnboardingService._internal();
  factory OnboardingService() => _instance;
  OnboardingService._internal();

  static const String _interestsKeyPrefix = 'user_interests_completed_';

  String _getKey(String userId) => '$_interestsKeyPrefix$userId';

  /// Verifica si el usuario ya completó la selección de intereses.
  Future<bool> hasCompletedInterests() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_getKey(user.id)) ?? false;
  }

  /// Marca que el usuario completó la selección de intereses.
  Future<void> markInterestsCompleted() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_getKey(user.id), true);
  }

  /// Limpia el estado (útil al cerrar sesión).
  Future<void> clearOnboardingState() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getKey(user.id));
  }
}
