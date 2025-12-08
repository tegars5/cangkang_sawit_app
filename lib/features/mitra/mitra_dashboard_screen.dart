import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Pastikan import ini sesuai dengan lokasi file Kakak
import '../../shared/services/mitra_service.dart';
import '../../widgets/common/logout_button.dart';
import 'create_order_screen.dart';
import 'order_history_screen.dart';
import 'product_catalog_screen.dart';

class MitraDashboardScreen extends ConsumerStatefulWidget {
  const MitraDashboardScreen({super.key});

  @override
  ConsumerState<MitraDashboardScreen> createState() =>
      _MitraDashboardScreenState();
}

class _MitraDashboardScreenState extends ConsumerState<MitraDashboardScreen> {
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

      if (mounted) {
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
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Terjadi kesalahan: $e';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Mitra Bisnis'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          // Logout Button
          LogoutButton.icon(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
                )
              : error != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.0,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Terjadi kesalahan',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      error!,
                      style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: _loadDashboardData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text(
                      'Selamat Datang, Mitra Bisnis',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Kelola pesanan cangkang sawit Anda dengan mudah',
                      style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 32.0),

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
                        const SizedBox(width: 16.0),
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

                    const SizedBox(height: 16.0),

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
                        const SizedBox(width: 16.0),
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

                    const SizedBox(height: 32.0),

                    // Menu Options
                    const Text(
                      'Menu Utama',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 16.0),

                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
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
                              // Asumsi: Tracking masuk ke OrderHistory dulu untuk pilih order
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
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
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
              Icon(icon, color: color, size: 24.0),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            title,
            style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
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
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
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
            Icon(icon, size: 32.0, color: const Color(0xFF1B5E20)),
            const SizedBox(height: 12.0),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4.0),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
