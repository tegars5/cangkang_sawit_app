import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Admin Orders Page
///
/// Displays and manages all orders in the system
class AdminOrdersPage extends ConsumerWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Order Management',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Order management features coming soon',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Orders'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Orders'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Pending'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Confirmed'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Shipped'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Completed'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Cancelled'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
