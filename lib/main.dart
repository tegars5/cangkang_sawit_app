import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // WAJIB: Untuk Riverpod
import 'package:flutter_screenutil/flutter_screenutil.dart'; // WAJIB: Untuk ukuran layar
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart'; // WAJIB: Untuk format tanggal Indo
import 'package:flutter_dotenv/flutter_dotenv.dart'; // WAJIB: Untuk environment variables

// Pastikan import ini sesuai dengan lokasi file Kakak
import 'core/constants/app_constants.dart';
import 'features/auth/login_screen.dart';
import 'features/mitra/mitra_dashboard_screen.dart';
import 'features/admin/pages/admin_dashboard_page.dart'; // Sesuaikan nama file dashboard admin
import 'features/driver/driver_dashboard_screen.dart'; // Sesuaikan nama file dashboard driver

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load Environment Variables
  // PENTING! Harus dipanggil sebelum mengakses AppConstants
  await dotenv.load(fileName: ".env");

  // 2. Inisialisasi Supabase
  // Kredensial akan diambil dari file .env
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // 3. Inisialisasi Format Tanggal Indonesia (PENTING! Biar gak merah saat buka kalender)
  await initializeDateFormatting('id_ID', null);

  runApp(
    // 4. Bungkus App dengan ProviderScope (PENTING! Biar Riverpod jalan)
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 5. Bungkus dengan ScreenUtilInit agar .w dan .h berfungsi
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Ukuran desain standar (iPhone X)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Cangkang Sawit App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2E7D32), // Warna Hijau Sawit
              primary: const Color(0xFF2E7D32),
            ),
            useMaterial3: true,
            // Font default (opsional)
            fontFamily: 'Roboto',
          ),
          // Cek sesi login saat aplikasi dibuka
          home: const AuthCheck(),
        );
      },
    );
  }
}

/// Widget untuk mengecek status login user saat aplikasi baru dibuka
class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      // Beri jeda sedikit agar splash screen terasa halus
      await Future.delayed(const Duration(seconds: 2));

      final session = Supabase.instance.client.auth.currentSession;

      if (session == null) {
        _navigateToLogin();
      } else {
        // Jika sudah login, cek role user untuk diarahkan ke dashboard yang benar
        await _checkUserRole(session.user.id);
      }
    } catch (e) {
      // Jika error, lempar ke login aja biar aman
      _navigateToLogin();
    }
  }

  Future<void> _checkUserRole(String userId) async {
    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('role_id, roles(name)')
          .eq('id', userId)
          .single();

      final roleId = profile['role_id'] as int?;

      if (mounted) {
        if (roleId == 2) {
          // Mitra Bisnis
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MitraDashboardScreen()),
          );
        } else if (roleId == 1) {
          // Admin
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
          );
        } else if (roleId == 3) {
          // Driver/Logistik
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DriverDashboardScreen()),
          );
        } else {
          _navigateToLogin();
        }
      }
    } catch (e) {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),
    );
  }
}
