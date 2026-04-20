import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vyra/core/theme/app_theme.dart';
import 'package:vyra/features/auth/presentation/screens/login_screen.dart';
import 'package:vyra/features/home/presentation/screens/home_screen.dart';
import 'package:vyra/features/onboarding/presentation/screens/interests_screen.dart';
import 'package:vyra/services/auth_service.dart';
import 'package:vyra/services/onboarding_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://nybndivzkohedszwmezs.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im55Ym5kaXZ6a29oZWRzendtZXpzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMwMDU0MzYsImV4cCI6MjA4ODU4MTQzNn0.n8mrFGEUOSHY54l9Q0aRgwmrr5ao2L0p0q4CGTIbmeo',
  );

  runApp(const VyraApp());
}

class VyraApp extends StatelessWidget {
  const VyraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vyra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const AuthWrapper(),
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBlue),
            ),
          );
        }

        // Verificar si hay sesión activa
        final session = snapshot.data?.session;
        if (session != null) {
          return const _PostLoginGate();
        }

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
