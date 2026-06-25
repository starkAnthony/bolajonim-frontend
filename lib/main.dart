import 'package:flutter/material.dart';
import 'core/services/app_warmup_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/session_service.dart';
import 'core/services/splash_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/splash_bridge.dart';
import 'core/widgets/splash_loading_screen.dart';
import 'features/auth/presentation/start_screen.dart';
import 'features/navigation/main_navigation_screen.dart';
import 'features/teacher/presentation/teacher_main_navigation_screen.dart';

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

class AppEntryScreen extends StatefulWidget {
  const AppEntryScreen({super.key});

  @override
  State<AppEntryScreen> createState() => _AppEntryScreenState();
}

class _AppEntryScreenState extends State<AppEntryScreen> {
  bool _ready = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    SplashService.beginSplashImageWait();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final startedAt = DateTime.now();

    await SplashService.bootstrap();
    final isLoggedIn = await AuthService.isLoggedIn();
    await AppWarmupService.warmup(splash: SplashService.current);
    await SplashService.waitForSplashImageReady();

    final elapsed = DateTime.now().difference(startedAt);
    final remaining = SplashService.minDisplayDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    if (!mounted) return;
    dismissHtmlSplash();
    resetWebAppearance();
    setState(() {
      _isLoggedIn = isLoggedIn;
      _ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return SplashLoadingScreen(config: SplashService.current);
    }

    if (_isLoggedIn) {
      return const RoleBasedHomeScreen();
    }

    return const StartScreen();
  }
}

class RoleBasedHomeScreen extends StatefulWidget {
  const RoleBasedHomeScreen({super.key});

  @override
  State<RoleBasedHomeScreen> createState() => _RoleBasedHomeScreenState();
}

class _RoleBasedHomeScreenState extends State<RoleBasedHomeScreen> {
  UserRole? _role;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final startedAt = DateTime.now();
    final role = await SessionService.getRole();
    final elapsed = DateTime.now().difference(startedAt);
    const minRoleSplash = Duration(milliseconds: 600);
    final remaining = minRoleSplash - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    if (!mounted) return;
    setState(() {
      _role = role;
      _ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return SplashLoadingScreen(config: SplashService.current);
    }

    return switch (_role ?? UserRole.parent) {
      UserRole.teacher => const TeacherMainNavigationScreen(),
      UserRole.director => const TeacherMainNavigationScreen(isDirector: true),
      _ => const MainNavigationScreen(),
    };
  }
}
