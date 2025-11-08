import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../admin/admin_dashboard.dart';
import '../mitra/mitra_dashboard.dart';
import '../logistik/logistik_dashboard.dart';
import '../../widgets/lottie_animations.dart';
import '../../widgets/professional_animations.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 60.h),

                  // Logo dan Title
                  Center(
                    child: Column(
                      children: [
                        BounceWidget(
                          child: Container(
                            width: 80.w,
                            height: 80.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Icon(
                              Icons.eco,
                              size: 40.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        AnimatedTextWidget(
                          text: 'Cangkang Sawit App',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                          ),
                          animationDuration: const Duration(milliseconds: 1200),
                        ),
                        SizedBox(height: 8.h),
                        SlideInWidget(
                          delay: const Duration(milliseconds: 500),
                          child: Text(
                            'PT. Fujiyama Biomass Energy',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 60.h),

                  // Welcome Text
                  Text(
                    'Selamat Datang',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Masuk ke akun Anda untuk melanjutkan',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                  ),

                  SizedBox(height: 40.h),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
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
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 32.h),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                _login();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
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
                  ),

                  SizedBox(height: 24.h),

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: const Color(0xFF2E7D32),
                          width: 2,
                        ),
                        foregroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Daftar Akun Baru',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Register Link (Alternative)
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun? ',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Gunakan tombol Masuk di atas',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF2E7D32),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Footer
                  Center(
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h), // Extra space at bottom
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Login dengan Supabase
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null) {
        // Ambil profile user untuk menentukan role
        final profileResponse = await Supabase.instance.client
            .from('profiles')
            .select('*, roles(*)')
            .eq('id', response.user!.id)
            .maybeSingle();

        if (profileResponse == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Profile user tidak ditemukan. Silahkan buat test users terlebih dahulu.',
                ),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 4),
              ),
            );
          }
          return;
        }

        final roleName = profileResponse['roles']?['name'] ?? '';

        if (mounted) {
          // Show professional success animation first
          await LottieSuccessDialog.show(
            context,
            title: 'Login Berhasil!',
            message:
                'Selamat datang, ${profileResponse['full_name']}!\nRole: $roleName',
          );

          // Navigate berdasarkan role
          switch (roleName.toLowerCase()) {
            case 'admin':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboard()),
              );
              break;
            case 'mitra bisnis':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MitraDashboard()),
              );
              break;
            case 'logistik':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LogistikDashboard(),
                ),
              );
              break;
            default:
              LottieSnackbar.showError(
                context,
                message:
                    'Role tidak dikenali: "$roleName". Silahkan hubungi administrator.',
              );
          }
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        String errorMessage = 'Login gagal';

        if (e.message.contains('Invalid login credentials')) {
          errorMessage =
              'Email atau password salah. Pastikan menggunakan credentials yang benar atau buat test users terlebih dahulu.';
        } else if (e.message.contains('Email not confirmed')) {
          errorMessage = 'Email belum dikonfirmasi. Silahkan cek email Anda.';
        } else {
          errorMessage = 'Login gagal: ${e.message}';
        }

        LottieSnackbar.showError(
          context,
          message: errorMessage,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      if (mounted) {
        LottieSnackbar.showError(
          context,
          message: 'Error tidak terduga: ${e.toString()}',
          duration: const Duration(seconds: 4),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
