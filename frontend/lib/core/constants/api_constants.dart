class ApiConstants {
  // Producción (Vercel)
  static const String baseUrl = 'https://project-ax22f.vercel.app';

  // Desarrollo local
  // static const String baseUrl = 'http://10.0.2.2:3000'; // Android emulator
  // static const String baseUrl = 'http://localhost:3000'; // iOS simulator / web


  static const String apiVersion = '/api';

  // Auth endpoints
  static String get login => '$baseUrl$apiVersion/auth/login';
  static String get register => '$baseUrl$apiVersion/auth/register';
  static String get me => '$baseUrl$apiVersion/auth/me';
  static String get logout => '$baseUrl$apiVersion/auth/logout';

  // Users endpoints
  static String get usersMe => '$baseUrl$apiVersion/users/me';
  static String userProfile(String id) => '$baseUrl$apiVersion/users/$id';
  static String userPosts(String id) => '$baseUrl$apiVersion/users/$id/posts';

  // Posts endpoints
  static String get posts => '$baseUrl$apiVersion/posts';
  static String get myPosts => '$baseUrl$apiVersion/users/me/posts';
}
