import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/profile/profile_screen.dart';
import 'features/health_records/data/models/health_record.dart';
import 'features/health_records/presentation/providers/health_record_provider.dart';
import 'features/health_records/presentation/screens/add_edit_health_record_screen.dart';
import 'features/health_records/presentation/screens/dashboard_screen.dart';
import 'features/health_records/presentation/screens/health_record_list_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const dashboard = '/';
  static const records = '/records';
  static const addEditRecord = '/add-edit-record';
  static const profile = '/profile';
}

class HealthMateApp extends StatelessWidget {
  const HealthMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => HealthRecordProvider()..loadRecords(),
        ),
      ],
      child: MaterialApp(
        title: 'HealthMate',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.login,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.login:
              return MaterialPageRoute<void>(
                builder: (_) => const LoginScreen(),
                settings: settings,
              );
            case AppRoutes.dashboard:
              return MaterialPageRoute<void>(
                builder: (_) => const DashboardScreen(),
                settings: settings,
              );
            case AppRoutes.records:
              return MaterialPageRoute<void>(
                builder: (_) => const HealthRecordListScreen(),
                settings: settings,
              );
            case AppRoutes.addEditRecord:
              final record = settings.arguments as HealthRecord?;
              return MaterialPageRoute<void>(
                builder: (_) => AddEditHealthRecordScreen(initialRecord: record),
                settings: settings,
              );
            case AppRoutes.profile:
              return MaterialPageRoute<void>(
                builder: (_) => const ProfileScreen(),
                settings: settings,
              );
            default:
              return MaterialPageRoute<void>(
                builder: (_) => const DashboardScreen(),
                settings: settings,
              );
          }
        },
      ),
    );
  }
}
