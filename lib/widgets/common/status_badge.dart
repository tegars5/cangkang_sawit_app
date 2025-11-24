import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String? text;

  const StatusBadge({
    super.key,
    required this.status,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Text(
        text ?? _getStatusText(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
      case 'processing':
      case 'diproses':
        return Colors.blue;
      case 'shipped':
      case 'in_transit':
      case 'dikirim':
        return Colors.indigo;
      case 'delivered':
      case 'completed':
      case 'selesai':
        return Colors.green;
      case 'cancelled':
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'confirmed':
      case 'processing':
        return 'Diproses';
      case 'shipped':
      case 'in_transit':
        return 'Dikirim';
      case 'delivered':
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }
}