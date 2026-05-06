import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vyra/core/constants/api_constants.dart';
import 'package:vyra/services/onboarding_service.dart';

/// Modelo simple de usuario basado en la respuesta de Supabase Auth
class AuthUser {
  final String id;
  final String email;
  final String? name;
  final Map<String, dynamic>? metadata;

  AuthUser({
    required this.id,
    required this.email,
    this.name,
    this.metadata,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      name: json['user_metadata']?['full_name'] as String?,
      metadata: json['user_metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Eventos de estado de autenticación
enum AuthStatus { authenticated, unauthenticated, loading }

class AppAuthState {
  final AuthStatus status;
  final AuthUser? user;

  AppAuthState({required this.status, this.user});
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _authStateController = StreamController<AppAuthState>.broadcast();
  Stream<AppAuthState> get authStateChanges => _authStateController.stream;

  AppAuthState _currentState = AppAuthState(status: AuthStatus.loading);
  AppAuthState get currentState => _currentState;

  AuthUser? _currentUser;
  AuthUser? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  // ──────────────────────────────────────────
  // Almacenamiento de tokens
  // ──────────────────────────────────────────

  static const _keyAccessToken = 'vyra_access_token';
  static const _keyRefreshToken = 'vyra_refresh_token';

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  Future<void> _saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
  }

  // ──────────────────────────────────────────
  // Headers comunes
  // ──────────────────────────────────────────

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth) {
      final token = await getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ──────────────────────────────────────────
  // Inicialización / validación de sesión
  // ──────────────────────────────────────────

  /// Valida si hay un token guardado y es válido llamando a /api/auth/me
  Future<void> initializeSession() async {
    _currentState = AppAuthState(status: AuthStatus.loading);
    _authStateController.add(_currentState);

    final token = await getAccessToken();
    if (token == null || token.isEmpty) {
      _currentUser = null;
      _currentState = AppAuthState(status: AuthStatus.unauthenticated);
      _authStateController.add(_currentState);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.me),
        headers: await _headers(auth: true),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final userJson = body['user'] as Map<String, dynamic>;
        _currentUser = AuthUser.fromJson(userJson);
        _currentState = AppAuthState(status: AuthStatus.authenticated, user: _currentUser);
        _authStateController.add(_currentState);
      } else {
        await _clearTokens();
        _currentUser = null;
        _currentState = AppAuthState(status: AuthStatus.unauthenticated);
      _authStateController.add(_currentState);
      }
    } on SocketException {
      // Sin conexión: mantener estado anterior o marcar como no autenticado
      _currentUser = null;
      _currentState = AppAuthState(status: AuthStatus.unauthenticated);
      _authStateController.add(_currentState);
    } catch (e) {
      await _clearTokens();
      _currentUser = null;
      _currentState = AppAuthState(status: AuthStatus.unauthenticated);
      _authStateController.add(_currentState);
    }
  }

  // ──────────────────────────────────────────
  // Login
  // ──────────────────────────────────────────

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: await _headers(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 8));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        throw Exception(body['error'] ?? 'Error al iniciar sesión');
      }

      final accessToken = body['access_token'] as String;
      final refreshToken = body['refresh_token'] as String;
      final userJson = body['user'] as Map<String, dynamic>;

      await _saveTokens(accessToken: accessToken, refreshToken: refreshToken);
      _currentUser = AuthUser.fromJson(userJson);

      _authStateController.add(
        AppAuthState(status: AuthStatus.authenticated, user: _currentUser),
      );
    } on SocketException {
      throw Exception('Sin conexión a internet. Verifica tu red.');
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ──────────────────────────────────────────
  // Registro
  // ──────────────────────────────────────────

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: await _headers(),
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      ).timeout(const Duration(seconds: 8));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(body['error'] ?? 'Error al registrar');
      }

      // Si el registro devolvió sesión (confirmación de email desactivada)
      if (body['access_token'] != null) {
        final accessToken = body['access_token'] as String;
        final refreshToken = body['refresh_token'] as String;
        final userJson = body['user'] as Map<String, dynamic>;

        await _saveTokens(accessToken: accessToken, refreshToken: refreshToken);
        _currentUser = AuthUser.fromJson(userJson);

        _currentState = AppAuthState(status: AuthStatus.authenticated, user: _currentUser);
        _authStateController.add(_currentState);
      } else {
        // Requiere confirmación de email
        _currentState = AppAuthState(status: AuthStatus.unauthenticated);
      _authStateController.add(_currentState);
      }
    } on SocketException {
      throw Exception('Sin conexión a internet. Verifica tu red.');
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ──────────────────────────────────────────
  // Logout
  // ──────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await OnboardingService().clearOnboardingState();

      final token = await getAccessToken();
      if (token != null) {
        await http.post(
          Uri.parse(ApiConstants.logout),
          headers: await _headers(auth: true),
        ).timeout(const Duration(seconds: 8));
      }
    } catch (e) {
      // Ignorar errores de red en logout
    } finally {
      await _clearTokens();
      _currentUser = null;
      _currentState = AppAuthState(status: AuthStatus.unauthenticated);
      _authStateController.add(_currentState);
    }
  }

  // ──────────────────────────────────────────
  // Perfil
  // ──────────────────────────────────────────

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    // Por ahora, devuelve los metadatos del usuario.
    // Cuando tengas /api/users/:id o /api/profiles/:id,
    // reemplaza esta implementación.
    if (_currentUser == null) return null;
    return {
      'id': _currentUser!.id,
      'username': _currentUser!.name,
      'full_name': _currentUser!.name,
    };
  }

  // ──────────────────────────────────────────
  // Actualizar perfil (placeholder para futuro)
  // ──────────────────────────────────────────

  Future<void> updateProfile({
    String? name,
    String? bio,
    String? avatarUrl,
  }) async {
    // TODO: Implementar vía backend cuando exista el endpoint
    if (_currentUser == null) {
      throw Exception('No hay sesión activa');
    }
    // Por ahora solo actualiza localmente
    _currentUser = AuthUser(
      id: _currentUser!.id,
      email: _currentUser!.email,
      name: name ?? _currentUser!.name,
      metadata: _currentUser!.metadata,
    );
  }

  Future<void> updateDisplayName(String name) async {
    await updateProfile(name: name);
  }

  // ──────────────────────────────────────────
  // Restablecer contraseña (placeholder)
  // ──────────────────────────────────────────

  Future<void> resetPassword(String email) async {
    // TODO: Implementar endpoint /api/auth/reset-password en backend
    throw Exception(
      'Funcionalidad no implementada. Contacta soporte.',
    );
  }

  void dispose() {
    _authStateController.close();
  }
}
