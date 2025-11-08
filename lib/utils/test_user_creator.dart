import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../widgets/lottie_animations.dart';

/// Helper class untuk membuat test users untuk development
class TestUserCreator {
  static final _supabase = Supabase.instance.client;

  /// Membuat semua test users untuk development
  static Future<void> createAllTestUsers() async {
    try {
      print('🔄 Membuat test users...');

      // Pastikan roles sudah ada
      await _ensureRolesExist();

      // 1. Admin User
      await _createTestUser(
        email: 'admin@fujiyama.com',
        password: 'password123',
        fullName: 'Administrator System',
        roleId: 1, // Admin role
      );

      // 2. Mitra Bisnis User
      await _createTestUser(
        email: 'mitra@fujiyama.com',
        password: 'password123',
        fullName: 'Mitra Bisnis Partner',
        roleId: 2, // Mitra Bisnis role
      );

      // 3. Driver/Logistik User
      await _createTestUser(
        email: 'driver@fujiyama.com',
        password: 'password123',
        fullName: 'Driver Logistik',
        roleId: 3, // Logistik role
      );

      print('✅ Semua test users berhasil dibuat!');
      print('📧 Login credentials:');
      print('   Admin: admin@fujiyama.com / password123');
      print('   Mitra: mitra@fujiyama.com / password123');
      print('   Driver: driver@fujiyama.com / password123');
    } catch (e) {
      print('❌ Error creating test users: $e');
      rethrow;
    }
  }

  /// Membuat test users dengan UI feedback professional
  static Future<void> createAllTestUsersWithUI(BuildContext context) async {
    try {
      // Show loading animation
      await LottieLoadingDialog.show(
        context,
        message: 'Membuat test users...',
        future: createAllTestUsers(),
      );

      // Show success animation
      await LottieSuccessDialog.show(
        context,
        title: 'Success!',
        message:
            'Semua test users berhasil dibuat!\n\nLogin:\n• admin@fujiyama.com\n• mitra@fujiyama.com\n• driver@fujiyama.com\n\nPassword: password123',
      );
    } catch (e) {
      LottieSnackbar.showError(
        context,
        message: 'Error membuat test users: $e',
      );
    }
  }

  /// Pastikan roles ada di database
  static Future<void> _ensureRolesExist() async {
    try {
      // Cek apakah roles sudah ada
      final roles = await _supabase.from('roles').select('id, name');

      final existingRoles = <String, int>{};
      for (final role in roles) {
        existingRoles[role['name']] = role['id'];
      }

      // Buat roles yang belum ada
      final requiredRoles = [
        {'id': 1, 'name': 'Admin'},
        {'id': 2, 'name': 'Mitra Bisnis'},
        {'id': 3, 'name': 'Logistik'},
      ];

      for (final roleData in requiredRoles) {
        if (!existingRoles.containsValue(roleData['id'])) {
          try {
            await _supabase.from('roles').upsert({
              'id': roleData['id'],
              'name': roleData['name'],
              'created_at': DateTime.now().toIso8601String(),
            });
            print('✅ Role ${roleData['name']} created');
          } catch (e) {
            print('⚠️ Role ${roleData['name']} might already exist: $e');
          }
        }
      }
    } catch (e) {
      print('⚠️ Error ensuring roles exist: $e');
    }
  }

  /// Membuat individual test user
  static Future<void> _createTestUser({
    required String email,
    required String password,
    required String fullName,
    required int roleId,
  }) async {
    try {
      // Cek apakah user sudah ada di auth
      try {
        final signInResult = await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (signInResult.user != null) {
          // User sudah ada dan bisa login, cek profile
          final profile = await _supabase
              .from('profiles')
              .select('*')
              .eq('id', signInResult.user!.id)
              .maybeSingle();

          if (profile == null) {
            // Profile tidak ada, buat profile
            await _supabase.from('profiles').insert({
              'id': signInResult.user!.id,
              'email': email,
              'full_name': fullName,
              'role_id': roleId,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
            print('✅ Profile untuk $email berhasil dibuat');
          } else {
            print('👤 User $email sudah ada dan lengkap');
          }

          // Sign out user setelah pengecekan
          await _supabase.auth.signOut();
          return;
        }
      } catch (authError) {
        // User belum ada atau credentials salah, lanjut buat user baru
        print('🔄 Creating new user for $email...');
      }

      // 1. Create user via Supabase Auth
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role_id': roleId},
      );

      if (authResponse.user != null) {
        // 2. Insert profile data (dengan upsert untuk safety)
        await _supabase.from('profiles').upsert({
          'id': authResponse.user!.id,
          'email': email,
          'full_name': fullName,
          'role_id': roleId,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        print('✅ User $email berhasil dibuat');

        // Sign out user setelah dibuat
        await _supabase.auth.signOut();
      } else {
        throw Exception('Failed to create auth user');
      }
    } catch (e) {
      print('❌ Error creating user $email: $e');
      // Continue creating other users even if one fails
    }
  }

  /// Hapus semua test users (untuk cleanup)
  static Future<void> deleteAllTestUsers() async {
    try {
      print('🔄 Menghapus test users...');

      final testEmails = [
        'admin@fujiyama.com',
        'mitra@fujiyama.com',
        'driver@fujiyama.com',
      ];

      for (final email in testEmails) {
        try {
          // Note: Supabase Auth deletion biasanya dilakukan via Admin API
          // Untuk development, kita bisa delete dari profiles table
          await _supabase.from('profiles').delete().eq('email', email);

          print('🗑️ Deleted profile for $email');
        } catch (e) {
          print('⚠️ Could not delete $email: $e');
        }
      }

      print('✅ Cleanup completed');
    } catch (e) {
      print('❌ Error during cleanup: $e');
    }
  }

  /// Verify test users exist and have correct roles
  static Future<void> verifyTestUsers() async {
    try {
      print('🔍 Verifying test users...');

      final profiles = await _supabase
          .from('profiles')
          .select('email, full_name, role_id, roles(name)')
          .inFilter('email', [
            'admin@fujiyama.com',
            'mitra@fujiyama.com',
            'driver@fujiyama.com',
          ]);

      if (profiles.isEmpty) {
        print('❌ No test users found');
        return;
      }

      for (final profile in profiles) {
        final email = profile['email'];
        final roleName = profile['roles']?['name'] ?? 'Unknown';
        print('👤 $email -> Role: $roleName');
      }

      print('✅ Verification completed');
    } catch (e) {
      print('❌ Error verifying users: $e');
    }
  }
}
