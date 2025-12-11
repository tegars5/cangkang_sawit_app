import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../shared/models/models.dart';

/// Immutable state for driver navigation
class DriverNavigationState {
  final Shipment shipment;
  final Position? currentLocation;
  final LatLng destination;
  final List<LatLng> routePoints;
  final String currentStatus;
  final double? distanceInMeters;
  final Duration? eta;
  final bool isTracking;
  final bool isLoading;
  final String? error;

  const DriverNavigationState({
    required this.shipment,
    this.currentLocation,
    required this.destination,
    this.routePoints = const [],
    required this.currentStatus,
    this.distanceInMeters,
    this.eta,
    this.isTracking = false,
    this.isLoading = false,
    this.error,
  });

  DriverNavigationState copyWith({
    Shipment? shipment,
    Position? currentLocation,
    LatLng? destination,
    List<LatLng>? routePoints,
    String? currentStatus,
    double? distanceInMeters,
    Duration? eta,
    bool? isTracking,
    bool? isLoading,
    String? error,
  }) {
    return DriverNavigationState(
      shipment: shipment ?? this.shipment,
      currentLocation: currentLocation ?? this.currentLocation,
      destination: destination ?? this.destination,
      routePoints: routePoints ?? this.routePoints,
      currentStatus: currentStatus ?? this.currentStatus,
      distanceInMeters: distanceInMeters ?? this.distanceInMeters,
      eta: eta ?? this.eta,
      isTracking: isTracking ?? this.isTracking,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Helper getters
  LatLng? get currentLatLng => currentLocation != null
      ? LatLng(currentLocation!.latitude, currentLocation!.longitude)
      : null;

  String get formattedDistance {
    if (distanceInMeters == null) return 'N/A';
    if (distanceInMeters! < 1000) {
      return '${distanceInMeters!.toStringAsFixed(0)} m';
    }
    return '${(distanceInMeters! / 1000).toStringAsFixed(1)} km';
  }

  String get formattedETA {
    if (eta == null) return 'N/A';
    final hours = eta!.inHours;
    final minutes = eta!.inMinutes % 60;
    if (hours > 0) {
      return '$hours jam $minutes menit';
    }
    return '$minutes menit';
  }

  String get statusDisplayText {
    switch (currentStatus) {
      case 'assigned':
        return 'Tugas Diterima';
      case 'in_transit':
        return 'Dalam Perjalanan';
      case 'arrived_pickup':
        return 'Sampai di Lokasi Pickup';
      case 'picked_up':
        return 'Barang Sudah Diambil';
      case 'arrived_destination':
        return 'Sampai di Tujuan';
      case 'completed':
        return 'Pengiriman Selesai';
      default:
        return 'Menunggu';
    }
  }

  bool get canStartTask => currentStatus == 'assigned';
  bool get canMarkArrived => currentStatus == 'in_transit';
  bool get canMarkPickedUp => currentStatus == 'arrived_pickup';
  bool get canMarkDelivered =>
      currentStatus == 'picked_up' || currentStatus == 'arrived_destination';
}
