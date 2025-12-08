import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/models.dart';
import '../../../shared/repositories/order_repository.dart';
import '../../../widgets/common/status_badge.dart';
import 'prepare_shipment_page.dart';

class OrderDetailPage extends StatefulWidget {
  // Menerima object Order langsung, bukan Map
  final Order order;

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final OrderRepository _orderRepository = OrderRepository();
  bool _isUpdating = false;

  // Fungsi untuk Admin mengubah status pesanan
  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    try {
      await _orderRepository.updateOrderStatus(
        orderId: widget.order.id,
        status: newStatus,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status berhasil diubah ke $newStatus')),
        );
        Navigator.pop(context); // Kembali agar list di-refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal update: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Order ${order.orderNumber}'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Info ---
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status:', style: TextStyle(fontSize: 14.sp)),
                        StatusBadge(status: order.status),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Bayar:',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currencyFormat.format(order.totalAmount),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // --- Informasi Pengiriman ---
            Text(
              'Informasi Pengiriman',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.blue),
                title: Text(order.deliveryAddress ?? '-'),
                subtitle: Text(
                  'Tgl: ${DateFormat('dd MMM yyyy').format(order.deliveryDate ?? DateTime.now())}',
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // --- Detail Produk ---
            Text(
              'Item Pesanan',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            // Karena orderDetails ada di dalam object Order (List<OrderDetail>), kita mapping
            if (order.orderDetails != null && order.orderDetails!.isNotEmpty)
              ...order.orderDetails!.map(
                (item) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.shopping_bag_outlined),
                    title: Text(
                      'Produk Sawit',
                    ), // Bisa diganti item.productName jika ada
                    subtitle: Text(
                      '${item.requestedQuantity} Ton x ${currencyFormat.format(item.unitPrice)}',
                    ),
                    trailing: Text(currencyFormat.format(item.subtotal)),
                  ),
                ),
              )
            else
              const Text('Tidak ada detail item.'),

            SizedBox(height: 32.h),

            // --- Tombol Aksi Admin ---
            if (order.status == 'pending')
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _isUpdating
                      ? null
                      : () => _updateStatus('confirmed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isUpdating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('KONFIRMASI PESANAN'),
                ),
              ),

            if (order.status == 'confirmed')
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _isUpdating
                      ? null
                      : () async {
                          // Navigate to prepare shipment page
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PrepareShipmentPage(order: order),
                            ),
                          );

                          // If shipment was successfully assigned, refresh order data
                          if (result == true && mounted) {
                            setState(() {
                              // Trigger rebuild to show updated status
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('PROSES PENGIRIMAN (SHIP)'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
