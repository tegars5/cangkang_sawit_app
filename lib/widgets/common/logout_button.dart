import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../features/auth/controllers/logout_controller.dart';
import '../../features/auth/login_screen.dart';

/// Reusable logout button widget
/// Can be used as IconButton or full-width button
class LogoutButton extends ConsumerWidget {
  final bool isFullWidth;
  final String? text;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const LogoutButton({
    super.key,
    this.isFullWidth = false,
    this.text,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// Factory for icon button (used in AppBar)
  factory LogoutButton.icon({IconData? icon, Color? color}) {
    return LogoutButton(
      isFullWidth: false,
      icon: icon ?? Icons.logout,
      foregroundColor: color,
    );
  }

  /// Factory for full-width button (used in settings/profile)
  factory LogoutButton.fullWidth({
    String? text,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return LogoutButton(
      isFullWidth: true,
      text: text ?? 'Logout',
      backgroundColor: backgroundColor ?? Colors.red,
      foregroundColor: foregroundColor ?? Colors.white,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoutState = ref.watch(logoutControllerProvider);

    // Listen to logout state changes
    ref.listen<LogoutState>(logoutControllerProvider, (previous, next) {
      if (next.isSuccess) {
        // Navigate to login screen on success
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
        // Reset state
        ref.read(logoutControllerProvider.notifier).reset();
      } else if (next.error != null) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Reset state
        ref.read(logoutControllerProvider.notifier).reset();
      }
    });

    if (isFullWidth) {
      return _buildFullWidthButton(context, ref, logoutState);
    } else {
      return _buildIconButton(context, ref, logoutState);
    }
  }

  Widget _buildIconButton(
    BuildContext context,
    WidgetRef ref,
    LogoutState logoutState,
  ) {
    return IconButton(
      onPressed: logoutState.isLoading
          ? null
          : () => _showLogoutConfirmation(context, ref),
      icon: logoutState.isLoading
          ? SizedBox(
              width: 20.w,
              height: 20.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  foregroundColor ?? Colors.white,
                ),
              ),
            )
          : Icon(icon ?? Icons.logout, color: foregroundColor),
      tooltip: 'Logout',
    );
  }

  Widget _buildFullWidthButton(
    BuildContext context,
    WidgetRef ref,
    LogoutState logoutState,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: logoutState.isLoading
            ? null
            : () => _showLogoutConfirmation(context, ref),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.red,
          foregroundColor: foregroundColor ?? Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: logoutState.isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    foregroundColor ?? Colors.white,
                  ),
                ),
              )
            : Text(
                text ?? 'Logout',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red, size: 24.sp),
            SizedBox(width: 12.w),
            Text(
              'Konfirmasi Logout',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Batal',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Perform logout using controller
              ref.read(logoutControllerProvider.notifier).logout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(
              'Logout',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
