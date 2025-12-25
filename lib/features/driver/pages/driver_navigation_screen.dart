import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/driver_tracking_controller.dart';
import '../../shipments/domain/entities/shipment.dart';

/// Driver Navigation Screen - Like Gojek/Grab driver app
/// Shows map with route, ETA, and status update buttons
class DriverNavigationScreen extends ConsumerStatefulWidget {
  final Shipment shipment;

  const DriverNavigationScreen({super.key, required this.shipment});

  @override
  ConsumerState<DriverNavigationScreen> createState() =>
      _DriverNavigationScreenState();
}

class _DriverNavigationScreenState
    extends ConsumerState<DriverNavigationScreen> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    // Initialize navigation - set active shipment
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(driverTrackingControllerProvider.notifier)
          .setActiveShipment(widget.shipment);
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(driverTrackingControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Google Map (Full Screen)
          _buildMap(state),

          // Top Safe Area with back button
          Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),

          // Customer Info Card (Top Overlay)
          Positioned(
            top: MediaQuery.of(context).padding.top + 60.h,
            left: 16.w,
            right: 16.w,
            child: _buildCustomerInfoCard(state),
          ),

          // Bottom Action Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomActionCard(state),
          ),

          // Floating Re-center Button
          Positioned(
            right: 16.w,
            bottom: 280.h,
            child: _buildRecenterButton(state),
          ),

          // Loading Overlay
          if (state.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMap(state) {
    if (state.currentLocation == null) {
      return Container(
        color: Colors.grey[300],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 64.sp, color: Colors.grey[600]),
              SizedBox(height: 16.h),
              Text(
                'Mengambil lokasi GPS...',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      );
    }

    final currentLatLng = state.currentLatLng!;
    final markers = <Marker>{
      // Driver marker
      Marker(
        markerId: const MarkerId('driver'),
        position: currentLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Posisi Anda'),
      ),
      // Destination marker
      Marker(
        markerId: const MarkerId('destination'),
        position: state.destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Tujuan'),
      ),
    };

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: currentLatLng, zoom: 15),
      markers: markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      onMapCreated: (controller) {
        _mapController = controller;
        _fitBounds(currentLatLng, state.destination);
      },
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8.h,
        left: 8.w,
        right: 8.w,
        bottom: 8.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.5), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back, size: 24.sp, color: Colors.black87),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Text(
                'Navigasi Pengiriman',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard(state) {
    final order = state.shipment.order;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.local_shipping,
                  color: const Color(0xFF2E7D32),
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order?.orderNumber ?? 'N/A',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      order?.mitraName ?? 'Customer',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Call button
              IconButton(
                onPressed: () => _callCustomer(order?.mitraPhone),
                icon: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.phone, color: Colors.white, size: 20.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(height: 1, color: Colors.grey[300]),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.red, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  order?.deliveryAddress ?? 'Alamat tidak tersedia',
                  style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionCard(state) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: _getStatusColor(
                  state.currentStatus,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                state.statusDisplayText,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(state.currentStatus),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // ETA and Distance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoChip(
                  Icons.access_time,
                  'ETA',
                  state.formattedETA,
                  Colors.blue,
                ),
                _buildInfoChip(
                  Icons.straighten,
                  'Jarak',
                  state.formattedDistance,
                  Colors.orange,
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Action Button
            _buildActionButton(state),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(state) {
    String buttonText;
    VoidCallback? onPressed;
    Color buttonColor = const Color(0xFF2E7D32);

    if (state.canStartTask) {
      buttonText = 'Mulai Pengiriman';
      onPressed = () {
        // TODO: Implement navigation start
        ref
            .read(driverTrackingControllerProvider.notifier)
            .startTracking(widget.shipment.id);
      };
    } else if (state.currentStatus == 'in_transit') {
      buttonText = 'Sampai di Lokasi Pickup';
      onPressed = () {
        // TODO: Implement arrived at pickup
      };
    } else if (state.currentStatus == 'arrived_pickup') {
      buttonText = 'Barang Sudah Diambil';
      onPressed = () {
        // TODO: Implement mark picked up
      };
    } else if (state.currentStatus == 'picked_up') {
      buttonText = 'Sampai di Tujuan';
      onPressed = () {
        // TODO: Implement arrived at destination
      };
    } else if (state.currentStatus == 'arrived_destination') {
      buttonText = 'Selesaikan Pengiriman';
      buttonColor = Colors.green;
      onPressed = () {
        _showCompleteDialog();
      };
    } else if (state.currentStatus == 'completed') {
      buttonText = 'Pengiriman Selesai';
      buttonColor = Colors.grey;
      onPressed = null;
    } else {
      buttonText = 'Menunggu...';
      onPressed = null;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: Text(
          buttonText,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildRecenterButton(state) {
    return FloatingActionButton(
      onPressed: () {
        if (state.currentLatLng != null && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(state.currentLatLng!),
          );
        }
      },
      backgroundColor: Colors.white,
      child: Icon(Icons.my_location, color: const Color(0xFF2E7D32)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'in_transit':
      case 'picked_up':
        return Colors.orange;
      case 'arrived_pickup':
      case 'arrived_destination':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _fitBounds(LatLng point1, LatLng point2) {
    if (_mapController == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        point1.latitude < point2.latitude ? point1.latitude : point2.latitude,
        point1.longitude < point2.longitude
            ? point1.longitude
            : point2.longitude,
      ),
      northeast: LatLng(
        point1.latitude > point2.latitude ? point1.latitude : point2.latitude,
        point1.longitude > point2.longitude
            ? point1.longitude
            : point2.longitude,
      ),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  void _callCustomer(String? phone) async {
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor telepon tidak tersedia')),
      );
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28.sp),
            SizedBox(width: 12.w),
            Text(
              'Selesaikan Pengiriman?',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          'Pastikan barang sudah diterima oleh customer dengan baik.',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(fontSize: 14.sp)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement complete delivery
              ref
                  .read(driverTrackingControllerProvider.notifier)
                  .stopTracking();
              // Navigate back after completion
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) Navigator.pop(context);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Selesai', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }
}
