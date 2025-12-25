import 'package:equatable/equatable.dart';
import '../../domain/entities/driver_location.dart';

/// State for tracking feature
class TrackingState extends Equatable {
  final DriverLocation? currentLocation;
  final List<DriverLocation> locationHistory;
  final bool isTracking;
  final bool isLoading;
  final String? errorMessage;
  final String? shipmentId;
  final double? totalDistance;

  const TrackingState({
    this.currentLocation,
    this.locationHistory = const [],
    this.isTracking = false,
    this.isLoading = false,
    this.errorMessage,
    this.shipmentId,
    this.totalDistance,
  });

  TrackingState copyWith({
    DriverLocation? currentLocation,
    List<DriverLocation>? locationHistory,
    bool? isTracking,
    bool? isLoading,
    String? errorMessage,
    String? shipmentId,
    double? totalDistance,
    bool clearError = false,
    bool clearCurrentLocation = false,
  }) {
    return TrackingState(
      currentLocation: clearCurrentLocation
          ? null
          : currentLocation ?? this.currentLocation,
      locationHistory: locationHistory ?? this.locationHistory,
      isTracking: isTracking ?? this.isTracking,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      shipmentId: shipmentId ?? this.shipmentId,
      totalDistance: totalDistance ?? this.totalDistance,
    );
  }

  @override
  List<Object?> get props => [
    currentLocation,
    locationHistory,
    isTracking,
    isLoading,
    errorMessage,
    shipmentId,
    totalDistance,
  ];
}
