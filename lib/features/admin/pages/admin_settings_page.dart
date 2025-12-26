import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';

/// Login Page - Simplified version with role driver id = 3
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      print('🔐 Starting login...');

      // Login with Supabase
      final authResponse = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      print('✅ Auth success! User ID: ${authResponse.user?.id}');
      print('📝 Session: ${authResponse.session != null}');

      if (authResponse.user == null || authResponse.session == null) {
        throw Exception(
          'Login gagal. Silakan periksa email dan password Anda.',
        );
      }

      // Wait for session initialization
      await Future.delayed(const Duration(milliseconds: 1500));

      print('📊 Querying profile for user: ${authResponse.user!.id}');

      // Try-catch specifically for the profile query
      late final Map<String, dynamic> profileData;
      try {
        profileData = await supabase
            .from('profiles')
            .select('role_id, full_name, email')
            .eq('id', authResponse.user!.id)
            .single();

        print('✅ Profile data: $profileData');
      } catch (e) {
        print('❌ Profile query error: $e');
        print('Error type: ${e.runtimeType}');
        rethrow;
      }

      final roleId = profileData['role_id'] as int?;
      final fullName = profileData['full_name'] as String?;

      print('👤 Role ID: $roleId, Name: $fullName');

      if (roleId == null) {
        throw Exception(
          'Role pengguna tidak ditemukan. Hubungi administrator.',
        );
      }

      // Get role name with fallback
      String roleName = roleId == 1
          ? 'Admin'
          : roleId == 2
          ? 'Mitra Bisnis'
          : roleId == 3
          ? 'Driver'
          : 'User';

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login berhasil! Selamat datang ${fullName ?? roleName}',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate based on role (clear all previous routes)
      String routeName;

      if (roleId == 3) {
        // Driver role
        routeName = AppRouter.driverDeliveries;
      } else if (roleId == 1) {
        // Admin role
        routeName = AppRouter.adminDashboard;
      } else if (roleId == 2) {
        // Mitra Bisnis role
        routeName = AppRouter.productCatalog;
      } else {
        throw Exception('Role tidak dikenali (ID: $roleId)');
      }

      // Clear navigation stack and go to dashboard
      // Use GoRouter context.go for navigation
      if (roleId == 3) {
        // Driver: Go to deliveries page
        context.go(AppRouter.driverDeliveries);
      } else if (roleId == 1) {
        // Admin: Go to admin dashboard
        context.go(AppRouter.adminDashboard);
      } else if (roleId == 2) {
        // Mitra: Go to product catalog
        context.go(AppRouter.productCatalog);
      }
    } on AuthException catch (e) {
      if (!mounted) return;

      String errorMessage = 'Login gagal';
      if (e.message.contains('Invalid login credentials')) {
        errorMessage = 'Email atau password salah';
      } else if (e.message.contains('Email not confirmed')) {
        errorMessage = 'Email belum dikonfirmasi';
      } else {
        errorMessage = 'Login gagal: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Icon(
                    Icons.local_shipping_rounded,
                    size: 80.sp,
                    color: const Color(0xFF1B5E20),
                  ),
                  SizedBox(height: 24.h),

                  // Title
                  Text(
                    'Cangkang Sawit',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B5E20),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Delivery Management System',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 48.h),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'masukkan email anda',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email wajib diisi';
                      }
                      if (!value.contains('@')) {
                        return 'Email tidak valid';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'masukkan password anda',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password wajib diisi';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24.h),

                  // Login Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Masuk',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  SizedBox(height: 16.h),

                  // Register Link (optional - uncomment if needed)
                  // TextButton(
                  //   onPressed: () {
                  //     Navigator.of(context).pushNamed(AppRouter.register);
                  //   },
                  //   child: Text(
                  //     'Belum punya akun? Daftar disini',
                  //     style: TextStyle(
                  //       fontSize: 14.sp,
                  //       color: const Color(0xFF1B5E20),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(height: 24.h),

                  // Role Info
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[700],
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Role ID Information',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '• Admin: Role ID = 1\n'
                          '• Mitra Bisnis: Role ID = 2\n'
                          '• Driver: Role ID = 3',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
