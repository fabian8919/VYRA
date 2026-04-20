import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vyra/services/onboarding_service.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Stream de estado de autenticación
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Obtener usuario actual
  User? get currentUser => _supabase.auth.currentUser;

  // Verificar si hay sesión activa
  bool get isAuthenticated => currentUser != null;

  // Registro con email y contraseña
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );

      return res;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al registrar: $e');
    }
  }

  // Login con email y contraseña
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return res;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await OnboardingService().clearOnboardingState();
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  // Restablecer contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al enviar correo de recuperación: $e');
    }
  }

  // Actualizar perfil de usuario
  Future<void> updateProfile({String? name, String? avatarUrl}) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['full_name'] = name;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await _supabase.auth.updateUser(UserAttributes(data: updates));
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  // Manejar excepciones de Supabase Auth
  String _handleAuthException(AuthException e) {
    // Códigos de error comunes de Supabase
    switch (e.statusCode) {
      case '400':
        if (e.message.contains('email')) {
          return 'Correo electrónico inválido';
        }
        if (e.message.contains('password')) {
          return 'Contraseña inválida o demasiado débil';
        }
        return 'Solicitud inválida: ${e.message}';
      case '401':
        return 'Credenciales inválidas. Verifica tus datos.';
      case '403':
        return 'Acceso denegado. Verifica tu correo electrónico.';
      case '404':
        return 'Usuario no encontrado';
      case '409':
        return 'Este correo electrónico ya está registrado';
      case '422':
        return 'Datos inválidos. Verifica la información ingresada.';
      case '500':
        return 'Error del servidor. Intenta más tarde.';
      default:
        return e.message;
    }
  }
}
