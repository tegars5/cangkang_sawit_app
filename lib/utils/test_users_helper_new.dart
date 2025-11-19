import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Helper untuk membuat test users secara otomatis
class TestUsersHelper {
  static Future<void> createTestUsers() async {
    try {
      print('🔧 Creating test users...');

      // List of test users
      final testUsers = [
        {
          'email': 'admin@fujiyama.com',
          'password': 'password123',
          'fullName': 'Administrator',
          'role': 'admin',
        },
        {
          'email': 'mitra@fujiyama.com',
          'password': 'password123',
          'fullName': 'Mitra Bisnis',
          'role': 'customer', // Mitra is a type of customer
        },
        {
          'email': 'logistik@fujiyama.com',
          'password': 'password123',
          'fullName': 'Driver Logistik',
          'role': 'driver',
        },
      ];

      for (final user in testUsers) {
        try {
          print('📝 Creating user: ${user['email']}');

          // Create user in auth
          final authResponse = await Supabase.instance.client.auth.signUp(
            email: user['email']!,
            password: user['password']!,
          );

          if (authResponse.user != null) {
            print('✅ Auth user created: ${authResponse.user!.id}');

            // Create profile with role enum
            await Supabase.instance.client.from('profiles').insert({
              'id': authResponse.user!.id,
              'full_name': user['fullName']!,
              'email': user['email']!,
              'role': user['role']!, // Use role enum directly
            });

            print('✅ Profile created for: ${user['email']}');
          }
        } catch (e) {
          print('⚠️ Error creating user ${user['email']}: $e');
          // Continue with next user
        }
      }

      print('🎉 Test users setup completed!');
    } catch (e) {
      print('❌ Error in test users setup: $e');
    }
  }

  /// Widget untuk tombol create test users (untuk development)
  static Widget buildTestUsersButton() {
    return ElevatedButton(
      onPressed: createTestUsers,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      child: const Text('Create Test Users'),
    );
  }

  /// Cek apakah user sudah ada
  static Future<bool> checkIfUserExists(String email) async {
    try {
      await Supabase.instance.client
          .from('profiles')
          .select('id')
          .eq('email', email)
          .single();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Create roles if not exist
  static Future<void> setupRoles() async {
    try {
      print('🔧 Setting up roles...');

      final roles = [
        {'name': 'Admin', 'description': 'Administrator with full access'},
        {
          'name': 'Mitra Bisnis',
          'description': 'Business partners who can place orders',
        },
        {
          'name': 'Logistik',
          'description': 'Drivers for delivery and GPS tracking',
        },
      ];

      for (final role in roles) {
        try {
          await Supabase.instance.client.from('roles').insert(role);
          print('✅ Role created: ${role['name']}');
        } catch (e) {
          print('⚠️ Role ${role['name']} might already exist: $e');
        }
      }

      print('🎉 Roles setup completed!');
    } catch (e) {
      print('❌ Error setting up roles: $e');
    }
  }
}
