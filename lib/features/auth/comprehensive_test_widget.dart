import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/force_user_creator.dart';
import '../../utils/test_user_creator.dart';
import '../../widgets/lottie_animations.dart';
import '../../debug/animation_test_screen.dart';

/// Widget untuk comprehensive testing dan debugging
class ComprehensiveTestWidget extends StatefulWidget {
  const ComprehensiveTestWidget({super.key});

  @override
  State<ComprehensiveTestWidget> createState() =>
      _ComprehensiveTestWidgetState();
}

class _ComprehensiveTestWidgetState extends State<ComprehensiveTestWidget> {
  String _statusText = 'Ready for testing...';
  bool _isLoading = false;
  List<String> _testResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comprehensive Test'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[600]),
                        SizedBox(width: 8.w),
                        Text(
                          'Test Status',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (_isLoading)
                          SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        _statusText,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Action Buttons
            Text(
              'Test Actions',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),

            // Row 1
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testDatabaseConnection,
                    icon: const Icon(Icons.wifi_find),
                    label: const Text('Test DB'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _normalCreateUsers,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Normal Create'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Row 2
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _forceCreateUsers,
                    icon: const Icon(Icons.build),
                    label: const Text('Force Create'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testLoginFlow,
                    icon: const Icon(Icons.login),
                    label: const Text('Test Login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Results
            Text(
              'Test Results',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),

            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: ListView.builder(
                    itemCount: _testResults.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        child: Text(
                          _testResults[index],
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11.sp,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Professional Create Users Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _createTestUsersWithAnimation,
                icon: const Icon(Icons.group_add),
                label: const Text('Create Test Users (Professional)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Test Professional Animations Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AnimationTestScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.animation),
                label: const Text('Test Professional Animations'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Clear button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _testResults.clear();
                    _statusText = 'Ready for testing...';
                  });
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Results'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addResult(String message) {
    setState(() {
      _testResults.add(
        '${DateTime.now().toString().substring(11, 19)} $message',
      );
    });
  }

  Future<void> _testDatabaseConnection() async {
    setState(() {
      _isLoading = true;
      _statusText = 'Testing database connection...';
    });

    try {
      _addResult('🔄 Testing database connection...');

      final status = await ForceUserCreator.getDatabaseStatus();

      if (status['connected']) {
        _addResult('✅ Database connected successfully');
        _addResult('📊 Roles found: ${status['roles_count']}');
        _addResult('👥 Profiles found: ${status['profiles_count']}');

        if (status['current_user'] != null) {
          _addResult('🔐 Current user: ${status['current_user']}');
        } else {
          _addResult('🔐 No user currently logged in');
        }

        setState(() {
          _statusText = 'Database connection: ✅ OK';
        });
      } else {
        _addResult('❌ Database connection failed');
        for (final error in status['errors']) {
          _addResult('   Error: $error');
        }
        setState(() {
          _statusText = 'Database connection: ❌ FAILED';
        });
      }
    } catch (e) {
      _addResult('💥 Fatal database error: $e');
      setState(() {
        _statusText = 'Database error: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _normalCreateUsers() async {
    setState(() {
      _isLoading = true;
      _statusText = 'Creating users (normal method)...';
    });

    try {
      _addResult('🔄 Starting normal user creation...');
      await TestUserCreator.createAllTestUsers();
      _addResult('✅ Normal user creation completed');

      setState(() {
        _statusText = 'Normal user creation: ✅ DONE';
      });
    } catch (e) {
      _addResult('❌ Normal user creation failed: $e');
      setState(() {
        _statusText = 'Normal creation error: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _forceCreateUsers() async {
    setState(() {
      _isLoading = true;
      _statusText = 'Force creating users...';
    });

    try {
      _addResult('🔄 Starting force user creation...');

      final results = await ForceUserCreator.forceCreateTestUsers();

      for (final detail in results['details']) {
        _addResult(detail);
      }

      for (final error in results['errors']) {
        _addResult(error);
      }

      if (results['success']) {
        _addResult('✅ Force creation completed: ${results['message']}');
        setState(() {
          _statusText = 'Force creation: ✅ SUCCESS';
        });

        // Show professional success animation
        await LottieSuccessDialog.show(
          context,
          title: 'Success!',
          message: 'Test users berhasil dibuat dengan force method!',
        );
      } else {
        _addResult('❌ Force creation failed: ${results['message']}');
        setState(() {
          _statusText = 'Force creation: ❌ FAILED';
        });

        LottieSnackbar.showError(
          context,
          message: 'Force creation failed: ${results['message']}',
        );
      }
    } catch (e) {
      _addResult('💥 Force creation fatal error: $e');
      setState(() {
        _statusText = 'Force creation error: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testLoginFlow() async {
    setState(() {
      _isLoading = true;
      _statusText = 'Testing login flow...';
    });

    // This would test login without navigating away
    _addResult('🔄 Testing login credentials...');
    _addResult('📧 Testing: admin@fujiyama.com');
    _addResult('🔒 Testing: password123');

    // Add login test logic here
    _addResult('⚠️ Login test not implemented yet');
    _addResult('👉 Use main login screen to test');

    setState(() {
      _statusText = 'Login test: ⚠️ Use main screen';
      _isLoading = false;
    });
  }

  /// Create test users dengan professional animation
  Future<void> _createTestUsersWithAnimation() async {
    setState(() {
      _isLoading = true;
      _statusText = 'Creating test users...';
    });

    try {
      _addResult('🔄 Starting professional user creation...');

      // Use the professional UI method from TestUserCreator
      await TestUserCreator.createAllTestUsersWithUI(context);

      _addResult('✅ Professional user creation completed!');
      setState(() {
        _statusText = 'Professional creation: ✅ SUCCESS';
      });
    } catch (e) {
      _addResult('❌ Professional creation error: $e');
      setState(() {
        _statusText = 'Professional creation: ❌ ERROR';
      });

      LottieSnackbar.showError(context, message: 'Error creating users: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }
}
