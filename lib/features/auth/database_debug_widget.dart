import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseDebugWidget extends StatefulWidget {
  const DatabaseDebugWidget({super.key});

  @override
  State<DatabaseDebugWidget> createState() => _DatabaseDebugWidgetState();
}

class _DatabaseDebugWidgetState extends State<DatabaseDebugWidget> {
  String _output = '';

  Future<void> _checkMitraUser() async {
    setState(() {
      _output = 'Checking mitra user...\n';
    });

    try {
      // Check if mitra@fujiyama.com exists in auth
      final users = await Supabase.instance.client.auth.admin.listUsers();
      final mitraAuthUser = users.firstWhere(
        (user) => user.email == 'mitra@fujiyama.com',
        orElse: () => throw Exception('Mitra user not found in auth'),
      );

      setState(() {
        _output += '✅ Mitra user found in auth: ${mitraAuthUser.id}\n';
      });

      // Check profile
      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select('*, roles(*)')
          .eq('id', mitraAuthUser.id)
          .maybeSingle();

      setState(() {
        _output += '📋 Profile data: $profileResponse\n';
      });

      if (profileResponse != null) {
        final roleName =
            profileResponse['roles']?['name'] ??
            profileResponse['roles']?['nama'] ??
            'No role found';
        setState(() {
          _output += '🎭 Role name: "$roleName"\n';
          _output +=
              '🔍 Role contains mitra: ${roleName.toLowerCase().contains('mitra')}\n';
        });
      } else {
        setState(() {
          _output += '❌ No profile found for mitra user\n';
        });
      }

      // Check all roles table
      final rolesResponse = await Supabase.instance.client
          .from('roles')
          .select('*');

      setState(() {
        _output += '📝 All roles in database:\n';
        for (var role in rolesResponse) {
          _output += '  - ID: ${role['id']}, Name: "${role['name']}"\n';
        }
      });
    } catch (e) {
      setState(() {
        _output += '❌ Error: $e\n';
      });
    }
  }

  Future<void> _createMitraIfNeeded() async {
    setState(() {
      _output = 'Creating/fixing mitra user...\n';
    });

    try {
      // First ensure roles exist
      final rolesCheck = await Supabase.instance.client
          .from('roles')
          .select('*')
          .eq('name', 'Mitra Bisnis');

      if (rolesCheck.isEmpty) {
        await Supabase.instance.client.from('roles').insert({
          'id': 2,
          'name': 'Mitra Bisnis',
        });
        setState(() {
          _output += '✅ Created Mitra Bisnis role\n';
        });
      }

      // Try to create auth user
      try {
        final authResponse = await Supabase.instance.client.auth.signUp(
          email: 'mitra@fujiyama.com',
          password: 'password123',
        );

        if (authResponse.user != null) {
          // Create profile
          await Supabase.instance.client.from('profiles').insert({
            'id': authResponse.user!.id,
            'full_name': 'Mitra Test User',
            'role_id': 2,
          });

          setState(() {
            _output += '✅ Created mitra user with profile\n';
          });
        }
      } catch (e) {
        setState(() {
          _output += '⚠️ User might already exist: $e\n';
        });
      }

      // Now check the user again
      await _checkMitraUser();
    } catch (e) {
      setState(() {
        _output += '❌ Error creating user: $e\n';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Debug'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: _checkMitraUser,
                  child: const Text('Check Mitra User'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _createMitraIfNeeded,
                  child: const Text('Create/Fix Mitra'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _output.isEmpty
                        ? 'Click buttons above to debug...'
                        : _output,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
