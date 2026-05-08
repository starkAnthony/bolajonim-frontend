import 'package:flutter/material.dart';
import 'core/services/auth_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/start_screen.dart';
import 'features/navigation/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BolajonimApp());
}

class BolajonimApp extends StatelessWidget {
  const BolajonimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bolajonim',
      theme: AppTheme.lightTheme,
      home: const AppEntryScreen(),
    );
  }
}

class AppEntryScreen extends StatelessWidget {
  const AppEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SplashLoadingScreen();
        }

        final isLoggedIn = snapshot.data ?? false;

        if (isLoggedIn) {
          return const MainNavigationScreen();
        }

        return const StartScreen();
      },
    );
  }
}

class SplashLoadingScreen extends StatelessWidget {
  const SplashLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
