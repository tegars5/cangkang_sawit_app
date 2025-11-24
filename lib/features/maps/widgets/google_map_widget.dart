import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import '../../../core/services/location_service.dart';

class GoogleMapWidget extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final double zoom;
  final Set<Marker>? markers;
  final Set<Polyline>? polylines;
  final bool showCurrentLocation;
  final bool enableLocationTracking;
  final Function(LatLng)? onMapTapped;
  final Function(GoogleMapController)? onMapCreated;

  const GoogleMapWidget({
    super.key,
    this.initialLat,
    this.initialLng,
    this.zoom = 15.0,
    this.markers,
    this.polylines,
    this.showCurrentLocation = true,
    this.enableLocationTracking = false,
    this.onMapTapped,
    this.onMapCreated,
  });

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  GoogleMapController? _controller;
  final LocationService _locationService = LocationService();
  LatLng _currentLocation = const LatLng(-6.2088, 106.8456); // Jakarta default
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    try {
      // Initialize location service
      bool locationInitialized = await _locationService.initialize();

      if (locationInitialized && widget.showCurrentLocation) {
        loc.LocationData? currentLocation = await _locationService
            .getCurrentLocation();
        if (currentLocation != null && mounted) {
          setState(() {
            _currentLocation = LatLng(
              currentLocation.latitude!,
              currentLocation.longitude!,
            );
          });
        }
      }

      // Use provided initial location if available
      if (widget.initialLat != null && widget.initialLng != null) {
        _currentLocation = LatLng(widget.initialLat!, widget.initialLng!);
      }

      // Setup markers
      if (widget.markers != null) {
        _markers = widget.markers!;
      }

      if (widget.showCurrentLocation) {
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: _currentLocation,
            infoWindow: const InfoWindow(title: 'Lokasi Saat Ini'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );
      }

      // Setup polylines
      if (widget.polylines != null) {
        _polylines = widget.polylines!;
      }

      setState(() {
        _isLoading = false;
      });

      // Start location tracking if enabled
      if (widget.enableLocationTracking) {
        _startLocationTracking();
      }
    } catch (e) {
      debugPrint('Error initializing map: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startLocationTracking() {
    _locationService.getLocationStream().listen((loc.LocationData location) {
      if (location.latitude != null && location.longitude != null && mounted) {
        LatLng newLocation = LatLng(location.latitude!, location.longitude!);

        setState(() {
          _currentLocation = newLocation;

          // Update current location marker
          _markers.removeWhere(
            (marker) => marker.markerId.value == 'current_location',
          );
          _markers.add(
            Marker(
              markerId: const MarkerId('current_location'),
              position: newLocation,
              infoWindow: const InfoWindow(title: 'Lokasi Saat Ini'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
            ),
          );
        });

        // Move camera to new location
        _controller?.animateCamera(CameraUpdate.newLatLng(newLocation));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat peta...'),
          ],
        ),
      );
    }

    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
        if (widget.onMapCreated != null) {
          widget.onMapCreated!(controller);
        }
      },
      initialCameraPosition: CameraPosition(
        target: _currentLocation,
        zoom: widget.zoom,
      ),
      markers: _markers,
      polylines: _polylines,
      onTap: widget.onMapTapped,
      myLocationEnabled: false, // We handle this manually
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: true,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: true,
      zoomGesturesEnabled: true,
    );
  }

  /// Public method to add marker
  void addMarker(Marker marker) {
    if (mounted) {
      setState(() {
        _markers.add(marker);
      });
    }
  }

  /// Public method to remove marker
  void removeMarker(String markerId) {
    if (mounted) {
      setState(() {
        _markers.removeWhere((marker) => marker.markerId.value == markerId);
      });
    }
  }

  /// Public method to add polyline
  void addPolyline(Polyline polyline) {
    if (mounted) {
      setState(() {
        _polylines.add(polyline);
      });
    }
  }

  /// Public method to move camera
  void moveCamera(LatLng position, {double? zoom}) {
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: zoom ?? widget.zoom),
      ),
    );
  }

  /// Public method to get current location
  LatLng getCurrentLocation() => _currentLocation;
}
