import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/activity_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/draft_provider.dart';
import 'providers/observation_provider.dart';
import 'providers/evidence_provider.dart';
import 'screens/draft_reports_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/daily_track_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/activities_screen.dart';
import 'services/api_service.dart';

void main() {
  // Enable better error reporting
  WidgetsFlutterBinding.ensureInitialized();

  // Print startup message
  print('🚀 Starting TRR Site Report App...');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('🏗️ Building MyApp widget...');

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => DraftProvider()),
        ChangeNotifierProvider(
          create: (context) => ObservationProvider(
            apiService: ApiService(
              baseUrl: 'http://192.168.1.190:8080/api/observations',
            ),
          ),
        ),
        ChangeNotifierProvider(create: (context) => EvidenceProvider()),
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
          '/daily-track': (context) => const DailyTrackScreen(),
          '/activities': (context) => const ActivitiesScreen(), // Fixed route
          '/drafts': (context) => const DraftReportsScreen(),
          '/reports': (context) => const ReportsScreen(),
        },
        onGenerateRoute: (settings) {
          // Handle unknown routes
          if (settings.name == '/activity') {
            return MaterialPageRoute(
                builder: (context) => const ActivitiesScreen());
          }
          return null;
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    print('🔐 Checking authentication status...');

    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isAuthenticated) {
      print('✅ User is authenticated, showing Dashboard');
      return const DashboardScreen();
    } else {
      print('🔒 User not authenticated, showing Login');
      return const LoginScreen();
    }
  }
}
