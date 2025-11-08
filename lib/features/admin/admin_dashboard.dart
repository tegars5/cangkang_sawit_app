import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/admin_service.dart';
import '../../widgets/lottie_animations.dart';
import 'order_confirmation_screen.dart';
import 'shipment_assignment_screen.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  Map<String, dynamic>? dashboardStats;
  List<dynamic> recentOrders = [];
  List<dynamic> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => isLoading = true);

    try {
      // Load dashboard statistics
      final statsResult = await AdminDashboardService.getDashboardStats();
      if (statsResult['success']) {
        setState(() => dashboardStats = statsResult['data']);
      }

      // Load recent orders
      final ordersResult = await AdminDashboardService.getRecentOrders(
        limit: 5,
      );
      if (ordersResult['success']) {
        setState(() => recentOrders = ordersResult['data']);
      }

      // Load users
      final usersResult = await AdminDashboardService.getAllUsers();
      if (usersResult['success']) {
        setState(() => users = usersResult['data']);
      }
    } catch (e) {
      if (mounted) {
        LottieSnackbar.showError(
          context,
          message: 'Error loading dashboard: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement logout
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logout akan diimplementasikan')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Selamat Datang, Admin',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Kelola pesanan dan pengiriman cangkang sawit',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),

            SizedBox(height: 32.h),

            // Loading indicator or Statistics Cards
            if (isLoading)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(40.h),
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Loading dashboard data...',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Statistics Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Pesanan Pending',
                      value: '${dashboardStats?['pendingOrders'] ?? 0}',
                      icon: Icons.inbox,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Dalam Proses',
                      value: '${dashboardStats?['processingOrders'] ?? 0}',
                      icon: Icons.local_shipping,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Pesanan Selesai',
                      value: '${dashboardStats?['completedOrders'] ?? 0}',
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total Produk',
                      value: '${dashboardStats?['totalProducts'] ?? 0}',
                      icon: Icons.eco,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              // Menu Grid
              Text(
                'Menu Utama',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 16.h),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  children: [
                    _buildMenuCard(
                      title: 'Kelola Pesanan',
                      subtitle: 'Konfirmasi & tracking',
                      icon: Icons.assignment,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fitur akan diimplementasikan'),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      title: 'Konfirmasi Pesanan',
                      subtitle: 'Review & konfirmasi pesanan baru',
                      icon: Icons.assignment_turned_in,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const OrderConfirmationScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      title: 'Kelola Pengiriman',
                      subtitle: 'Upload surat jalan & assign driver',
                      icon: Icons.local_shipping,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ShipmentAssignmentScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      title: 'Kelola Pengguna',
                      subtitle: 'Mitra & driver',
                      icon: Icons.people,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fitur akan diimplementasikan'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ], // Closing bracket untuk else block
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24.sp),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32.sp, color: const Color(0xFF2E7D32)),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
