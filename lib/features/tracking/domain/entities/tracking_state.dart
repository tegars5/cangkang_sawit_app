// Import DriverLocation entity
import 'driver_location.dart';

/// Domain entity representing the overall tracking state
class TrackingState {
  final String shipmentId;
  final String driverId;
  final String driverName;
  final String? driverPhone;
  final DriverLocation? currentLocation;
  final List<DriverLocation> locationHistory;
  final bool isTracking;
  final DateTime? startTime;
  final DateTime? lastUpdateTime;
  final double? totalDistance; // in meters
  final double? estimatedTimeArrival; // in minutes

  const TrackingState({
    required this.shipmentId,
    required this.driverId,
    required this.driverName,
    this.driverPhone,
    this.currentLocation,
    this.locationHistory = const [],
    this.isTracking = false,
    this.startTime,
    this.lastUpdateTime,
    this.totalDistance,
    this.estimatedTimeArrival,
  });

  // Business logic methods

  /// Check if tracking is active and receiving updates
  bool isActive() {
    if (!isTracking) return false;
    if (currentLocation == null) return false;
    return currentLocation!.isRecent();
  }

  /// Check if driver has moved significantly
  bool hasSignificantMovement() {
    if (locationHistory.length < 2) return false;

    final lastLocation = locationHistory.last;
    final previousLocation = locationHistory[locationHistory.length - 2];

    final distance = lastLocation.distanceTo(previousLocation);
    return distance > 10; // More than 10 meters
  }

  /// Get average speed from history (km/h)
  double getAverageSpeed() {
    if (locationHistory.isEmpty) return 0.0;

    final locationsWithSpeed = locationHistory
        .where((loc) => loc.speed != null)
        .toList();

    if (locationsWithSpeed.isEmpty) return 0.0;

    final totalSpeed = locationsWithSpeed.fold<double>(
      0.0,
      (sum, loc) => sum + loc.speed!,
    );

    return (totalSpeed / locationsWithSpeed.length) * 3.6; // Convert to km/h
  }

  /// Get tracking duration in minutes
  int getTrackingDuration() {
    if (startTime == null) return 0;
    final now = lastUpdateTime ?? DateTime.now();
    return now.difference(startTime!).inMinutes;
  }

  /// Get formatted total distance
  String getFormattedTotalDistance() {
    if (totalDistance == null) return 'N/A';

    if (totalDistance! < 1000) {
      return '${totalDistance!.toStringAsFixed(0)} m';
    } else {
      final km = totalDistance! / 1000;
      return '${km.toStringAsFixed(2)} km';
    }
  }

  /// Get formatted ETA
  String getFormattedETA() {
    if (estimatedTimeArrival == null) return 'N/A';

    if (estimatedTimeArrival! < 60) {
      return '${estimatedTimeArrival!.toStringAsFixed(0)} menit';
    } else {
      final hours = estimatedTimeArrival! / 60;
      return '${hours.toStringAsFixed(1)} jam';
    }
  }

  // Copy with method
  TrackingState copyWith({
    String? shipmentId,
    String? driverId,
    String? driverName,
    String? driverPhone,
    DriverLocation? currentLocation,
    List<DriverLocation>? locationHistory,
    bool? isTracking,
    DateTime? startTime,
    DateTime? lastUpdateTime,
    double? totalDistance,
    double? estimatedTimeArrival,
  }) {
    return TrackingState(
      shipmentId: shipmentId ?? this.shipmentId,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      currentLocation: currentLocation ?? this.currentLocation,
      locationHistory: locationHistory ?? this.locationHistory,
      isTracking: isTracking ?? this.isTracking,
      startTime: startTime ?? this.startTime,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      totalDistance: totalDistance ?? this.totalDistance,
      estimatedTimeArrival: estimatedTimeArrival ?? this.estimatedTimeArrival,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrackingState &&
        other.shipmentId == shipmentId &&
        other.driverId == driverId;
  }

  @override
  int get hashCode => Object.hash(shipmentId, driverId);
}
