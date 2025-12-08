import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/shipment.dart';
import '../controllers/driver_tracking_controller.dart';
import '../services/driver_background_tracking_service.dart';

class DriverTrackingPage extends ConsumerStatefulWidget {
  final Shipment shipment;

  const DriverTrackingPage({super.key, required this.shipment});

  @override
  ConsumerState<DriverTrackingPage> createState() => _DriverTrackingPageState();
}

class _DriverTrackingPageState extends ConsumerState<DriverTrackingPage> {
  GoogleMapController? _mapController;
  Timer? _locationSaveTimer;
  Timer? _mapUpdateTimer;
  final DriverBackgroundTrackingService _backgroundService =
      DriverBackgroundTrackingService();

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  @override
  void dispose() {
    _locationSaveTimer?.cancel();
    _mapUpdateTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeTracking() async {
    final controller = ref.read(driverTrackingControllerProvider.notifier);
    final currentUser = Supabase.instance.client.auth.currentUser;

    if (currentUser == null) {
      _showError('User tidak ditemukan');
      return;
    }

    // Set active shipment
    controller.setActiveShipment(widget.shipment);

    // Auto-start tracking untuk shipment in_transit
    if (widget.shipment.status == 'in_transit' ||
        widget.shipment.status == 'pending') {
      await _startTracking();
    }
  }

  Future<void> _startTracking() async {
    final controller = ref.read(driverTrackingControllerProvider.notifier);
    final currentUser = Supabase.instance.client.auth.currentUser;

    if (currentUser == null) return;

    final driverId = currentUser.id;

    // Start foreground tracking
    await controller.startTracking(driverId);

    // Start background tracking (HIGH PRIORITY)
    await _backgroundService.startBackgroundTracking(
      driverId: driverId,
      shipmentId: widget.shipment.id,
    );

    // Setup periodic location save (every 30 seconds)
    _locationSaveTimer?.cancel();
    _locationSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      controller.saveLocationToDatabase(driverId);
    });

