import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final loc.Location _location = loc.Location();
  bool _serviceEnabled = false;
  loc.PermissionStatus _permissionGranted = loc.PermissionStatus.denied;

  /// Initialize location service
  Future<bool> initialize() async {
    try {
      // Check if location services are enabled
      _serviceEnabled = await _location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await _location.requestService();
        if (!_serviceEnabled) {
          return false;
        }
      }

      // Check permissions
      _permissionGranted = await _location.hasPermission();
      if (_permissionGranted == loc.PermissionStatus.denied) {
        _permissionGranted = await _location.requestPermission();
        if (_permissionGranted != loc.PermissionStatus.granted) {
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error initializing location service: $e');
      return false;
    }
  }

  /// Get current position using Geolocator (more accurate)
  Future<Position?> getCurrentPosition() async {
    try {
      bool initialized = await initialize();
      if (!initialized) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Error getting current position: $e');
      return null;
    }
  }

  /// Get current location using Location package (for background tracking)
  Future<loc.LocationData?> getCurrentLocation() async {
    try {
      bool initialized = await initialize();
      if (!initialized) return null;

      return await _location.getLocation();
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  /// Start location tracking (background-friendly)
  Stream<loc.LocationData> getLocationStream({
    int intervalMs = 5000, // 5 seconds
    double distanceFilter = 10.0, // 10 meters
  }) {
    return _location.onLocationChanged.handleError((error) {
      debugPrint('Location stream error: $error');
    });
  }

  /// Setup location settings for background tracking
  Future<void> enableBackgroundMode() async {
    try {
      await _location.enableBackgroundMode(enable: true);
      await _location.changeSettings(
        accuracy: loc.LocationAccuracy.high,
        interval: 5000, // 5 seconds
        distanceFilter: 10.0, // 10 meters
      );
    } catch (e) {
      debugPrint('Error enabling background mode: $e');
    }
  }

  /// Check location permission status
  Future<bool> hasPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Request location permission
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Calculate distance between two points in meters
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Format distance for display
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }

  /// Convert Location coordinates to Google Maps format
  Map<String, double> toGoogleMapsCoordinates(loc.LocationData location) {
    return {
      'latitude': location.latitude ?? 0.0,
      'longitude': location.longitude ?? 0.0,
    };
  }

  /// Convert Position to Google Maps format
  Map<String, double> positionToGoogleMapsCoordinates(Position position) {
    return {'latitude': position.latitude, 'longitude': position.longitude};
  }
}
