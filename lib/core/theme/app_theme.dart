import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Colores del nuevo diseño (basados en login)
  // Fondo principal - lavanda muy claro
  static const Color background = Color(0xFFF0F0FF);
  
  // Surface colors - lavanda claro para tarjetas
  static const Color surfaceContainer = Color(0xFFE8E8FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);

  // Primary colors
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color accentBlue = Color(0xFF60A5FA);
  static const Color skyBlue = Color(0xFF93C5FD);
  static const Color lightBlue = Color(0xFFEEF2FF);

  // Colores de texto
  static const Color textPrimary = Color(0xFF292B51);
  static const Color textSecondary = Color(0xFF565881);
  static const Color textLight = Color(0xFF71739E);
  static const Color textMuted = Color(0xFF565881);
  static const Color onSurface = Color(0xFF292B51);
  static const Color onSurfaceVariant = Color(0xFF565881);

  // Bordes y divisores
  static const Color outline = Color(0xFF71739E);
  static const Color outlineVariant = Color(0xFFC4C4E0);
  
  // Superficie
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;

  // Degradados
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB), Color(0xFF1D4ED8)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF2563EB), Color(0xFF3B82F6), Color(0xFF60A5FA)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEEF2FF), Color(0xFFF8FAFC)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFF)],
  );

  // Sombras
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF3B82F6).withAlpha(26),
      blurRadius: 40,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: const Color(0xFF2563EB).withAlpha(77),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // Tema claro
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: accentBlue,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.bold,
          color: primaryBlue,
          letterSpacing: -1,
        ),
        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
        labelLarge: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textMuted,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white.withAlpha(230),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  // Tema oscuro (para el feed)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: accentBlue,
        surface: Color(0xFF1A1A1A),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }
}
