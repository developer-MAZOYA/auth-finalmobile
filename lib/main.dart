import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'Auth Final',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF667eea)),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
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

    // Show loading while checking auth state
    if (authProvider.isLoading && authProvider.user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Redirect based on auth state
    return authProvider.isAuthenticated
        ? const DashboardScreen()
        : const LoginScreen();
  }
}
