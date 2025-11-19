import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/common/common_widgets.dart';

/// Admin Settings Page - System settings and configuration
class AdminSettingsPage extends ConsumerStatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  ConsumerState<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends ConsumerState<AdminSettingsPage> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _autoAssignOrders = false;
  bool _requirePhotoProof = true;
  bool _enableGPSTracking = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Show help
            },
            icon: Icon(Icons.help_outline, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            InfoCard(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40.r,
                    backgroundColor: const Color(0xFF1B5E20).withOpacity(0.1),
                    child: Text(
                      'AD',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1B5E20),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Admin System',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'admin@cangkangsawit.com',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16.h),
                  SecondaryButton(
                    text: 'Edit Profile',
                    onPressed: () {
                      // TODO: Edit profile
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // System Settings
            _buildSectionTitle('System Settings'),
            SizedBox(height: 12.h),

            _buildSettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Push Notifications',
              subtitle: 'Receive push notifications for new orders',
              isSwitch: true,
              switchValue: _pushNotifications,
              onSwitchChanged: (value) {
                setState(() {
                  _pushNotifications = value;
                });
              },
            ),

            _buildSettingsTile(
              icon: Icons.email_outlined,
              title: 'Email Notifications',
              subtitle: 'Receive email alerts for important updates',
              isSwitch: true,
              switchValue: _emailNotifications,
              onSwitchChanged: (value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
            ),

            _buildSettingsTile(
              icon: Icons.auto_mode_outlined,
              title: 'Auto Assign Orders',
              subtitle: 'Automatically assign orders to available drivers',
              isSwitch: true,
              switchValue: _autoAssignOrders,
              onSwitchChanged: (value) {
                setState(() {
                  _autoAssignOrders = value;
                });
              },
            ),

            SizedBox(height: 20.h),

            // Delivery Settings
            _buildSectionTitle('Delivery Settings'),
            SizedBox(height: 12.h),

            _buildSettingsTile(
              icon: Icons.camera_alt_outlined,
              title: 'Photo Proof Required',
              subtitle: 'Require drivers to upload delivery photos',
              isSwitch: true,
              switchValue: _requirePhotoProof,
              onSwitchChanged: (value) {
                setState(() {
                  _requirePhotoProof = value;
                });
              },
            ),

            _buildSettingsTile(
              icon: Icons.gps_fixed_outlined,
              title: 'GPS Tracking',
              subtitle: 'Enable real-time GPS tracking for shipments',
              isSwitch: true,
              switchValue: _enableGPSTracking,
              onSwitchChanged: (value) {
                setState(() {
                  _enableGPSTracking = value;
                });
              },
            ),

            _buildSettingsTile(
              icon: Icons.schedule_outlined,
              title: 'Delivery Time Slots',
              subtitle: 'Manage available delivery time slots',
              onTap: () {
                // TODO: Show time slots settings
              },
            ),

            _buildSettingsTile(
              icon: Icons.location_on_outlined,
              title: 'Delivery Zones',
              subtitle: 'Configure delivery zones and pricing',
              onTap: () {
                // TODO: Show delivery zones
              },
            ),

            SizedBox(height: 20.h),

            // Business Settings
            _buildSectionTitle('Business Settings'),
            SizedBox(height: 12.h),

            _buildSettingsTile(
              icon: Icons.business_outlined,
              title: 'Company Information',
              subtitle: 'Update company details and branding',
              onTap: () {
                // TODO: Show company settings
              },
            ),

            _buildSettingsTile(
              icon: Icons.attach_money_outlined,
              title: 'Pricing & Rates',
              subtitle: 'Manage product pricing and delivery rates',
              onTap: () {
                // TODO: Show pricing settings
              },
            ),

            _buildSettingsTile(
              icon: Icons.inventory_2_outlined,
              title: 'Product Categories',
              subtitle: 'Manage product types and categories',
              onTap: () {
                // TODO: Show product categories
              },
            ),

            _buildSettingsTile(
              icon: Icons.warehouse_outlined,
              title: 'Warehouses',
              subtitle: 'Manage warehouse locations and capacity',
              onTap: () {
                // TODO: Show warehouses
              },
            ),

            SizedBox(height: 20.h),

            // Reports & Analytics
            _buildSectionTitle('Reports & Analytics'),
            SizedBox(height: 12.h),

            _buildSettingsTile(
              icon: Icons.bar_chart_outlined,
              title: 'Sales Reports',
              subtitle: 'View detailed sales and revenue reports',
              onTap: () {
                // TODO: Show sales reports
              },
            ),

            _buildSettingsTile(
              icon: Icons.trending_up_outlined,
              title: 'Performance Analytics',
              subtitle: 'Driver and delivery performance metrics',
              onTap: () {
                // TODO: Show analytics
              },
            ),

            _buildSettingsTile(
              icon: Icons.download_outlined,
              title: 'Export Data',
              subtitle: 'Export orders, drivers, and analytics data',
              onTap: () {
                // TODO: Show export options
              },
            ),

            SizedBox(height: 20.h),

            // Security & Privacy
            _buildSectionTitle('Security & Privacy'),
            SizedBox(height: 12.h),

            _buildSettingsTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Update your account password',
              onTap: () {
                _showChangePasswordDialog();
              },
            ),

            _buildSettingsTile(
              icon: Icons.security_outlined,
              title: 'Two-Factor Authentication',
              subtitle: 'Add an extra layer of security',
              onTap: () {
                // TODO: Show 2FA setup
              },
            ),

            _buildSettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'View our privacy policy and terms',
              onTap: () {
                // TODO: Show privacy policy
              },
            ),

            SizedBox(height: 20.h),

            // Support & Help
            _buildSectionTitle('Support & Help'),
            SizedBox(height: 12.h),

            _buildSettingsTile(
              icon: Icons.help_outline,
              title: 'Help Center',
              subtitle: 'Get help and support',
              onTap: () {
                // TODO: Show help center
              },
            ),

            _buildSettingsTile(
              icon: Icons.bug_report_outlined,
              title: 'Report Issue',
              subtitle: 'Report bugs or technical issues',
              onTap: () {
                // TODO: Show bug report
              },
            ),

            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'App version and information',
              onTap: () {
                _showAboutDialog();
              },
            ),

            SizedBox(height: 30.h),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showLogoutDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isSwitch = false,
    bool? switchValue,
    Function(bool)? onSwitchChanged,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        leading: Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: const Color(0xFF1B5E20).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: const Color(0xFF1B5E20), size: 20.sp),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
        trailing: isSwitch
            ? Switch(
                value: switchValue ?? false,
                onChanged: onSwitchChanged,
                activeColor: const Color(0xFF1B5E20),
              )
            : Icon(Icons.chevron_right, color: Colors.grey[400], size: 20.sp),
        onTap: onTap,
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement change password
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password changed successfully'),
                  backgroundColor: Color(0xFF1B5E20),
                ),
              );
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Cangkang Sawit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cangkang Sawit Management System',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text('Version: 1.0.0'),
            Text('Build: 2024.05.23'),
            const SizedBox(height: 12),
            Text(
              'A comprehensive system for managing palm kernel shell logistics and delivery operations.',
              style: TextStyle(fontSize: 12.sp),
            ),
            const SizedBox(height: 12),
            Text(
              '© 2024 Cangkang Sawit. All rights reserved.',
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement logout
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
