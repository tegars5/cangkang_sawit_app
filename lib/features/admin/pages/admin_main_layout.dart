import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/common/common_widgets.dart';
import 'admin_dashboard_page.dart';
import 'admin_orders_page.dart';
import 'admin_shipments_page.dart';
import 'admin_users_page.dart';
import 'admin_settings_page.dart';

/// Main Admin Layout dengan Bottom Navigation
class AdminMainLayout extends ConsumerStatefulWidget {
  const AdminMainLayout({super.key});

  @override
  ConsumerState<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends ConsumerState<AdminMainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AdminDashboardPage(),
    const AdminOrdersPage(),
    const AdminShipmentsPage(),
    const AdminUsersPage(),
    const AdminSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AdminBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
