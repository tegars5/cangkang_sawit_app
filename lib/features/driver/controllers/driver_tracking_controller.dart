import 'package:flutter_riverpod/legacy.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import '../models/driver_tracking_state.dart';
import '../../shipments/domain/entities/shipment.dart';
import '../../tracking/domain/entities/driver_location.dart';

/// Driver Tracking Controller Provider
final driverTrackingControllerProvider =
    StateNotifierProvider<DriverTrackingController, DriverTrackingState>(
      (ref) => DriverTrackingController(),
    );

/// Controller for driver real-time tracking
class DriverTrackingController extends StateNotifier<DriverTrackingState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  DriverTrackingController() : super(const DriverTrackingState());

  /// Set active shipment
  void setActiveShipment(Shipment shipment) {
    state = state.copyWith(
      activeShipmentId: shipment.id,
      destinationLat: shipment.deliveryLatitude,
      destinationLng: shipment.deliveryLongitude,
    );
  }

  /// Start tracking for a shipment
  void startTracking(String shipmentId) {
    state = state.copyWith(
      isTracking: true,
      activeShipmentId: shipmentId,
      error: null,
    );
  }

  /// Stop tracking
  void stopTracking() {
    state = state.copyWith(isTracking: false, activeShipmentId: null);
  }

  /// Update current location
  void updateLocation(double lat, double lng) {
    if (state.isTracking) {
      state = state.copyWith(currentLat: lat, currentLng: lng);
      _calculateEstimatedArrival(lat, lng);
    }
  }

  /// Update current location with DriverLocation object
  void updateDriverLocation(DriverLocation location) {
    if (state.isTracking) {
      state = state.copyWith(
        currentLocation: location,
        currentLat: location.latitude,
        currentLng: location.longitude,
      );
      _calculateEstimatedArrival(location.latitude, location.longitude);
    }
  }

  /// Save location to database
  Future<void> saveLocationToDatabase(String driverId) async {
    if (!state.isTracking ||
        state.currentLat == null ||
        state.currentLng == null) {
      return;
    }

    try {
      state = state.copyWith(isLoading: true);

      // Get current position for accuracy
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Insert location into driver_locations table
      await _supabase.from('driver_locations').insert({
        'driver_id': driverId,
        'shipment_id': state.activeShipmentId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'speed': position.speed,
        'heading': position.heading,
        'timestamp': DateTime.now().toIso8601String(),
      });

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save location: $e',
      );
    }
  }

  /// Calculate distance between two points using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // km

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Get formatted distance to destination
  String getFormattedDistance() {
    if (state.currentLat == null || state.currentLng == null) {
      return '-';
    }

    // Get destination from active shipment if available
    if (state.destinationLat != null && state.destinationLng != null) {
      final distance = _calculateDistance(
        state.currentLat!,
        state.currentLng!,
        state.destinationLat!,
        state.destinationLng!,
      );

      if (distance < 1) {
        return '${(distance * 1000).toStringAsFixed(0)} m';
      } else {
        return '${distance.toStringAsFixed(1)} km';
      }
    }

    return '-';
  }

  /// Calculate estimated arrival time
  void _calculateEstimatedArrival(double currentLat, double currentLng) {
    // This would calculate ETA based on distance and average speed
    // For now, set a placeholder
    final now = DateTime.now();
    final eta = now.add(const Duration(minutes: 30)); // Example: 30 min ETA
    state = state.copyWith(
      estimatedArrival:
          '${eta.hour.toString().padLeft(2, '0')}:${eta.minute.toString().padLeft(2, '0')}',
    );
  }

  /// Set error
  void setError(String error) {
    state = state.copyWith(error: error);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
