import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Widget untuk debug dan test database connection
class DatabaseDebugWidget extends StatefulWidget {
  const DatabaseDebugWidget({super.key});

  @override
  State<DatabaseDebugWidget> createState() => _DatabaseDebugWidgetState();
}

class _DatabaseDebugWidgetState extends State<DatabaseDebugWidget> {
  String _debugInfo = 'Initializing...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkDatabaseConnection();
  }

  Future<void> _checkDatabaseConnection() async {
    setState(() {
      _isLoading = true;
      _debugInfo = '🔄 Checking database connection...';
    });

    try {
      final supabase = Supabase.instance.client;

      // Test 1: Check connection
      await supabase.from('roles').select('id').limit(1);

      String info = '✅ Database connection: OK\n';
      info += '📊 Roles table accessible\n';

      // Test 2: Check roles
      final roles = await supabase.from('roles').select('id, name');
      info += '🏷️ Available roles:\n';
      for (final role in roles) {
        info += '   - ${role['name']} (ID: ${role['id']})\n';
      }

      // Test 3: Check profiles
      final profiles = await supabase
          .from('profiles')
          .select('email, full_name, roles(name)')
          .limit(10);

      info += '\n👥 Test users (max 10):\n';
      if (profiles.isEmpty) {
        info += '   ⚠️ No users found - need to create test users\n';
      } else {
        for (final profile in profiles) {
          final email = profile['email'];
          final role = profile['roles']?['name'] ?? 'No role';
          info += '   - $email ($role)\n';
        }
      }

      // Test 4: Check authentication
      final currentUser = supabase.auth.currentUser;
      if (currentUser != null) {
        info += '\n🔐 Current user: ${currentUser.email}\n';
      } else {
        info += '\n🔐 No user logged in\n';
      }

      setState(() {
        _debugInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _debugInfo = '❌ Database error:\n$e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testCreateUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      // Test creating a simple user
      final testEmail =
          'test_${DateTime.now().millisecondsSinceEpoch}@fujiyama.com';

      final authResponse = await supabase.auth.signUp(
        email: testEmail,
        password: 'test123',
      );

      if (authResponse.user != null) {
        await supabase.from('profiles').insert({
          'id': authResponse.user!.id,
          'email': testEmail,
          'full_name': 'Test User',
          'role_id': 1,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Clean up - sign out
        await supabase.auth.signOut();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Test user created: $testEmail'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh debug info
        _checkDatabaseConnection();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to create test user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Debug'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _checkDatabaseConnection,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Database Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (_isLoading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        _debugInfo,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _checkDatabaseConnection,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testCreateUser,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Test Create User'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
