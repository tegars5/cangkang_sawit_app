import 'package:flutter/foundation.dart';
import 'package:cangkang_sawit_app/shared/models/models.dart';

/// Immutable state for tracking screen
@immutable
class TrackingState {
  final Shipment? shipment;
  final List<ShipmentTimeline> timeline;
  final DriverLocation? driverLocation;
  final bool isLoading;
  final String? error;
  final bool isSubscribed;

  const TrackingState({
    this.shipment,
    this.timeline = const [],
    this.driverLocation,
    this.isLoading = false,
    this.error,
    this.isSubscribed = false,
  });

  TrackingState copyWith({
    Shipment? shipment,
    List<ShipmentTimeline>? timeline,
    DriverLocation? driverLocation,
    bool? isLoading,
    String? error,
    bool? isSubscribed,
  }) {
    return TrackingState(
      shipment: shipment ?? this.shipment,
      timeline: timeline ?? this.timeline,
      driverLocation: driverLocation ?? this.driverLocation,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSubscribed: isSubscribed ?? this.isSubscribed,
    );
  }

  /// Get current status from shipment
  String get currentStatus => shipment?.status ?? 'unknown';

  /// Check if shipment is in progress
  bool get isInProgress =>
      currentStatus == 'in_transit' || currentStatus == 'arrived';

  /// Check if shipment is completed
  bool get isCompleted => currentStatus == 'completed';

  /// Get driver name
  String get driverName => shipment?.driverName ?? 'Unknown Driver';

  /// Get order number
  String get orderNumber => shipment?.orderNumber ?? 'Unknown Order';

  /// Check if has driver location
  bool get hasDriverLocation => driverLocation != null;

  /// Check if driver location is recent
  bool get isDriverLocationRecent => driverLocation?.isRecent ?? false;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrackingState &&
        other.shipment == shipment &&
        other.timeline == timeline &&
        other.driverLocation == driverLocation &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.isSubscribed == isSubscribed;
  }

  @override
  int get hashCode {
    return Object.hash(
      shipment,
      timeline,
      driverLocation,
      isLoading,
      error,
      isSubscribed,
    );
  }
}
