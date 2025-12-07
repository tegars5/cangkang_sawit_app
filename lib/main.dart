import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/constants/app_constants.dart';
import 'shared/providers/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/mitra/mitra_dashboard_screen.dart';
import 'features/admin/pages/admin_main_layout.dart';
import 'features/driver/driver_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load Environment Variables
  await dotenv.load(fileName: ".env");

  // 2. Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // 3. Initialize Indonesian date formatting
  await initializeDateFormatting('id_ID', null);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Cangkang Sawit App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2E7D32),
              primary: const Color(0xFF2E7D32),
            ),
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          home: const AuthCheck(),
        );
      },
    );
  }
}

/// Widget to check authentication status using AuthProvider
/// Clean architecture - no direct Supabase calls
class AuthCheck extends ConsumerWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // Show loading while checking auth
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
        ),
      );
    }

    // If authenticated and has profile, navigate to appropriate dashboard
    if (authState.isAuthenticated && authState.profile != null) {
      final roleId = authState.profile!.roleId;
      if (roleId != null) {
        return _getDashboardForRole(roleId);
      }
    }

    // Not authenticated - show login
    return const LoginScreen();
  }

  Widget _getDashboardForRole(int roleId) {
    switch (roleId) {
      case 1: // Admin
        return const AdminMainLayout();
      case 2: // Mitra
        return const MitraDashboardScreen();
      case 3: // Driver
        return const DriverDashboardScreen();
      default:
        return const MitraDashboardScreen();
    }
  }
}
