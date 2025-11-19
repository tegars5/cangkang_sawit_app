import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/mitra_service.dart';
import 'create_order_screen.dart';
import 'order_history_screen.dart';
import 'product_catalog_screen.dart';
import 'order_tracking_screen.dart';

class MitraDashboard extends ConsumerStatefulWidget {
  const MitraDashboard({super.key});

  @override
  ConsumerState<MitraDashboard> createState() => _MitraDashboardState();
}

class _MitraDashboardState extends ConsumerState<MitraDashboard> {
  Map<String, dynamic>? dashboardStats;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final result = await MitraService.getDashboardStats();

      if (result['success']) {
        setState(() {
          dashboardStats = result['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          error = result['error'] ?? 'Gagal memuat data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mitra Bisnis'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
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
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                )
              : error != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.sp,
                      color: Colors.red[300],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Terjadi kesalahan',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      error!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: _loadDashboardData,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Selamat Datang, Mitra',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Kelola pesanan cangkang sawit Anda',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Quick Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'Pesanan Pending',
                            value: '${dashboardStats?['pending_orders'] ?? 0}',
                            icon: Icons.hourglass_empty,
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Pesanan Aktif',
                            value: '${dashboardStats?['active_orders'] ?? 0}',
                            icon: Icons.local_shipping,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Additional Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'Total Pesanan',
                            value: '${dashboardStats?['total_orders'] ?? 0}',
                            icon: Icons.shopping_cart,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Bulan Ini',
                            value:
                                '${dashboardStats?['this_month_orders'] ?? 0}',
                            icon: Icons.calendar_month,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 32.h),

                    // Menu Options
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
                            title: 'Buat Pesanan',
                            subtitle: 'Pesan cangkang sawit',
                            icon: Icons.add_shopping_cart,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CreateOrderScreen(),
                                ),
                              );
                            },
                          ),
                          _buildMenuCard(
                            title: 'Riwayat Pesanan',
                            subtitle: 'Lihat semua pesanan',
                            icon: Icons.history,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const OrderHistoryScreen(),
                                ),
                              );
                            },
                          ),
                          _buildMenuCard(
                            title: 'Tracking Pesanan',
                            subtitle: 'Lacak pengiriman',
                            icon: Icons.location_on,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const OrderTrackingScreen(),
                                ),
                              );
                            },
                          ),
                          _buildMenuCard(
                            title: 'Katalog Produk',
                            subtitle: 'Lihat produk tersedia',
                            icon: Icons.eco,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ProductCatalogScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
            color: Colors.grey.withOpacity(0.1),
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
              color: Colors.grey.withOpacity(0.1),
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
