import 'package:flutter/material.dart';
import 'package:vyra/core/providers/theme_provider.dart';
import 'package:vyra/core/theme/app_theme.dart';
import 'package:vyra/features/auth/presentation/screens/login_screen.dart';
import 'package:vyra/features/home/presentation/screens/home_screen.dart';
import 'package:vyra/features/onboarding/presentation/screens/interests_screen.dart';
import 'package:vyra/services/auth_service.dart';
import 'package:vyra/services/onboarding_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar tema guardado
  await ThemeProvider.instance.loadTheme();

  // Inicializar y validar sesión activa contra el backend
  await AuthService().initializeSession();

  runApp(const VyraApp());
}

class VyraApp extends StatelessWidget {
  const VyraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeProvider.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'Vyra',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeProvider.instance.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Estado inicial mientras carga
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data?.status == AuthStatus.loading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBlue),
            ),
          );
        }

        // Usuario autenticado
        if (snapshot.data?.status == AuthStatus.authenticated) {
          return const _PostLoginGate();
        }

        // Usuario no autenticado
        return const LoginScreen();
      },
    );
  }
}

/// Widget que decide si mostrar la pantalla de intereses (primer ingreso)
/// o ir directamente al Home.
class _PostLoginGate extends StatefulWidget {
  const _PostLoginGate();

  @override
  State<_PostLoginGate> createState() => _PostLoginGateState();
}

class _PostLoginGateState extends State<_PostLoginGate> {
  late final Future<bool> _onboardingFuture;

  @override
  void initState() {
    super.initState();
    _onboardingFuture = OnboardingService().hasCompletedInterests();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _onboardingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBlue),
            ),
          );
        }

        final hasCompleted = snapshot.data ?? false;
        if (!hasCompleted) {
          return const InterestsScreen();
        }

        return const HomeScreen();
      },
    );
  }
}
