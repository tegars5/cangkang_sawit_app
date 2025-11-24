import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/google_map_widget.dart';

class DeliveryTrackingScreen extends StatefulWidget {
  final String shipmentId;
  final String shipmentNumber;
  final Map<String, dynamic> shipmentData;

  const DeliveryTrackingScreen({
    super.key,
    required this.shipmentId,
    required this.shipmentNumber,
    required this.shipmentData,
  });

  @override
  State<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen> {
  GoogleMapController? _mapController;

  // Mock data - in real app, this would come from backend
  final LatLng _driverLocation = const LatLng(-6.2088, 106.8456); // Jakarta
  final LatLng _destination = const LatLng(-6.2297, 106.8457); // Destination
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  final String _estimatedArrival = "14:30";
  double _currentZoom = 13.0;
  bool _isBottomSheetExpanded = false;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() {
    // Add driver marker
    _markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: _driverLocation,
        infoWindow: InfoWindow(
          title: 'Driver: ${widget.shipmentData['driver_name'] ?? 'Unknown'}',
          snippet: 'Current Location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // Add destination marker
    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: _destination,
        infoWindow: const InfoWindow(
          title: 'Destination',
          snippet: 'Delivery Location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    // Add route polyline
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [_driverLocation, _destination],
        color: const Color(0xFF2E7D32),
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(20)],
      ),
    );

    setState(() {});
  }

  void _contactDriver() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${widget.shipmentData['driver_name']}...'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }

  void _zoomIn() {
    _currentZoom = (_currentZoom + 1).clamp(0, 20);
    _mapController?.animateCamera(CameraUpdate.zoomTo(_currentZoom));
  }

  void _zoomOut() {
    _currentZoom = (_currentZoom - 1).clamp(0, 20);
    _mapController?.animateCamera(CameraUpdate.zoomTo(_currentZoom));
  }

  void _goToMyLocation() {
    _mapController?.animateCamera(CameraUpdate.newLatLng(_driverLocation));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Top App Bar
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 16.w,
              right: 16.w,
              bottom: 16.h,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF0D47A1), // Primary color
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                ),
                Expanded(
                  child: Text(
                    'Live Tracking',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 48.w), // Balance for back button
              ],
            ),
          ),

          // Map Section with Bottom Sheet
          Expanded(
            child: Stack(
              children: [
                // Map
                GoogleMapWidget(
                  initialLat: _driverLocation.latitude,
                  initialLng: _driverLocation.longitude,
                  zoom: _currentZoom,
                  markers: _markers,
                  polylines: _polylines,
                  showCurrentLocation: false,
                  enableLocationTracking: false,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                ),

                // Map Controls - Right Side
                Positioned(
                  right: 16.w,
                  bottom: 240.h, // Adjusted for bottom sheet
                  child: Column(
                    children: [
                      // Zoom In Button
                      Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _zoomIn,
                          icon: const Icon(
                            Icons.add,
                            color: Colors.black54,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),

                      // Zoom Out Button
                      Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _zoomOut,
                          icon: const Icon(
                            Icons.remove,
                            color: Colors.black54,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),

                // Current Location Button
                Positioned(
                  right: 16.w,
                  bottom: 180.h,
                  child: Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _goToMyLocation,
                      icon: const Icon(
                        Icons.my_location,
                        color: Color(0xFF0D47A1),
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),

                // Bottom Sheet
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag Handle
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isBottomSheetExpanded = !_isBottomSheetExpanded;
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: Center(
                              child: Container(
                                width: 36.w,
                                height: 4.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2.r),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Bottom Sheet Content
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Order Info Header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Order ID #${widget.shipmentNumber}',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: const Color(
                                              0xFF757575,
                                            ), // text-light/70
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          'Palm Kernel Shells - 8 Ton',
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(
                                              0xFF424242,
                                            ), // text-light
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF2E7D32,
                                      ).withValues(alpha: 0.1), // secondary/10
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      'En Route',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(
                                          0xFF2E7D32,
                                        ), // secondary
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),

                              // Progress Section
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'En Route to Port',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(
                                            0xFF424242,
                                          ), // text-light
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),

                                  // Progress Bar
                                  Container(
                                    height: 8.h,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFE0E0E0,
                                      ), // border-light
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: FractionallySizedBox(
                                      widthFactor: 0.65, // 65% progress
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF2E7D32,
                                          ), // secondary
                                          borderRadius: BorderRadius.circular(
                                            4.r,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8.h),

                                  Text(
                                    'ETA: $_estimatedArrival WIB',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(
                                        0xFF757575,
                                      ), // text-light/70
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),

                              // Divider
                              Divider(
                                height: 32.h,
                                thickness: 1,
                                color: const Color(0xFFE0E0E0), // border-light
                              ),

                              // Driver Info Section
                              Row(
                                children: [
                                  // Driver Avatar
                                  Container(
                                    width: 56.w,
                                    height: 56.w,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.w),

                                  // Driver Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.shipmentData['driver_name'] ??
                                              'Budi Santoso',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(
                                              0xFF424242,
                                            ), // text-light
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          'Dump Truck - B 1234 XYZ',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: const Color(
                                              0xFF757575,
                                            ), // text-light/70
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Action Buttons
                                  Row(
                                    children: [
                                      // Chat Button
                                      Container(
                                        width: 40.w,
                                        height: 40.w,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2E7D32)
                                              .withValues(
                                                alpha: 0.1,
                                              ), // secondary/10
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Opening chat...',
                                                ),
                                                backgroundColor: Color(
                                                  0xFF2E7D32,
                                                ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.chat,
                                            color: Color(
                                              0xFF2E7D32,
                                            ), // secondary
                                            size: 20,
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),

                                      // Call Button
                                      Container(
                                        width: 40.w,
                                        height: 40.w,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF0D47A1), // primary
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          onPressed: _contactDriver,
                                          icon: const Icon(
                                            Icons.call,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 24.h),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Navigation Bar
          Container(
            height: 80.h,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Color(0xFFE0E0E0), // border-light
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'Home', false),
                _buildNavItem(Icons.list_alt, 'Orders', false),
                _buildNavItem(Icons.pin_drop, 'Tracking', true),
                _buildNavItem(Icons.person, 'Profile', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: isActive
                  ? const Color(0xFF0D47A1) // primary
                  : const Color(0xFF757575), // text-light/70
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: isActive
                    ? const Color(0xFF0D47A1) // primary
                    : const Color(0xFF757575), // text-light/70
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
