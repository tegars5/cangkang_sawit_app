import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/tracking_notifier.dart';

/// Tracking Map Page - Real-time driver location tracking
class TrackingMapPage extends ConsumerStatefulWidget {
  final String shipmentId;
  final String driverName;

  const TrackingMapPage({
    super.key,
    required this.shipmentId,
    required this.driverName,
  });

  @override
  ConsumerState<TrackingMapPage> createState() => _TrackingMapPageState();
}

class _TrackingMapPageState extends ConsumerState<TrackingMapPage> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // Start tracking when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(trackingNotifierProvider.notifier)
          .startTracking(widget.shipmentId);
    });
  }

  @override
  void dispose() {
    // Stop tracking when leaving page
    ref.read(trackingNotifierProvider.notifier).stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(trackingNotifierProvider);

    // Update markers when location changes
    if (trackingState.currentLocation != null) {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId(
            'driver_${trackingState.currentLocation!.driverId}',
          ),
          position: LatLng(
            trackingState.currentLocation!.latitude,
            trackingState.currentLocation!.longitude,
          ),
          infoWindow: InfoWindow(
            title: widget.driverName,
            snippet: trackingState.currentLocation!.getFormattedSpeed(),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );

      // Move camera to new position
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(
            trackingState.currentLocation!.latitude,
            trackingState.currentLocation!.longitude,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking: ${widget.driverName}'),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          if (trackingState.isTracking)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: const Icon(Icons.sensors, color: Colors.greenAccent),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: trackingState.currentLocation != null
                  ? LatLng(
                      trackingState.currentLocation!.latitude,
                      trackingState.currentLocation!.longitude,
                    )
                  : const LatLng(-6.2088, 106.8456), // Default to Jakarta
              zoom: 15,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),

          // Info Card at bottom
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom: 16.h,
            child: _buildInfoCard(trackingState),
          ),

          // Loading indicator
          if (trackingState.isLoading)
            const Center(child: CircularProgressIndicator()),

          // Error message
          if (trackingState.errorMessage != null)
            Positioned(
              top: 16.h,
              left: 16.w,
              right: 16.w,
              child: Card(
                color: Colors.red[50],
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red[700]),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          trackingState.errorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          ref
                              .read(trackingNotifierProvider.notifier)
                              .clearError();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(trackingState) {
    final location = trackingState.currentLocation;
    if (location == null) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: const Text('Menunggu lokasi driver...'),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Driver info
            Row(
              children: [
                const Icon(Icons.person, color: Color(0xFF2E7D32)),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.driverName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        location.getTimeAgo(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: location.isRecent()
                        ? Colors.green[100]
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    location.isRecent() ? 'ACTIVE' : 'DELAYED',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: location.isRecent()
                          ? Colors.green[700]
                          : Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Location stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.speed,
                  label: 'Kecepatan',
                  value: location.getFormattedSpeed(),
                ),
                _buildStatItem(
                  icon: Icons.navigation,
                  label: 'Arah',
                  value: location.getDirectionText(),
                ),
                if (trackingState.totalDistance != null)
                  _buildStatItem(
                    icon: Icons.route,
                    label: 'Jarak',
                    value:
                        '${(trackingState.totalDistance! / 1000).toStringAsFixed(1)} km',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20.sp, color: const Color(0xFF2E7D32)),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
