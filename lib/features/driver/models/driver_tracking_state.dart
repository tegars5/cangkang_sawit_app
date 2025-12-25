import '../../tracking/domain/entities/driver_location.dart';

/// Immutable state for driver location tracking
class DriverTrackingState {
  final bool isTracking;
  final String? activeShipmentId;
  final double? currentLat;
  final double? currentLng;
  final double? destinationLat;
  final double? destinationLng;
  final String? error;
  final DriverLocation? currentLocation;
  final bool isLoading;
  final String? estimatedArrival;

  const DriverTrackingState({
    this.isTracking = false,
    this.activeShipmentId,
    this.currentLat,
    this.currentLng,
    this.destinationLat,
    this.destinationLng,
    this.error,
    this.currentLocation,
    this.isLoading = false,
    this.estimatedArrival,
  });

  // Convenience getter for errorMessage (alias for error)
  String? get errorMessage => error;

  DriverTrackingState copyWith({
    bool? isTracking,
    String? activeShipmentId,
    double? currentLat,
    double? currentLng,
    double? destinationLat,
    double? destinationLng,
    String? error,
    DriverLocation? currentLocation,
    bool? isLoading,
    String? estimatedArrival,
  }) {
    return DriverTrackingState(
      isTracking: isTracking ?? this.isTracking,
      activeShipmentId: activeShipmentId ?? this.activeShipmentId,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
      error: error ?? this.error,
      currentLocation: currentLocation ?? this.currentLocation,
      isLoading: isLoading ?? this.isLoading,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DriverTrackingState &&
        other.isTracking == isTracking &&
        other.activeShipmentId == activeShipmentId &&
        other.currentLat == currentLat &&
        other.currentLng == currentLng &&
        other.error == error &&
        other.currentLocation == currentLocation &&
        other.isLoading == isLoading &&
        other.estimatedArrival == estimatedArrival;
  }

  @override
  int get hashCode {
    return Object.hash(
      isTracking,
      activeShipmentId,
      currentLat,
      currentLng,
      error,
      currentLocation,
      isLoading,
      estimatedArrival,
    );
  }
}
