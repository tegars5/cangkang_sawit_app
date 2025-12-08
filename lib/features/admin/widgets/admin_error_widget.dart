import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'admin_card_container.dart';

/// Reusable Error Widget untuk Admin Pages
class AdminErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool useCard;
  final IconData? icon;

  const AdminErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.useCard = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              color: const Color(0xFFF44336),
              size: 28.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF757575),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 12.h),
              TextButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh, size: 16.sp),
                label: Text(
                  'Coba Lagi',
                  style: TextStyle(fontSize: 12.sp),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1B5E20),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (useCard) {
      return AdminCardContainer(
        padding: EdgeInsets.zero,
        child: content,
      );
    }

    return content;
  }
}
