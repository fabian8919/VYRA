import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vyra/core/providers/theme_provider.dart';

class AppTheme {
  // === COLORES CLAROS (originales) ===
  static const Color _lightBackground = Color(0xFFF0F0FF);
  static const Color _lightSurfaceContainer = Color(0xFFE8E8FF);
  static const Color _lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _lightTextPrimary = Color(0xFF292B51);
  static const Color _lightTextSecondary = Color(0xFF565881);
  static const Color _lightTextLight = Color(0xFF71739E);
  static const Color _lightTextMuted = Color(0xFF565881);
  static const Color _lightOnSurface = Color(0xFF292B51);
  static const Color _lightOnSurfaceVariant = Color(0xFF565881);
  static const Color _lightOutline = Color(0xFF71739E);
  static const Color _lightOutlineVariant = Color(0xFFC4C4E0);
  static const Color _lightSurface = Colors.white;
  static const Color _lightCardBackground = Colors.white;

  // === COLORES OSCUROS ===
  static const Color _darkBackground = Color(0xFF0D0D1A);
  static const Color _darkSurfaceContainer = Color(0xFF252538);
  static const Color _darkSurfaceContainerLowest = Color(0xFF1E1E2E);
  static const Color _darkTextPrimary = Colors.white;
  static const Color _darkTextSecondary = Color(0xFFD0D0E0);
  static const Color _darkTextLight = Color(0xFFC0C0D0);
  static const Color _darkTextMuted = Color(0xFFC0C0D0);
  static const Color _darkOnSurface = Colors.white;
  static const Color _darkOnSurfaceVariant = Color(0xFFD0D0E0);
  static const Color _darkOutline = Color(0xFF4A4A5E);
  static const Color _darkOutlineVariant = Color(0xFF2A2A3E);
  static const Color _darkSurface = Color(0xFF1A1A2A);
  static const Color _darkCardBackground = Color(0xFF252538);

  static bool get _isDark => ThemeProvider.instance.isDarkMode;

  // === COLORES DINÁMICOS ===
  static Color get background => _isDark ? _darkBackground : _lightBackground;
  static Color get surfaceContainer => _isDark ? _darkSurfaceContainer : _lightSurfaceContainer;
  static Color get surfaceContainerLowest => _isDark ? _darkSurfaceContainerLowest : _lightSurfaceContainerLowest;
  static Color get textPrimary => _isDark ? _darkTextPrimary : _lightTextPrimary;
  static Color get textSecondary => _isDark ? _darkTextSecondary : _lightTextSecondary;
  static Color get textLight => _isDark ? _darkTextLight : _lightTextLight;
  static Color get textMuted => _isDark ? _darkTextMuted : _lightTextMuted;
  static Color get onSurface => _isDark ? _darkOnSurface : _lightOnSurface;
  static Color get onSurfaceVariant => _isDark ? _darkOnSurfaceVariant : _lightOnSurfaceVariant;
  static Color get outline => _isDark ? _darkOutline : _lightOutline;
  static Color get outlineVariant => _isDark ? _darkOutlineVariant : _lightOutlineVariant;
  static Color get surface => _isDark ? _darkSurface : _lightSurface;
  static Color get cardBackground => _isDark ? _darkCardBackground : _lightCardBackground;

  // Primary colors (siempre iguales)
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color accentBlue = Color(0xFF60A5FA);
  static const Color skyBlue = Color(0xFF93C5FD);
  static const Color lightBlue = Color(0xFFEEF2FF);

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
      scaffoldBackgroundColor: _lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: accentBlue,
        surface: _lightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _lightTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: _lightTextPrimary,
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
          color: _lightTextPrimary,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: _lightTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _lightTextPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: _lightTextPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: _lightTextSecondary),
        labelLarge: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _lightTextMuted,
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

  // Tema oscuro
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: accentBlue,
        surface: _darkSurface,
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
        fillColor: _darkSurfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkOutlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkOutlineVariant),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: primaryBlue, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        hintStyle: TextStyle(color: _darkTextLight, fontSize: 15),
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
          color: _darkTextPrimary,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: _darkTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _darkTextPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: _darkTextPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: _darkTextSecondary),
        labelLarge: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _darkTextMuted,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _darkCardBackground.withAlpha(230),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}
