import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../shipments/domain/entities/shipment.dart';

/// Immutable state model for driver navigation
class DriverNavigationState {
  final Shipment shipment;
  final LatLng destination;
  final String currentStatus;
  final bool isTracking;
  final LatLng? currentLocation;
  final double distanceToDestination;
  final int estimatedTimeMinutes;

  const DriverNavigationState({
    required this.shipment,
    required this.destination,
    required this.currentStatus,
    this.isTracking = false,
    this.currentLocation,
    this.distanceToDestination = 0.0,
    this.estimatedTimeMinutes = 0,
  });

  /// Create a copy with modified fields
  DriverNavigationState copyWith({
    Shipment? shipment,
    LatLng? destination,
    String? currentStatus,
    bool? isTracking,
    LatLng? currentLocation,
    double? distanceToDestination,
    int? estimatedTimeMinutes,
  }) {
    return DriverNavigationState(
      shipment: shipment ?? this.shipment,
      destination: destination ?? this.destination,
      currentStatus: currentStatus ?? this.currentStatus,
      isTracking: isTracking ?? this.isTracking,
      currentLocation: currentLocation ?? this.currentLocation,
      distanceToDestination:
          distanceToDestination ?? this.distanceToDestination,
      estimatedTimeMinutes: estimatedTimeMinutes ?? this.estimatedTimeMinutes,
    );
  }
}
