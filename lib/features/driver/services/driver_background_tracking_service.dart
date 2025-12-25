import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// Background tracking service for driver location updates
///
/// Handles continuous location tracking when driver is on delivery
class DriverBackgroundTrackingService {
  Timer? _locationTimer;
  StreamSubscription<Position>? _positionStream;
  bool _isTracking = false;

  /// Start background location tracking
  Future<void> startTracking({
    required Function(double lat, double lng) onLocationUpdate,
    Duration interval = const Duration(seconds: 30),
  }) async {
    if (_isTracking) return;

    // Check location permissions
    final hasPermission = await _checkLocationPermission();
    if (!hasPermission) {
      throw Exception('Location permission not granted');
    }

    _isTracking = true;

    // Start periodic location updates
    _locationTimer = Timer.periodic(interval, (timer) async {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        onLocationUpdate(position.latitude, position.longitude);
      } catch (e) {
        // Handle error silently
        print('Location update error: $e');
      }
    });
  }

  /// Stop background location tracking
  void stopTracking() {
    _isTracking = false;
    _locationTimer?.cancel();
    _locationTimer = null;
    _positionStream?.cancel();
    _positionStream = null;
  }

  /// Check if tracking is active
  bool get isTracking => _isTracking;

  /// Check location permission
  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Dispose resources
  void dispose() {
    stopTracking();
  }
}
