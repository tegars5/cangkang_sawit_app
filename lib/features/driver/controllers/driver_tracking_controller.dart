import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../shared/models/driver_location.dart';
import '../../../shared/models/shipment.dart';
import '../../../core/services/gps_service.dart';
import '../../../shared/repositories/location_repository.dart';

/// State untuk Driver Tracking
class DriverTrackingState {
  final bool isTracking;
  final DriverLocation? currentLocation;
  final Shipment? activeShipment;
  final double? distanceToDestination; // dalam meter
  final String? estimatedArrival; // format: "14:30"
  final String? errorMessage;
  final bool isLoading;

  const DriverTrackingState({
    this.isTracking = false,
    this.currentLocation,
    this.activeShipment,
    this.distanceToDestination,
    this.estimatedArrival,
    this.errorMessage,
    this.isLoading = false,
  });

  DriverTrackingState copyWith({
    bool? isTracking,
    DriverLocation? currentLocation,
    Shipment? activeShipment,
    double? distanceToDestination,
    String? estimatedArrival,
    String? errorMessage,
    bool? isLoading,
  }) {
    return DriverTrackingState(
      isTracking: isTracking ?? this.isTracking,
      currentLocation: currentLocation ?? this.currentLocation,
      activeShipment: activeShipment ?? this.activeShipment,
      distanceToDestination:
          distanceToDestination ?? this.distanceToDestination,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Controller untuk Driver Tracking
class DriverTrackingController extends Notifier<DriverTrackingState> {
  final GpsService _gpsService = GpsService();
  final LocationRepository _locationRepository = LocationRepository();

  @override
  DriverTrackingState build() => const DriverTrackingState();

  /// Set active shipment
  void setActiveShipment(Shipment shipment) {
    state = state.copyWith(activeShipment: shipment);
    _calculateDistanceAndETA();
  }

  /// Update current location
  void updateLocation(Position position, String driverId) {
    final location = DriverLocation(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      driverId: driverId,
      shipmentId: state.activeShipment?.id,
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      speed: position.speed,
      heading: position.heading,
      timestamp: DateTime.now(),
      createdAt: DateTime.now(),
    );

    state = state.copyWith(currentLocation: location);
    _calculateDistanceAndETA();
  }

  /// Calculate distance and ETA to destination
  void _calculateDistanceAndETA() {
    if (state.currentLocation == null || state.activeShipment == null) {
      return;
    }

    final shipment = state.activeShipment!;

    // Check if destination coordinates exist
    if (shipment.destinationLat == null || shipment.destinationLng == null) {
      return;
    }

    // Calculate distance using Geolocator
    final distance = _gpsService.calculateDistance(
      state.currentLocation!.latitude,
      state.currentLocation!.longitude,
      shipment.destinationLat!,
      shipment.destinationLng!,
    );

    state = state.copyWith(distanceToDestination: distance);

    // Calculate ETA based on current speed
    // Assume average speed of 40 km/h if current speed is 0 or null
    final currentSpeed = state.currentLocation!.speed ?? 0;
    final averageSpeed = currentSpeed > 0 ? currentSpeed : 40.0; // km/h

    // Convert distance from meters to km
    final distanceKm = distance / 1000;

    // Calculate time in hours
    final timeHours = distanceKm / averageSpeed;

    // Calculate ETA
    final now = DateTime.now();
    final eta = now.add(Duration(minutes: (timeHours * 60).round()));

    // Format ETA as "HH:mm"
    final etaFormatted =
        '${eta.hour.toString().padLeft(2, '0')}:${eta.minute.toString().padLeft(2, '0')}';

    state = state.copyWith(estimatedArrival: etaFormatted);
  }

  /// Start tracking
  Future<void> startTracking(String driverId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _gpsService.startTracking(
        onLocationUpdate: (position) {
          updateLocation(position, driverId);
        },
        intervalSeconds: 10, // Update setiap 10 detik
      );

      state = state.copyWith(isTracking: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Gagal memulai tracking: $e',
        isLoading: false,
      );
    }
  }

  /// Stop tracking
  void stopTracking() {
    _gpsService.stopTracking();
    state = state.copyWith(isTracking: false);
  }

  /// Save current location to database
  Future<void> saveLocationToDatabase(String driverId) async {
    if (state.currentLocation == null) return;

    try {
      await _locationRepository.saveLocation(
        shipmentId: state.activeShipment?.id ?? 'no-shipment',
        driverId: driverId,
        latitude: state.currentLocation!.latitude,
        longitude: state.currentLocation!.longitude,
        bearing: state.currentLocation!.heading,
        speed: state.currentLocation!.speed,
        isActive: state.isTracking,
      );
    } catch (e) {
      // Log error but don't stop tracking
      print('Error saving location to database: $e');
    }
  }

  /// Get formatted distance
  String getFormattedDistance() {
    if (state.distanceToDestination == null) return '-';

    final distanceKm = state.distanceToDestination! / 1000;

    if (distanceKm < 1) {
      return '${state.distanceToDestination!.toStringAsFixed(0)} m';
    } else {
      return '${distanceKm.toStringAsFixed(1)} km';
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Reset state
  void reset() {
    _gpsService.stopTracking();
    state = const DriverTrackingState();
  }
}

/// Provider untuk Driver Tracking Controller
final driverTrackingControllerProvider =
    NotifierProvider<DriverTrackingController, DriverTrackingState>(() {
      return DriverTrackingController();
    });
