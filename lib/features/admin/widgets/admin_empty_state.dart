import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'admin_card_container.dart';

/// Reusable Empty State Widget untuk Admin Pages
class AdminEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionText;
  final VoidCallback? onActionTap;
  final bool useCard;

  const AdminEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionText,
    this.onActionTap,
    this.useCard = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40.sp, color: const Color(0xFF9E9E9E)),
            SizedBox(height: 12.h),
            Text(
              message,
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF757575)),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onActionTap != null) ...[
              SizedBox(height: 12.h),
              TextButton(
                onPressed: onActionTap,
                child: Text(
                  actionText!,
                  style: TextStyle(
                    color: const Color(0xFF1B5E20),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (useCard) {
      return AdminCardContainer(padding: EdgeInsets.zero, child: content);
    }

    return content;
  }
}
