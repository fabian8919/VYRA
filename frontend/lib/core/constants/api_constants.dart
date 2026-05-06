class ApiConstants {
  // TODO: Cambiar a la URL de producción cuando deployes
  static const String baseUrl = 'http://10.0.2.2:3000'; // Android emulator localhost
  // static const String baseUrl = 'http://localhost:3000'; // iOS simulator / web

  static const String apiVersion = '/api';

  // Auth endpoints
  static String get login => '$baseUrl$apiVersion/auth/login';
  static String get register => '$baseUrl$apiVersion/auth/register';
  static String get me => '$baseUrl$apiVersion/auth/me';
  static String get logout => '$baseUrl$apiVersion/auth/logout';
}
