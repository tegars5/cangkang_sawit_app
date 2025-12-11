import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

import '../../shared/models/models.dart';
import '../../shared/repositories/shipment_repository.dart';
import '../../shared/repositories/location_repository.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  final ShipmentRepository _shipmentRepository = ShipmentRepository();
  final LocationRepository _locationRepository = LocationRepository();
  final MapController _mapController = MapController();

  Shipment? shipment;
  DriverLocation? currentDriverLocation;
  StreamSubscription<List<DriverLocation>>? _locationSubscription;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadShipmentData();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadShipmentData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final fetchedShipment = await _shipmentRepository.getShipmentByOrderId(
        widget.orderId,
      );

      if (fetchedShipment != null) {
        setState(() {
          shipment = fetchedShipment;
          isLoading = false;
        });

        // Start location tracking if shipment is in transit
        if (fetchedShipment.status == 'in_transit') {
          _startLocationTracking();
        }
      } else {
        setState(() {
          error = 'Shipment tidak ditemukan untuk pesanan ini';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Gagal memuat data pengiriman: $e';
        isLoading = false;
      });
    }
  }

  void _startLocationTracking() {
    if (shipment == null) return;

    _locationSubscription = _locationRepository
        .streamDriverLocation(shipment!.id)
        .listen(
          (locations) {
            if (locations.isNotEmpty && mounted) {
              setState(() {
                currentDriverLocation = locations.first;
              });

              // Update map view to center on driver location
              if (currentDriverLocation != null) {
                _mapController.move(
                  LatLng(
                    currentDriverLocation!.latitude,
                    currentDriverLocation!.longitude,
                  ),
                  15.0,
                );
              }
            }
          },
          onError: (error) {
            // Handle location stream error gracefully
            if (mounted) {
              setState(() {
                currentDriverLocation = null;
              });
            }
          },
        );
  }

  int _getActiveStepIndex(String status) {
    switch (status) {
      case 'pending':
        return 0;
      case 'in_transit':
        return 1;
      case 'arrived':
        return 2;
      case 'completed':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking Pesanan'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? _buildErrorWidget()
          : shipment != null
          ? _buildTrackingContent()
          : _buildNoDataWidget(),
    );
  }

  Widget _buildErrorWidget() {
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
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _loadShipmentData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'Belum Ada Data Pengiriman',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'Pengiriman belum diatur untuk pesanan ini',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Info Card
          _buildOrderInfoCard(),
          SizedBox(height: 16.h),

          // Status Timeline
          _buildStatusTimeline(),
          SizedBox(height: 16.h),

          // Map Section
          _buildMapSection(),
          SizedBox(height: 16.h),

          // Driver Info (if available)
          if (shipment?.driverId != null) _buildDriverInfoCard(),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: const Color(0xFF2E7D32),
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Informasi Pesanan',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _buildInfoRow('ID Pesanan', widget.orderId),
            _buildInfoRow('Nomor Pengiriman', shipment!.deliveryNoteNumber),
            _buildInfoRow('Status', _getStatusText(shipment!.status)),
            if (shipment?.assignedAt != null)
              _buildInfoRow(
                'Tanggal Ditugaskan',
                _formatDateTime(shipment!.assignedAt ?? shipment!.createdAt),
              ),
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
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    final steps = [
      {'title': 'Pending', 'subtitle': 'Menunggu penugasan driver'},
      {'title': 'Diproses', 'subtitle': 'Driver sedang dalam perjalanan'},
      {'title': 'Dikirim', 'subtitle': 'Tiba di lokasi tujuan'},
      {'title': 'Selesai', 'subtitle': 'Pengiriman berhasil diselesaikan'},
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: const Color(0xFF2E7D32),
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Status Pengiriman',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Column(
              children: steps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                final isActive = index <= _getActiveStepIndex(shipment!.status);
                final isLast = index == steps.length - 1;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? const Color(0xFF2E7D32)
                                : Colors.grey[300],
                          ),
                          child: isActive
                              ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 12.sp,
                                )
                              : null,
                        ),
                        if (!isLast)
                          Container(
                            width: 2.w,
                            height: 40.h,
                            color: isActive
                                ? const Color(0xFF2E7D32)
                                : Colors.grey[300],
                          ),
                      ],
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step['title']!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? const Color(0xFF2E7D32)
                                    : Colors.grey[600],
                              ),
                            ),
                            Text(
                              step['subtitle']!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.map, color: const Color(0xFF2E7D32), size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Lokasi Driver',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              height: 200.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: currentDriverLocation != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: LatLng(
                            currentDriverLocation!.latitude,
                            currentDriverLocation!.longitude,
                          ),
                          initialZoom: 15.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'com.example.cangkang_sawit_app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(
                                  currentDriverLocation!.latitude,
                                  currentDriverLocation!.longitude,
                                ),
                                width: 40.w,
                                height: 40.w,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E7D32),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.local_shipping,
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : _buildMapPlaceholder(),
            ),
            if (currentDriverLocation != null) ...[
              SizedBox(height: 12.h),
              Text(
                'Terakhir diperbarui: ${_formatDateTime(currentDriverLocation!.timestamp)}',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 48.sp, color: Colors.grey[400]),
            SizedBox(height: 8.h),
            Text(
              shipment!.status == 'in_transit'
                  ? 'Menunggu lokasi driver...'
                  : 'Lokasi tidak tersedia',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: const Color(0xFF2E7D32), size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Informasi Driver',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // This would need to be populated with actual driver data
            // For now, showing placeholder
            _buildInfoRow(
              'Driver ID',
              shipment!.driverId ?? 'Belum ditugaskan',
            ),
            _buildInfoRow('Status', _getStatusText(shipment!.status)),
            if (currentDriverLocation != null) ...[
              _buildInfoRow(
                'Kecepatan',
                '${currentDriverLocation!.speed?.toStringAsFixed(1) ?? '0'} km/h',
              ),
              if (currentDriverLocation!.heading != null)
                _buildInfoRow(
                  'Arah',
                  '${currentDriverLocation!.heading!.toStringAsFixed(0)}°',
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'in_transit':
        return 'Dalam Perjalanan';
      case 'arrived':
        return 'Tiba di Tujuan';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