    // Setup periodic map update (every 2 seconds for smooth animation)
    _mapUpdateTimer?.cancel();
    _mapUpdateTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _updateMapMarkers();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tracking dimulai'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _stopTracking() async {
    // Show warning dialog
    final shouldStop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hentikan Tracking?'),
        content: const Text(
          'Tracking diperlukan untuk monitoring pengiriman. Yakin ingin menghentikan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hentikan'),
          ),
        ],
      ),
    );

    if (shouldStop == true) {
      final controller = ref.read(driverTrackingControllerProvider.notifier);
      controller.stopTracking();

      // Stop background tracking
      await _backgroundService.stopBackgroundTracking();

      _locationSaveTimer?.cancel();
      _mapUpdateTimer?.cancel();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tracking dihentikan'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _updateMapMarkers() {
    final state = ref.read(driverTrackingControllerProvider);

    if (state.currentLocation == null) return;

    final markers = <Marker>{};

    // Driver marker
    markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: LatLng(
          state.currentLocation!.latitude,
          state.currentLocation!.longitude,
        ),
        infoWindow: InfoWindow(
          title: 'Posisi Anda',
          snippet: state.currentLocation!.formattedSpeed,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        rotation: state.currentLocation!.heading ?? 0,
      ),
    );

    // Destination marker
    if (widget.shipment.destinationLat != null &&
        widget.shipment.destinationLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(
            widget.shipment.destinationLat!,
            widget.shipment.destinationLng!,
          ),
          infoWindow: InfoWindow(
            title: 'Tujuan',
            snippet: widget.shipment.destinationAddress,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      // Polyline route
      final polylines = <Polyline>{
        Polyline(
          polylineId: const PolylineId('route'),
          points: [
            LatLng(
              state.currentLocation!.latitude,
              state.currentLocation!.longitude,
            ),
            LatLng(
              widget.shipment.destinationLat!,
              widget.shipment.destinationLng!,
            ),
          ],
          color: const Color(0xFF2E7D32),
          width: 4,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      };

      setState(() {
        _polylines = polylines;
      });
    }

    setState(() {
      _markers = markers;
    });

    // Auto-follow driver location
    if (_isMapReady && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(
            state.currentLocation!.latitude,
            state.currentLocation!.longitude,
          ),
        ),
      );
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(driverTrackingControllerProvider);
    final controller = ref.read(driverTrackingControllerProvider.notifier);

    // Show error if any
    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showError(state.errorMessage!);
        controller.clearError();
      });
    }

    // Default location (Jakarta) if no current location
    final initialLat = state.currentLocation?.latitude ?? -6.2088;
    final initialLng = state.currentLocation?.longitude ?? 106.8456;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Google Maps
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(initialLat, initialLng),
              zoom: 15,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              _isMapReady = true;
              _updateMapMarkers();
            },
          ),

          // Top App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8.h,
                left: 16.w,
                right: 16.w,
                bottom: 16.h,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Tracking',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.shipment.deliveryNoteNumber,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // GPS Status Icon
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: state.isTracking
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      state.isTracking ? Icons.gps_fixed : Icons.gps_off,
                      color: state.isTracking ? Colors.green : Colors.red,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Map Controls - Right Side
          Positioned(
            right: 16.w,
            bottom: 300.h,
            child: Column(
              children: [
                // Zoom In
                _buildMapControl(
                  icon: Icons.add,
                  onTap: () {
                    _mapController?.animateCamera(CameraUpdate.zoomIn());
                  },
                  isTop: true,
                ),
                // Zoom Out
                _buildMapControl(
                  icon: Icons.remove,
                  onTap: () {
                    _mapController?.animateCamera(CameraUpdate.zoomOut());
                  },
                  isBottom: true,
                ),
              ],
            ),
          ),

          // My Location Button
          Positioned(
            right: 16.w,
            bottom: 240.h,
            child: _buildMapControl(
              icon: Icons.my_location,
              onTap: () {
                if (state.currentLocation != null) {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLng(
                      LatLng(
                        state.currentLocation!.latitude,
                        state.currentLocation!.longitude,
                      ),
                    ),
                  );
                }
              },
            ),
          ),

          // Bottom Info Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle
                  Container(
                    width: 36.w,
                    height: 4.h,
                    margin: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        // Stats Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.speed,
                                label: 'Kecepatan',
                                value:
                                    state.currentLocation?.formattedSpeed ??
                                    '-',
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.straighten,
                                label: 'Jarak',
                                value: controller.getFormattedDistance(),
                                color: Colors.orange,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.access_time,
                                label: 'ETA',
                                value: state.estimatedArrival ?? '-',
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        // Destination Info
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 24.sp,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tujuan Pengiriman',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      widget.shipment.destinationAddress,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Tracking Control Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: state.isLoading
                                ? null
                                : () {
                                    if (state.isTracking) {
                                      _stopTracking();
                                    } else {
                                      _startTracking();
                                    }
                                  },
                            icon: Icon(
                              state.isTracking ? Icons.stop : Icons.play_arrow,
                              size: 20.sp,
                            ),
                            label: Text(
                              state.isLoading
                                  ? 'Loading...'
                                  : state.isTracking
                                  ? 'Hentikan Tracking'
                                  : 'Mulai Tracking',
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: state.isTracking
                                  ? Colors.red
                                  : const Color(0xFF1B5E20),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControl({
    required IconData icon,
    required VoidCallback onTap,
    bool isTop = false,
    bool isBottom = false,
  }) {
    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: isTop ? Radius.circular(8.r) : Radius.zero,
          topRight: isTop ? Radius.circular(8.r) : Radius.zero,
          bottomLeft: isBottom ? Radius.circular(8.r) : Radius.zero,
          bottomRight: isBottom ? Radius.circular(8.r) : Radius.zero,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.black54, size: 20.sp),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
