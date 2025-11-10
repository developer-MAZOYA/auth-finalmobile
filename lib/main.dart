import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/project_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/project_registration_screen.dart';
import 'screens/daily_track_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ProjectProvider()),
      ],
      child: MaterialApp(
        title: "TRR Site Report",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6786ee)),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/project-registration': (context) =>
              const ProjectRegistrationScreen(),
          '/daily-track': (context) => const DailyTrackScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isAuthenticated) {
      return const DashboardScreen();
    } else {
      return const LoginScreen();
    }
  }
}
