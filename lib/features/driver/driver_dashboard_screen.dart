import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../core/repositories/shipment_repository.dart';
import '../../shared/models/shipment.dart';
import '../../widgets/common/logout_button.dart';
import 'pages/task_detail_page.dart';
import 'pages/driver_navigation_screen.dart';

class DriverDashboardScreen extends ConsumerStatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  ConsumerState<DriverDashboardScreen> createState() =>
      _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends ConsumerState<DriverDashboardScreen> {
  List<Shipment> _activeShipments = [];
  List<Shipment> _pendingShipments = [];
  List<Shipment> _completedToday = [];
  bool _isLoading = true;
  String? _error;

  // Stats
  int _totalDeliveriesToday = 0;
  int _completedDeliveries = 0;
  String _workingTime = '0j 0m';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw 'User not authenticated';

      // Get all shipments for this driver
      final allShipments = await ShipmentRepository.getDriverShipments(userId);

      // Filter by status
      final active = allShipments
          .where((s) => s.status == 'in_transit')
          .toList();

      // Pending includes both 'pending' and 'assigned' status
      final pending = allShipments
          .where((s) => s.status == 'pending' || s.status == 'assigned')
          .toList();

      // Get completed today
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final completed = allShipments
          .where(
            (s) =>
                s.status == 'completed' &&
                s.completedAt != null &&
                s.completedAt!.isAfter(todayStart),
          )
          .toList();

      setState(() {
        _activeShipments = active;
        _pendingShipments = pending;
        _completedToday = completed;
        _totalDeliveriesToday =
            pending.length + active.length + completed.length;
        _completedDeliveries = completed.length;
        _isLoading = false;
      });

      _calculateWorkingTime();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _calculateWorkingTime() {
    if (_completedToday.isEmpty && _activeShipments.isEmpty) {
      setState(() => _workingTime = '0j 0m');
      return;
    }

    DateTime? firstStart;
    DateTime? lastComplete = DateTime.now();

    // Find earliest start time
    for (var shipment in [..._activeShipments, ..._completedToday]) {
      if (shipment.startedAt != null) {
        if (firstStart == null || shipment.startedAt!.isBefore(firstStart)) {
          firstStart = shipment.startedAt;
        }
      }
    }

    if (firstStart != null) {
      final duration = lastComplete.difference(firstStart);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      setState(() => _workingTime = '${hours}j ${minutes}m');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Dashboard Driver'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [LogoutButton.icon()],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildErrorState()
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with driver info
                    _buildHeader(),
                    SizedBox(height: 20.h),

                    // Active Shipment Card (if any)
                    if (_activeShipments.isNotEmpty) ...[
                      _buildActiveShipmentCard(_activeShipments.first),
                      SizedBox(height: 20.h),
                    ],

                    // Today's Stats
                    _buildTodayStats(),
                    SizedBox(height: 20.h),

                    // Pending Shipments
                    if (_pendingShipments.isNotEmpty) ...[
                      _buildSectionHeader(
                        'Tugas Menunggu',
                        _pendingShipments.length,
                      ),
                      SizedBox(height: 12.h),
                      _buildPendingList(),
                      SizedBox(height: 20.h),
                    ],

                    // Completed Today
                    if (_completedToday.isNotEmpty) ...[
                      _buildSectionHeader(
                        'Selesai Hari Ini',
                        _completedToday.length,
                      ),
                      SizedBox(height: 12.h),
                      _buildCompletedList(),
                    ],

                    // Empty state
                    if (_activeShipments.isEmpty &&
                        _pendingShipments.isEmpty &&
                        _completedToday.isEmpty)
                      _buildEmptyState(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.userMetadata?['full_name'] ?? 'Driver';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 35.sp,
              color: const Color(0xFF1B5E20),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Online',
                      style: TextStyle(fontSize: 14.sp, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('HH:mm').format(DateTime.now()),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                DateFormat('dd MMM yyyy').format(DateTime.now()),
                style: TextStyle(fontSize: 12.sp, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveShipmentCard(Shipment shipment) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange.shade200, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.local_shipping,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PENGIRIMAN AKTIF',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      shipment.order?.orderNumber ?? 'N/A',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Destination
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: Colors.red, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  shipment.order?.deliveryAddress ?? 'Alamat tidak tersedia',
                  style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DriverNavigationScreen(shipment: shipment),
                  ),
                ).then((_) => _loadDashboardData());
              },
              icon: const Icon(Icons.navigation),
              label: const Text('Lanjutkan Navigasi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistik Hari Ini',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Tugas',
                _totalDeliveriesToday.toString(),
                Icons.assignment,
                Colors.blue,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                'Selesai',
                _completedDeliveries.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Sedang Jalan',
                _activeShipments.length.toString(),
                Icons.local_shipping,
                Colors.orange,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                'Waktu Kerja',
                _workingTime,
                Icons.access_time,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFF1B5E20).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B5E20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingList() {
    return Column(
      children: _pendingShipments.map((shipment) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          child: _buildShipmentCard(shipment, isPending: true),
        );
      }).toList(),
    );
  }

  Widget _buildCompletedList() {
    return Column(
      children: _completedToday.map((shipment) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          child: _buildShipmentCard(shipment, isPending: false),
        );
      }).toList(),
    );
  }

  Widget _buildShipmentCard(Shipment shipment, {required bool isPending}) {
    final color = isPending ? Colors.orange : Colors.green;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskDetailPage(taskData: shipment.toJson()),
          ),
        ).then((_) => _loadDashboardData());
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                isPending ? Icons.pending_actions : Icons.check_circle,
                color: color,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shipment.order?.orderNumber ?? 'N/A',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    shipment.order?.deliveryAddress ?? 'Alamat tidak tersedia',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isPending && shipment.completedAt != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      'Selesai: ${DateFormat('HH:mm').format(shipment.completedAt!)}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 24.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 80.sp, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text(
              'Belum Ada Tugas',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tugas baru akan muncul di sini',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: Colors.red[300]),
            SizedBox(height: 16.h),
            Text(
              'Gagal Memuat Data',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Text(
              _error ?? 'Terjadi kesalahan',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _loadDashboardData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
