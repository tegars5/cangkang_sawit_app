import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/tracking_controller.dart';
import '../widgets/tracking_timeline_widget.dart';
import '../widgets/driver_info_card.dart';

/// Real-time tracking progress screen for Mitra
/// Shows shipment timeline, driver location on map, and live updates
class TrackingProgressScreen extends ConsumerStatefulWidget {
  final String shipmentId;

  const TrackingProgressScreen({super.key, required this.shipmentId});

  @override
  ConsumerState<TrackingProgressScreen> createState() =>
      _TrackingProgressScreenState();
}

class _TrackingProgressScreenState
    extends ConsumerState<TrackingProgressScreen> {
  GoogleMapController? _mapController;
  // Save controller reference to avoid using ref in dispose
  late final TrackingController _trackingController;

  @override
  void initState() {
    super.initState();
    // Save controller reference
    _trackingController = ref.read(trackingControllerProvider.notifier);
    // Start tracking when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackingController.startTracking(widget.shipmentId);
    });
  }

  @override
  void dispose() {
    // Stop tracking when screen closes - safe to use saved reference
    _trackingController.stopTracking();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trackingControllerProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Lacak Pengiriman'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          // Real-time indicator
          if (state.isSubscribed)
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Row(
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
                    'Live',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            )
          : state.error != null
          ? _buildErrorState(state.error!)
          : state.shipment == null
          ? _buildNotFoundState()
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(trackingControllerProvider.notifier).refresh();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Map Section
                    _buildMapSection(state),

                    // Driver Info Card
                    if (state.shipment != null)
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: DriverInfoCard(
                          shipment: state.shipment!,
                          driverLocation: state.driverLocation,
                        ),
                      ),

                    // Timeline Section
                    _buildTimelineSection(state),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMapSection(state) {
    final hasLocation = state.driverLocation != null;
    final location = state.driverLocation;

    return Container(
      height: 300.h,
      width: double.infinity,
      color: Colors.grey[300],
      child: hasLocation
          ? GoogleMap(
              initialCameraPosition: CameraPosition(
                target: location!.latLng,
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('driver'),
                  position: location.latLng,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                  infoWindow: InfoWindow(
                    title: 'Driver',
                    snippet: location.isRecent
                        ? 'Lokasi terbaru: ${location.timeAgo}'
                        : 'Terakhir update: ${location.timeAgo}',
                  ),
                  rotation: location.heading ?? 0,
                ),
                // Destination marker
                if (state.shipment?.destinationLat != null &&
                    state.shipment?.destinationLng != null)
                  Marker(
                    markerId: const MarkerId('destination'),
                    position: LatLng(
                      state.shipment!.destinationLat!,
                      state.shipment!.destinationLng!,
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
                    infoWindow: const InfoWindow(
                      title: 'Tujuan',
                      snippet: 'Lokasi pengiriman',
                    ),
                  ),
              },
              onMapCreated: (controller) {
                _mapController = controller;
                // Auto-zoom to show both markers
                if (state.shipment?.destinationLat != null) {
                  _fitBounds(
                    location.latLng,
                    LatLng(
                      state.shipment!.destinationLat!,
                      state.shipment!.destinationLng!,
                    ),
                  );
                }
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 48.sp,
                    color: Colors.grey[600],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Lokasi driver belum tersedia',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
    );
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

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  Widget _buildTimelineSection(state) {
    return Container(
      margin: EdgeInsets.all(16.w),
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
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: const Color(0xFF2E7D32),
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Riwayat Pengiriman',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          TrackingTimelineWidget(
            timeline: state.timeline,
            currentStatus: state.currentStatus,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: Colors.red[300]),
            SizedBox(height: 16.h),
            Text(
              'Gagal memuat data tracking',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(trackingControllerProvider.notifier)
                    .startTracking(widget.shipmentId);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64.sp, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              'Pengiriman tidak ditemukan',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Text(
              'Data pengiriman tidak tersedia',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
