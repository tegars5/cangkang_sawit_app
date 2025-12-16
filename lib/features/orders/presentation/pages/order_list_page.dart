import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/order_notifier.dart';

/// Page to display list of orders
class OrderListPage extends ConsumerStatefulWidget {
  const OrderListPage({super.key});

  @override
  ConsumerState<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends ConsumerState<OrderListPage> {
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    // Load orders on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderNotifierProvider.notifier).loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (status) {
              setState(() {
                _selectedStatus = status == 'all' ? null : status;
              });
              ref
                  .read(orderNotifierProvider.notifier)
                  .loadOrders(status: _selectedStatus);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Semua')),
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
              const PopupMenuItem(value: 'confirmed', child: Text('Confirmed')),
              const PopupMenuItem(value: 'shipped', child: Text('Shipped')),
              const PopupMenuItem(value: 'completed', child: Text('Completed')),
              const PopupMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
          ),
        ],
      ),
      body: _buildBody(orderState),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/orders/create');
        },
        icon: const Icon(Icons.add),
        label: const Text('Buat Pesanan'),
      ),
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
                    .loadOrders(status: _selectedStatus);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (orderState.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada pesanan',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(orderNotifierProvider.notifier)
            .loadOrders(status: _selectedStatus);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orderState.orders.length,
        itemBuilder: (context, index) {
          final order = orderState.orders[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                order.orderNumber,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Tanggal: ${_formatDate(order.orderDate)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total: ${_formatCurrency(order.totalAmount)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusChip(order.status),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/orders/detail',
                  arguments: order.id,
                );
              },
            ),
          );
        },
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
}
