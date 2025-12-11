import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/models/models.dart';
import '../../../shared/repositories/order_repository.dart';

/// Dialog untuk konfirmasi order oleh admin
class ConfirmOrderDialog extends StatefulWidget {
  final Order order;
  final OrderRepository orderRepository;

  const ConfirmOrderDialog({
    super.key,
    required this.order,
    required this.orderRepository,
  });

  @override
  State<ConfirmOrderDialog> createState() => _ConfirmOrderDialogState();
}

class _ConfirmOrderDialogState extends State<ConfirmOrderDialog> {
  bool _isConfirming = false;
  String? _errorMessage;

  Future<void> _confirmOrder() async {
    setState(() {
      _isConfirming = true;
      _errorMessage = null;
    });

    try {
      // Get order details
      final orderDetails = widget.order.orderDetails ?? [];

      if (orderDetails.isEmpty) {
        throw Exception('Order details tidak ditemukan');
      }

      // Prepare confirmed items (accept all quantities by default)
      final confirmedItems = orderDetails.map((detail) {
        return {
          'detail_id': detail.id,
          'confirmed_quantity':
              detail.requestedQuantity, // Use requestedQuantity
        };
      }).toList();

      // Call repository to confirm order
      await widget.orderRepository.confirmOrder(
        orderId: widget.order.id,
        confirmedItems: confirmedItems,
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Pesanan berhasil dikonfirmasi'),
          backgroundColor: Colors.green,
        ),
      );

      // Close dialog and return success
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isConfirming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Konfirmasi Pesanan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Apakah Anda yakin ingin mengkonfirmasi pesanan ini?',
            style: TextStyle(fontSize: 14.sp),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order: ${widget.order.orderNumber}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Total: ${widget.order.totalQuantity} ton',
                  style: TextStyle(fontSize: 12.sp),
                ),
              ],
            ),
          ),
          if (_errorMessage != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red[700], fontSize: 12.sp),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isConfirming
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isConfirming ? null : _confirmOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
          ),
          child: _isConfirming
              ? SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Konfirmasi'),
        ),
      ],
    );
  }
}
