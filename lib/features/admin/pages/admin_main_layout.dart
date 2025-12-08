import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/common/common_widgets.dart';
import 'admin_dashboard_page.dart';
import 'admin_orders_page.dart';
import 'admin_products_page.dart';
import 'admin_shipments_page.dart';
import 'admin_settings_page.dart';
import '../providers/admin_providers.dart';

/// Main Admin Layout dengan Bottom Navigation
class AdminMainLayout extends ConsumerWidget {
  const AdminMainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(adminTabIndexProvider);

    final List<Widget> pages = [
      const AdminDashboardPage(), // 0
      const AdminOrdersPage(), // 1
      const AdminShipmentsPage(), // 2 - Center FAB
      const AdminProductsPage(), // 3
      const AdminSettingsPage(), // 4
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: AdminBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(adminTabIndexProvider.notifier).setIndex(index);
        },
      ),
    );
  }
}
