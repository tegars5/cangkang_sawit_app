import 'package:supabase_flutter/supabase_flutter.dart';

/// Utility untuk memaksa membuat test users dengan cara yang lebih direct
class ForceUserCreator {
  static final _supabase = Supabase.instance.client;

  /// Force create test users dengan method yang lebih aggressive
  static Future<Map<String, dynamic>> forceCreateTestUsers() async {
    final results = <String, dynamic>{
      'success': false,
      'message': '',
      'details': <String>[],
      'errors': <String>[],
    };

    try {
      results['details'].add('🔄 Starting force user creation...');

      // Step 1: Pastikan roles ada
      await _forceCreateRoles();
      results['details'].add('✅ Roles ensured');

      // Step 2: Buat users dengan force mode
      final users = [
        {
          'email': 'admin@fujiyama.com',
          'password': 'password123',
          'fullName': 'Administrator System',
          'roleId': 1,
        },
        {
          'email': 'mitra@fujiyama.com',
          'password': 'password123',
          'fullName': 'Mitra Bisnis Partner',
          'roleId': 2,
        },
        {
          'email': 'driver@fujiyama.com',
          'password': 'password123',
          'fullName': 'Driver Logistik',
          'roleId': 3,
        },
      ];

      int successCount = 0;
      for (final userData in users) {
        try {
          final created = await _forceCreateSingleUser(userData);
          if (created) {
            successCount++;
            results['details'].add('✅ Created: ${userData['email']}');
          } else {
            results['details'].add('👤 Already exists: ${userData['email']}');
          }
        } catch (e) {
          results['errors'].add('❌ Failed ${userData['email']}: $e');
        }
      }

      // Step 3: Verify users
      final verification = await _verifyAllUsers();
      results['details'].addAll(verification);

      results['success'] = successCount > 0 || verification.isNotEmpty;
      results['message'] = successCount > 0
          ? 'Successfully created $successCount users'
          : 'All users already exist and verified';
    } catch (e) {
      results['success'] = false;
      results['message'] = 'Fatal error: $e';
      results['errors'].add('💥 Fatal: $e');
    }

    return results;
  }

  /// Force create roles with direct SQL-like approach
  static Future<void> _forceCreateRoles() async {
    final requiredRoles = [
      {'id': 1, 'name': 'Admin'},
      {'id': 2, 'name': 'Mitra Bisnis'},
      {'id': 3, 'name': 'Logistik'},
    ];

    for (final role in requiredRoles) {
      try {
        // Use upsert to force creation
        await _supabase.from('roles').upsert({
          'id': role['id'],
          'name': role['name'],
          'created_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        // Ignore errors, role might exist
        print('Role ${role['name']} error (might exist): $e');
      }
    }
  }

  /// Force create single user dengan berbagai fallback methods
  static Future<bool> _forceCreateSingleUser(
    Map<String, dynamic> userData,
  ) async {
    final email = userData['email'] as String;
    final password = userData['password'] as String;
    final fullName = userData['fullName'] as String;
    final roleId = userData['roleId'] as int;

    try {
      // Method 1: Try to sign in first (check if exists)
      try {
        final existingAuth = await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (existingAuth.user != null) {
          // User exists in auth, ensure profile exists
          await _supabase.from('profiles').upsert({
            'id': existingAuth.user!.id,
            'email': email,
            'full_name': fullName,
            'role_id': roleId,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });

          await _supabase.auth.signOut();
          return false; // Already existed
        }
      } catch (authError) {
        // User doesn't exist or password wrong, continue to create
      }

      // Method 2: Create new user
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role_id': roleId},
      );

      if (authResponse.user != null) {
        // Force create profile
        await _supabase.from('profiles').upsert({
          'id': authResponse.user!.id,
          'email': email,
          'full_name': fullName,
          'role_id': roleId,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        await _supabase.auth.signOut();
        return true; // Successfully created
      }

      throw Exception('Failed to create auth user');
    } catch (e) {
      throw Exception('Force create failed for $email: $e');
    }
  }

  /// Verify all test users exist and have correct data
  static Future<List<String>> _verifyAllUsers() async {
    final results = <String>[];

    try {
      final profiles = await _supabase
          .from('profiles')
          .select('email, full_name, role_id, roles(name)')
          .inFilter('email', [
            'admin@fujiyama.com',
            'mitra@fujiyama.com',
            'driver@fujiyama.com',
          ]);

      results.add('📊 Found ${profiles.length} test users in profiles:');

      for (final profile in profiles) {
        final email = profile['email'];
        final role = profile['roles']?['name'] ?? 'No role';
        results.add('   ✓ $email -> $role');
      }

      if (profiles.length < 3) {
        results.add('⚠️ Missing some test users!');
      }
    } catch (e) {
      results.add('❌ Verification failed: $e');
    }

    return results;
  }

  /// Get database status for debugging
  static Future<Map<String, dynamic>> getDatabaseStatus() async {
    final status = <String, dynamic>{
      'connected': false,
      'roles_count': 0,
      'profiles_count': 0,
      'current_user': null,
      'errors': <String>[],
    };

    try {
      // Test connection
      final rolesData = await _supabase.from('roles').select('id, name');
      status['connected'] = true;
      status['roles_count'] = rolesData.length;

      final profilesData = await _supabase.from('profiles').select('email');
      status['profiles_count'] = profilesData.length;

      final currentUser = _supabase.auth.currentUser;
      status['current_user'] = currentUser?.email;
    } catch (e) {
      status['errors'].add(e.toString());
    }

    return status;
  }
}
