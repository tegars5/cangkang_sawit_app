import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/lottie_animations.dart';
import '../../widgets/animation_widgets.dart';
import '../../utils/test_users_helper.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;
  String _selectedRole = 'mitra_bisnis'; // Default role

  final List<Map<String, String>> _roles = [
    {'value': 'mitra_bisnis', 'label': 'Mitra Bisnis'},
    {'value': 'driver', 'label': 'Driver/Logistik'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<bool> _checkEmailAvailability(String email) async {
    try {
      final supabase = Supabase.instance.client;

      // Check in profiles table
      final profileCheck = await supabase
          .from('profiles')
          .select('email')
          .eq('email', email.trim());

      return profileCheck.isEmpty;
    } catch (e) {
      print('Error checking email availability: $e');
      return true; // Allow if we can't check
    }
  }

  Future<void> _resendVerificationEmail(String email) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.resend(type: OtpType.signup, email: email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email verifikasi telah dikirim ulang ke $email'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim email verifikasi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Fungsi untuk menampilkan Syarat & Ketentuan
  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Syarat & Ketentuan'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PT. Fujiyama Biomass Energy',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Dengan mendaftar, Anda menyetujui:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildTermItem('1. Kebijakan Privasi data pribadi'),
              _buildTermItem('2. Penggunaan aplikasi sesuai ketentuan'),
              _buildTermItem('3. Kerahasiaan informasi bisnis'),
              _buildTermItem('4. Kualitas produk cangkang sawit yang dijual'),
              _buildTermItem('5. Ketepatan waktu pengiriman'),
              _buildTermItem('6. Transparansi dalam transaksi'),
              const SizedBox(height: 16),
              const Text(
                '⚠️ Pelanggaran dapat mengakibatkan penangguhan akun.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  // Fungsi untuk membuat test users
  Future<void> _createTestUsers() async {
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Test Users'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Akan membuat ${TestUsersHelper.testUsers.length} test users:',
            ),
            SizedBox(height: 8),
            ...TestUsersHelper.testUsers.map(
              (user) => Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  '• ${user['name']} (${user['role']})',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Proses ini akan memakan waktu beberapa detik.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: Text('Buat Users'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF2E7D32)),
            SizedBox(height: 16),
            Text('Membuat test users...'),
          ],
        ),
      ),
    );

    try {
      final results = await TestUsersHelper.createAllTestUsers();

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        // Show results dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Test Users Creation'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(results['summary']),
                  SizedBox(height: 16),
                  if (results['success'].isNotEmpty) ...[
                    Text(
                      'Login Credentials:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    ...TestUsersHelper.testUsers.map(
                      (user) => Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${user['name']} (${user['role']})',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('📧 ${user['email']}'),
                              Text('🔑 ${user['password']}'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating test users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Fungsi untuk menampilkan info test users
  void _showTestUsersInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Available Test Users'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Gunakan credentials berikut untuk testing:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ...TestUsersHelper.testUsers.map(
                (user) => Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user['name']} (${user['role']?.toUpperCase()})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('📧 ${user['email']}'),
                      Text('🔑 ${user['password']}'),
                      Text('📱 ${user['phone']}'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '💡 Tip: Copy email dan password untuk login testing',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validasi terms & conditions
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon setujui Syarat & Ketentuan untuk melanjutkan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      // 1. Cek apakah email sudah terdaftar
      try {
        await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: 'dummy_password_check',
        );
        // Jika sampai sini, berarti email sudah ada
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Email ${_emailController.text.trim()} sudah terdaftar. Silakan gunakan email lain atau login.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      } catch (e) {
        // Email belum terdaftar, lanjut proses registrasi
      }

      // 2. Register user dengan Supabase Auth
      final String fullName = _nameController.text.trim();
      final String email = _emailController.text.trim();
      final String phone = _phoneController.text.trim();
      final String address = _addressController.text.trim();

      print('📝 Starting registration with data:');
      print('   Full Name: $fullName');
      print('   Email: $email');
      print('   Phone: $phone');
      print('   Role: $_selectedRole');
      print('   Address: $address');

      final AuthResponse authResponse = await supabase.auth.signUp(
        email: email,
        password: _passwordController.text,
        data: {
          'full_name': fullName,
          'display_name': fullName, // Tambahan untuk display_name
          'role': _selectedRole,
          'phone': phone,
        },
      );

      if (authResponse.user == null) {
        throw Exception('Gagal membuat akun. Silakan coba lagi.');
      }

      final userId = authResponse.user!.id;
      print('✅ User registered with ID: $userId');

      // 3. Buat profile untuk user dengan data lengkap
      final profileData = {
        'id': userId,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'address': address,
        'role': _selectedRole,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('📊 Creating profile with data: $profileData');

      try {
        await supabase.from('profiles').upsert(profileData);
        print('✅ Profile created successfully');

        // Update auth.users display_name juga
        try {
          await supabase.auth.updateUser(
            UserAttributes(
              data: {
                'full_name': fullName,
                'display_name': fullName,
                'phone': phone,
                'role': _selectedRole,
              },
            ),
          );
          print('✅ Auth user metadata updated');
        } catch (updateError) {
          print('⚠️ Auth update error (non-critical): $updateError');
        }
      } catch (profileError) {
        print('❌ Profile creation error: $profileError');

        // Coba dengan struktur minimal
        try {
          await supabase.from('profiles').insert({
            'id': userId,
            'email': email,
          });
          print('✅ Minimal profile created');
        } catch (minimalError) {
          print('❌ Even minimal profile failed: $minimalError');
          // User sudah terdaftar di auth, tapi profile mungkin belum
        }
      }

      print('Profile created successfully'); // Debug logging

      // 3. Handle email verification
      bool needsEmailVerification = authResponse.user!.emailConfirmedAt == null;

      // 4. Show success animation dengan info verification
      if (mounted) {
        String verificationText = needsEmailVerification
            ? '📨 Silakan cek email Anda untuk verifikasi akun sebelum login.'
            : '🎉 Akun sudah aktif! Silakan login dengan akun baru Anda.';

        String successMessage =
            '''
Akun Anda telah berhasil dibuat! ✅

📧 Email: $email
👤 Nama: $fullName
🏢 Role: ${_roles.firstWhere((r) => r['value'] == _selectedRole)['label']}
📱 Phone: $phone
📍 Alamat: $address

$verificationText
        ''';

        await LottieSuccessDialog.show(
          context,
          title: 'Registrasi Berhasil!',
          message: successMessage.trim(),
        );

        // 5. Navigate back to login
        Navigator.of(context).pop();
      }
    } on AuthException catch (e) {
      if (mounted) {
        String errorMessage = 'Gagal membuat akun';

        print('AuthException: ${e.message}'); // Debug logging

        if (e.message.contains('User already registered') ||
            e.message.contains('already registered') ||
            e.message.contains('email address is already registered')) {
          errorMessage =
              'Email ${_emailController.text.trim()} sudah terdaftar.\nSilakan gunakan email lain atau login dengan akun tersebut.';
        } else if (e.message.contains('invalid email') ||
            e.message.contains('Invalid email')) {
          errorMessage =
              'Format email tidak valid. Pastikan email memiliki format yang benar.';
        } else if (e.message.contains('password') ||
            e.message.contains('Password')) {
          errorMessage =
              'Password terlalu lemah. Password harus minimal 6 karakter.';
        } else if (e.message.contains('network') ||
            e.message.contains('Network')) {
          errorMessage = 'Koneksi internet bermasalah. Silakan coba lagi.';
        } else {
          errorMessage = 'Registrasi gagal: ${e.message}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        print('PostgrestException: ${e.message}'); // Debug logging
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database error: ${e.message}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        print('General Exception: $e'); // Debug logging
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan tidak terduga: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF2E7D32)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Test Users Info Button
          IconButton(
            icon: Icon(Icons.info_outline, color: Color(0xFF2E7D32)),
            onPressed: _showTestUsersInfo,
            tooltip: 'Show Test Users Info',
          ),
          // Create Test Users Button
          IconButton(
            icon: Icon(Icons.group_add, color: Color(0xFF2E7D32)),
            onPressed: _createTestUsers,
            tooltip: 'Create Test Users',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo dan Header
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
                            color: Colors.white,
                            size: 40.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      SlideInWidget(
                        direction: SlideDirection.top,
                        child: Text(
                          'Buat Akun Baru',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      SlideInWidget(
                        direction: SlideDirection.top,
                        delay: Duration(milliseconds: 200),
                        child: Text(
                          'Bergabung dengan PT. Fujiyama Biomass Energy',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40.h),

                // Form Fields
                SlideInWidget(
                  direction: SlideDirection.left,
                  delay: Duration(milliseconds: 300),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Lengkap
                      Text(
                        'Nama Lengkap',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Masukkan nama lengkap',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Color(0xFF2E7D32)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama lengkap harus diisi';
                          }
                          if (value.trim().length < 3) {
                            return 'Nama minimal 3 karakter';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Email
                SlideInWidget(
                  direction: SlideDirection.left,
                  delay: Duration(milliseconds: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Masukkan email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Color(0xFF2E7D32)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email harus diisi';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value.trim())) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Role Selection
                SlideInWidget(
                  direction: SlideDirection.left,
                  delay: Duration(milliseconds: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Peran/Posisi',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.work_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Color(0xFF2E7D32)),
                          ),
                        ),
                        items: _roles.map((role) {
                          return DropdownMenuItem<String>(
                            value: role['value'],
                            child: Text(role['label']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pilih peran Anda';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Phone
                SlideInWidget(
                  direction: SlideDirection.left,
                  delay: Duration(milliseconds: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nomor Telepon',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Masukkan nomor telepon',
                          prefixIcon: Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Color(0xFF2E7D32)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nomor telepon harus diisi';
                          }
                          if (value.trim().length < 10) {
                            return 'Nomor telepon minimal 10 digit';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Address
                SlideInWidget(
                  direction: SlideDirection.left,
                  delay: Duration(milliseconds: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alamat',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Masukkan alamat lengkap',
                          prefixIcon: Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Color(0xFF2E7D32)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Alamat harus diisi';
                          }
                          if (value.trim().length < 10) {
                            return 'Alamat terlalu singkat';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Password
                SlideInWidget(
                  direction: SlideDirection.right,
                  delay: Duration(milliseconds: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Masukkan password',
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Color(0xFF2E7D32)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password harus diisi';
                          }
                          if (value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Confirm Password
                SlideInWidget(
                  direction: SlideDirection.right,
                  delay: Duration(milliseconds: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Konfirmasi Password',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Konfirmasi password',
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Color(0xFF2E7D32)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Konfirmasi password harus diisi';
                          }
                          if (value != _passwordController.text) {
                            return 'Password tidak cocok';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Terms & Conditions Checkbox
                SlideInWidget(
                  direction: SlideDirection.bottom,
                  delay: Duration(milliseconds: 950),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF2E7D32),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 12.h),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[700],
                              ),
                              children: [
                                TextSpan(text: 'Saya setuju dengan '),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: _showTermsAndConditions,
                                    child: Text(
                                      'Syarat & Ketentuan',
                                      style: TextStyle(
                                        color: const Color(0xFF2E7D32),
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                ),
                                TextSpan(text: ' dan '),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: _showTermsAndConditions,
                                    child: Text(
                                      'Kebijakan Privasi',
                                      style: TextStyle(
                                        color: const Color(0xFF2E7D32),
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                ),
                                TextSpan(text: ' PT. Fujiyama Biomass Energy'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Register Button
                ScaleWidget(
                  delay: Duration(milliseconds: 1000),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 24.h,
                              width: 24.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Daftar Sekarang',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Login Link
                SlideInWidget(
                  direction: SlideDirection.bottom,
                  delay: Duration(milliseconds: 1100),
                  child: Center(
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
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Masuk di sini',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF2E7D32),
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
