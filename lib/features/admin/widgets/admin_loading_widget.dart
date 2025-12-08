import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'admin_card_container.dart';

/// Reusable Loading Widget untuk Admin Pages
class AdminLoadingWidget extends StatelessWidget {
  final bool useCard;
  final double? size;
  final Color? color;

  const AdminLoadingWidget({
    super.key,
    this.useCard = true,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final loader = Center(
      child: SizedBox(
        width: size ?? 24.w,
        height: size ?? 24.w,
        child: CircularProgressIndicator(
          color: color ?? const Color(0xFF1B5E20),
          strokeWidth: 2,
        ),
      ),
    );

    if (useCard) {
      return AdminCardContainer(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: loader,
        ),
      );
    }

    return loader;
  }
}

/// Loading Card placeholder dengan shimmer effect
class AdminLoadingCard extends StatelessWidget {
  final double? height;
  final double? width;

  const AdminLoadingCard({
    super.key,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 24.w,
          height: 24.w,
          child: const CircularProgressIndicator(
            color: Color(0xFF1B5E20),
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
