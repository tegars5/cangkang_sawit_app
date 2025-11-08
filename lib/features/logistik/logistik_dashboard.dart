import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LogistikDashboard extends ConsumerWidget {
  const LogistikDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Logistik'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.gps_fixed),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('GPS tracking akan diimplementasikan'),
                ),
              );
            },
          ),
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
              'Selamat Datang, Driver',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Kelola pengiriman cangkang sawit',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),

            SizedBox(height: 32.h),

            // Status Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green[600],
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: Siap Bertugas',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[800],
                          ),
                        ),
                        Text(
                          'GPS aktif • Kendaraan ready',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.green[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Pengiriman Hari Ini',
                    value: '3',
                    icon: Icons.local_shipping,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildStatCard(
                    title: 'Jarak Tempuh',
                    value: '127 km',
                    icon: Icons.route,
                    color: Colors.orange,
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
                    title: 'Daftar Pengiriman',
                    subtitle: 'Lihat jadwal pengiriman',
                    icon: Icons.list_alt,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur akan diimplementasikan'),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    title: 'Mulai Pengiriman',
                    subtitle: 'Konfirmasi pickup',
                    icon: Icons.play_circle_filled,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur akan diimplementasikan'),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    title: 'Tracking GPS',
                    subtitle: 'Bagikan lokasi real-time',
                    icon: Icons.gps_fixed,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur akan diimplementasikan'),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    title: 'Konfirmasi Delivery',
                    subtitle: 'Selesaikan pengiriman',
                    icon: Icons.check_circle_outline,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur akan diimplementasikan'),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    title: 'Riwayat Pengiriman',
                    subtitle: 'Lihat history delivery',
                    icon: Icons.history,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur akan diimplementasikan'),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    title: 'Laporan Harian',
                    subtitle: 'Submit laporan kerja',
                    icon: Icons.assessment,
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
                  fontSize: 20.sp,
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
