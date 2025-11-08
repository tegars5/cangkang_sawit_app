import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/mitra_service.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String? orderId;

  const OrderTrackingScreen({super.key, this.orderId});

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  final _orderIdController = TextEditingController();
  Map<String, dynamic>? trackingData;
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    if (widget.orderId != null) {
      _orderIdController.text = widget.orderId!;
      _trackOrder();
    }
  }

  @override
  void dispose() {
    _orderIdController.dispose();
    super.dispose();
  }

  Future<void> _trackOrder() async {
    if (_orderIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan ID pesanan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await MitraService.trackOrder(
        _orderIdController.text.trim(),
      );

      if (result['success']) {
        setState(() {
          trackingData = result['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          error = result['error'] ?? 'Gagal melacak pesanan';
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'order_placed':
        return Colors.blue;
      case 'confirmed':
        return Colors.green;
      case 'prepared':
        return Colors.orange;
      case 'picked_up':
        return Colors.purple;
      case 'in_transit':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'order_placed':
        return Icons.shopping_cart;
      case 'confirmed':
        return Icons.check_circle;
      case 'prepared':
        return Icons.inventory_2;
      case 'picked_up':
        return Icons.local_shipping;
      case 'in_transit':
        return Icons.directions_car;
      case 'delivered':
        return Icons.check_circle_outline;
      default:
        return Icons.help;
    }
  }

  String _getStatusTitle(String status) {
    switch (status) {
      case 'order_placed':
        return 'Pesanan Dibuat';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'prepared':
        return 'Disiapkan';
      case 'picked_up':
        return 'Diambil Driver';
      case 'in_transit':
        return 'Dalam Perjalanan';
      case 'delivered':
        return 'Terkirim';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lacak Pesanan'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search section
            Text(
              'Masukkan ID Pesanan',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _orderIdController,
                    decoration: InputDecoration(
                      hintText: 'Contoh: ORD-001',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                    onSubmitted: (value) => _trackOrder(),
                  ),
                ),
                SizedBox(width: 12.w),
                ElevatedButton(
                  onPressed: isLoading ? null : _trackOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 12.h,
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('Lacak'),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Results section
            if (error != null) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48.sp,
                      color: Colors.red[300],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Pesanan Tidak Ditemukan',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[700],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      error!,
                      style: TextStyle(fontSize: 14.sp, color: Colors.red[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else if (trackingData != null) ...[
              // Order info card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ID: ${trackingData!['order_id']}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                trackingData!['current_status'],
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: _getStatusColor(
                                  trackingData!['current_status'],
                                ).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              _getStatusTitle(trackingData!['current_status']),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: _getStatusColor(
                                  trackingData!['current_status'],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Tracking info
                      if (trackingData!['tracking_number'] != null)
                        _buildInfoRow(
                          'No. Resi:',
                          trackingData!['tracking_number'],
                        ),

                      if (trackingData!['estimated_delivery'] != null)
                        _buildInfoRow(
                          'Estimasi Tiba:',
                          DateTime.parse(
                            trackingData!['estimated_delivery'],
                          ).toString().substring(0, 16),
                        ),

                      // Driver info (if available)
                      if (trackingData!['driver'] != null) ...[
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Informasi Driver',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[700],
                                ),
                              ),
                              SizedBox(height: 8.h),
                              _buildInfoRow(
                                'Nama:',
                                trackingData!['driver']['name'],
                              ),
                              _buildInfoRow(
                                'Telepon:',
                                trackingData!['driver']['phone'],
                              ),
                              _buildInfoRow(
                                'Kendaraan:',
                                trackingData!['driver']['vehicle'],
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Location info (if available)
                      if (trackingData!['location'] != null) ...[
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 16.sp,
                                    color: Colors.green[700],
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Lokasi Terakhir',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                trackingData!['location']['address'],
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.green[600],
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Update: ${DateTime.parse(trackingData!['location']['updated_at']).toString().substring(0, 16)}',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Timeline
              Text(
                'Status Pengiriman',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16.h),

              if (trackingData!['timeline'] != null) ...[
                ...List.generate((trackingData!['timeline'] as List).length, (
                  index,
                ) {
                  final timeline = trackingData!['timeline'] as List;
                  final item = timeline[index];
                  final isLast = index == timeline.length - 1;
                  final isCurrent = item['current'] == true;

                  return _buildTimelineItem(
                    icon: _getStatusIcon(item['status']),
                    title: _getStatusTitle(item['status']),
                    description: item['description'],
                    timestamp: DateTime.parse(item['timestamp']),
                    isActive: isCurrent,
                    isCompleted: !isCurrent,
                    isLast: isLast,
                  );
                }),
              ],
            ] else ...[
              // Empty state
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(32.w),
                child: Column(
                  children: [
                    Icon(Icons.search, size: 64.sp, color: Colors.grey[400]),
                    SizedBox(height: 16.h),
                    Text(
                      'Masukkan ID Pesanan',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Masukkan ID pesanan Anda untuk melacak status pengiriman',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String description,
    required DateTime timestamp,
    required bool isActive,
    required bool isCompleted,
    required bool isLast,
  }) {
    Color itemColor = isActive
        ? const Color(0xFF2E7D32)
        : isCompleted
        ? Colors.green[300]!
        : Colors.grey[400]!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: isActive ? itemColor : Colors.white,
                border: Border.all(color: itemColor, width: isActive ? 3 : 2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20.sp,
                color: isActive ? Colors.white : itemColor,
              ),
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 40.h,
                color: itemColor.withOpacity(0.3),
              ),
          ],
        ),

        SizedBox(width: 16.w),

        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? itemColor : Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
