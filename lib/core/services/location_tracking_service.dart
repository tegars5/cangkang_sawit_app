import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../shared/repositories/tracking_repository.dart';

/// Background GPS tracking service for driver
/// Auto-updates location every 30 seconds and sends to Supabase
class LocationTrackingService {
  static final LocationTrackingService _instance =
      LocationTrackingService._internal();
  factory LocationTrackingService() => _instance;
  LocationTrackingService._internal();

  Timer? _timer;
  String? _currentShipmentId;
  final _trackingRepository = TrackingRepository();
  bool _isTracking = false;

  bool get isTracking => _isTracking;
  String? get currentShipmentId => _currentShipmentId;

  /// Start tracking for a shipment
  Future<bool> startTracking(String shipmentId) async {
    if (_isTracking && _currentShipmentId == shipmentId) {
      return true; // Already tracking this shipment
    }

    // Stop previous tracking if any
    stopTracking();

    // Request location permissions
    final hasPermission = await _requestLocationPermission();
    if (!hasPermission) {
      return false;
    }

    _currentShipmentId = shipmentId;
    _isTracking = true;

    // Initial location update
    await _updateLocation();

    // Start periodic updates (every 30 seconds)
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateLocation();
    });

    print('📍 Location tracking started for shipment: $shipmentId');
    return true;
  }

  /// Stop tracking
  void stopTracking() {
    _timer?.cancel();
    _timer = null;
    _currentShipmentId = null;
    _isTracking = false;
    print('📍 Location tracking stopped');
  }

  /// Request location permissions
  Future<bool> _requestLocationPermission() async {
    // Check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('❌ Location services are disabled');
      return false;
    }

    // Check permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('❌ Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('❌ Location permissions are permanently denied');
      return false;
    }

    // Request background location for Android
    if (permission == LocationPermission.whileInUse) {
      // Try to get always permission for background tracking
      final status = await Permission.locationAlways.request();
      if (!status.isGranted) {
        print('⚠️ Background location not granted, will use foreground only');
      }
    }

    return true;
  }

  /// Get current location and update to Supabase
  Future<void> _updateLocation() async {
    if (_currentShipmentId == null || !_isTracking) return;

    try {
      // Get current user ID (driver ID)
      final driverId = await _trackingRepository.getCurrentUserId();
      if (driverId == null) {
        print('❌ Driver ID not found');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      await _trackingRepository.updateDriverLocation(
        driverId: driverId,
        shipmentId: _currentShipmentId!,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        speed: position.speed,
        heading: position.heading,
      );

      print('📍 Location updated: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('❌ Error updating location: $e');
      // Don't stop tracking on error, just log it
    }
  }

  /// Get current position once (for initial map display)
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await _requestLocationPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('❌ Error getting current position: $e');
      return null;
    }
  }

  /// Listen to position stream for real-time updates
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }
}
