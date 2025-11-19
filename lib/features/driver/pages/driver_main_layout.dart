import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/common/common_widgets.dart';
import 'driver_dashboard_page.dart';
import 'driver_tasks_page.dart';
import 'driver_deliveries_page.dart';
import 'driver_profile_page.dart';

/// Driver Main Layout with Bottom Navigation
class DriverMainLayout extends ConsumerStatefulWidget {
  const DriverMainLayout({super.key});

  @override
  ConsumerState<DriverMainLayout> createState() => _DriverMainLayoutState();
}

class _DriverMainLayoutState extends ConsumerState<DriverMainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DriverDashboardPage(),
    const DriverTasksPage(),
    const DriverDeliveriesPage(),
    const DriverProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: DriverBottomNavBar(
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
