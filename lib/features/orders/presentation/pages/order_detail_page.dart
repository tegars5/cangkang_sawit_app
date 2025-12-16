import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/order_notifier.dart';

/// Page to display order details
class OrderDetailPage extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends ConsumerState<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
    // Load order details on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderNotifierProvider.notifier).loadOrderById(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: _buildBody(orderState),
    );
  }

  Widget _buildBody(orderState) {
    if (orderState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orderState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              orderState.errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(orderNotifierProvider.notifier)
                    .loadOrderById(widget.orderId);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    final order = orderState.selectedOrder;
    if (order == null) {
      return const Center(child: Text('Pesanan tidak ditemukan'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildStatusChip(order.status),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    'Tanggal Pesanan',
                    _formatDate(order.orderDate),
                  ),
                  if (order.confirmedAt != null)
                    _buildInfoRow(
                      'Tanggal Konfirmasi',
                      _formatDate(order.confirmedAt!),
                    ),
                  if (order.completedAt != null)
                    _buildInfoRow(
                      'Tanggal Selesai',
                      _formatDate(order.completedAt!),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Order Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Pesanan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    'Total Kuantitas',
                    '${order.totalQuantity.toStringAsFixed(0)} kg',
                  ),
                  if (order.confirmedQuantity > 0)
                    _buildInfoRow(
                      'Kuantitas Dikonfirmasi',
                      '${order.confirmedQuantity.toStringAsFixed(0)} kg',
                      valueColor: Colors.blue,
                    ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Total Harga',
                    _formatCurrency(order.totalAmount),
                    valueStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Addresses
          if (order.pickupAddress != null || order.deliveryAddress != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alamat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    if (order.pickupAddress != null) ...[
                      const Text(
                        'Alamat Pickup:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(order.pickupAddress!),
                      const SizedBox(height: 12),
                    ],
                    if (order.deliveryAddress != null) ...[
                      const Text(
                        'Alamat Pengiriman:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(order.deliveryAddress!),
                    ],
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Notes
          if (order.notes != null ||
              order.adminNotes != null ||
              order.customerNotes != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Catatan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    if (order.customerNotes != null) ...[
                      const Text(
                        'Catatan Customer:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(order.customerNotes!),
                      const SizedBox(height: 12),
                    ],
                    if (order.adminNotes != null) ...[
                      const Text(
                        'Catatan Admin:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(order.adminNotes!),
                    ],
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Action Buttons
          if (order.canBeCancelled())
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showCancelDialog(context),
                icon: const Icon(Icons.cancel),
                label: const Text('Batalkan Pesanan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    TextStyle? valueStyle,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style:
                valueStyle ??
                TextStyle(fontWeight: FontWeight.w600, color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'confirmed':
        color = Colors.blue;
        label = 'Confirmed';
        break;
      case 'shipped':
        color = Colors.purple;
        label = 'Shipped';
        break;
      case 'completed':
        color = Colors.green;
        label = 'Completed';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  void _showCancelDialog(BuildContext context) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Apakah Anda yakin ingin membatalkan pesanan ini?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Alasan Pembatalan',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alasan harus diisi')),
                );
                return;
              }

              Navigator.pop(context);

              final success = await ref
                  .read(orderNotifierProvider.notifier)
                  .cancelOrder(widget.orderId, reasonController.text);

              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pesanan berhasil dibatalkan'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ref.read(orderNotifierProvider).errorMessage ??
                            'Gagal membatalkan pesanan',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }
}
