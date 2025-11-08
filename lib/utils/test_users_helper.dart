import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

class TestUsersHelper {
  static final _random = Random();

  static List<Map<String, String>> get testUsers => [
    {
      'name': 'Ahmad Prasetyo',
      'email': 'ahmad.prasetyo@fujiyama.com',
      'phone': '081234567890',
      'address': 'Jl. Raya Sawit No. 123, Jakarta',
      'role': 'admin',
      'password': 'admin123',
    },
    {
      'name': 'Siti Nurhaliza',
      'email': 'siti.nurhaliza@gmail.com',
      'phone': '081298765432',
      'address': 'Jl. Perkebunan Kelapa Sawit, Medan',
      'role': 'mitra_bisnis',
      'password': 'mitra123',
    },
    {
      'name': 'Budi Santoso',
      'email': 'budi.santoso@driver.com',
      'phone': '081356789012',
      'address': 'Jl. Logistik Raya No. 45, Surabaya',
      'role': 'driver',
      'password': 'driver123',
    },
    {
      'name': 'Dewi Kartika Sari',
      'email': 'dewi.kartika@mitra.com',
      'phone': '081445566778',
      'address': 'Komplek Bisnis Sawit, Pekanbaru',
      'role': 'mitra_bisnis',
      'password': 'dewi123',
    },
    {
      'name': 'Joko Widodo Logistik',
      'email': 'joko.widodo@transport.com',
      'phone': '081567890123',
      'address': 'Terminal Cargo Sawit, Palembang',
      'role': 'driver',
      'password': 'joko123',
    },
  ];

  /// Membuat semua test users sekaligus
  static Future<Map<String, dynamic>> createAllTestUsers() async {
    final results = <String, dynamic>{
      'success': [],
      'failed': [],
      'summary': '',
    };

    print('🚀 Starting batch creation of ${testUsers.length} test users...');

    for (int i = 0; i < testUsers.length; i++) {
      final user = testUsers[i];
      print('\n📝 Creating user ${i + 1}/${testUsers.length}: ${user['name']}');

      try {
        final result = await createSingleTestUser(
          name: user['name']!,
          email: user['email']!,
          phone: user['phone']!,
          address: user['address']!,
          role: user['role']!,
          password: user['password']!,
        );

        if (result['success']) {
          results['success'].add({
            'name': user['name'],
            'email': user['email'],
            'role': user['role'],
          });
          print('✅ Success: ${user['name']}');
        } else {
          results['failed'].add({
            'name': user['name'],
            'email': user['email'],
            'error': result['error'],
          });
          print('❌ Failed: ${user['name']} - ${result['error']}');
        }
      } catch (e) {
        results['failed'].add({
          'name': user['name'],
          'email': user['email'],
          'error': e.toString(),
        });
        print('❌ Exception for ${user['name']}: $e');
      }

      // Small delay to avoid rate limiting
      if (i < testUsers.length - 1) {
        await Future.delayed(Duration(seconds: 1));
      }
    }

    final successCount = results['success'].length;
    final failedCount = results['failed'].length;

    results['summary'] =
        '''
🎯 Test Users Creation Summary:
✅ Success: $successCount users
❌ Failed: $failedCount users
📊 Total: ${successCount + failedCount} users processed

Successful users:
${(results['success'] as List).map((u) => '• ${u['name']} (${u['role']}) - ${u['email']}').join('\n')}

${failedCount > 0 ? '''
Failed users:
${(results['failed'] as List).map((u) => '• ${u['name']} - ${u['error']}').join('\n')}
''' : ''}
''';

    print('\n' + results['summary']);
    return results;
  }

  /// Membuat satu test user dengan data lengkap
  static Future<Map<String, dynamic>> createSingleTestUser({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String role,
    required String password,
  }) async {
    try {
      final supabase = Supabase.instance.client;

      print('📝 Registering: $name ($email)');

      // 1. Sign up user
      final AuthResponse authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'display_name': name,
          'phone': phone,
          'role': role,
        },
      );

      if (authResponse.user == null) {
        return {
          'success': false,
          'error': 'Auth signup failed - no user returned',
        };
      }

      final userId = authResponse.user!.id;
      print('✅ Auth created with ID: $userId');

      // 2. Create/update profile
      final profileData = {
        'id': userId,
        'email': email,
        'full_name': name,
        'phone': phone,
        'address': address,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await supabase.from('profiles').upsert(profileData);
      print('✅ Profile created');

      // 3. Update user metadata
      try {
        await supabase.auth.updateUser(
          UserAttributes(
            data: {
              'full_name': name,
              'display_name': name,
              'phone': phone,
              'role': role,
            },
          ),
        );
        print('✅ User metadata updated');
      } catch (updateError) {
        print('⚠️  Metadata update failed (non-critical): $updateError');
      }

      return {
        'success': true,
        'userId': userId,
        'message': 'User $name created successfully',
      };
    } catch (e) {
      print('❌ Error creating $name: $e');

      // Check if it's just duplicate email
      if (e.toString().toLowerCase().contains('already') ||
          e.toString().toLowerCase().contains('duplicate') ||
          e.toString().toLowerCase().contains('exists')) {
        return {'success': false, 'error': 'Email already exists'};
      }

      return {'success': false, 'error': e.toString()};
    }
  }

  /// Generate random test user
  static Map<String, String> generateRandomTestUser() {
    final names = [
      'Ahmad',
      'Siti',
      'Budi',
      'Dewi',
      'Joko',
      'Maya',
      'Andi',
      'Rina',
    ];
    final surnames = [
      'Prasetyo',
      'Nurhaliza',
      'Santoso',
      'Kartika',
      'Widodo',
      'Sari',
      'Wijaya',
      'Putri',
    ];
    final domains = ['gmail.com', 'yahoo.com', 'hotmail.com', 'fujiyama.com'];
    final roles = ['mitra_bisnis', 'driver'];

    final name =
        '${names[_random.nextInt(names.length)]} ${surnames[_random.nextInt(surnames.length)]}';
    final email =
        '${name.toLowerCase().replaceAll(' ', '.')}.${_random.nextInt(999)}@${domains[_random.nextInt(domains.length)]}';
    final role = roles[_random.nextInt(roles.length)];

    return {
      'name': name,
      'email': email,
      'phone': '081${_random.nextInt(900000000) + 100000000}',
      'address': 'Jl. Test ${_random.nextInt(100) + 1}, Indonesia',
      'role': role,
      'password': 'test123',
    };
  }

  /// Show test users info in dialog
  static void showTestUsersInfo() {
    print('📋 Available Test Users:');
    print('=' * 50);

    for (int i = 0; i < testUsers.length; i++) {
      final user = testUsers[i];
      print('${i + 1}. ${user['name']} (${user['role']?.toUpperCase()})');
      print('   📧 ${user['email']}');
      print('   🔑 ${user['password']}');
      print('   📱 ${user['phone']}');
      print('   📍 ${user['address']}');
      print('');
    }

    print('💡 Tip: Gunakan email dan password di atas untuk login testing');
  }
}
