import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/driver_navigation_state.dart';
import '../../../shared/models/models.dart';
import '../../../shared/repositories/tracking_repository.dart';
import '../../../core/services/location_tracking_service.dart';

/// Controller for driver navigation
class DriverNavigationController extends Notifier<DriverNavigationState> {
  final _trackingRepository = TrackingRepository();
  final _locationService = LocationTrackingService();
  StreamSubscription<Position>? _positionSubscription;

  @override
  DriverNavigationState build() {
    // Cleanup when disposed
    ref.onDispose(() {
      _positionSubscription?.cancel();
      _locationService.stopTracking();
    });

    // Return initial empty state
    return DriverNavigationState(
      shipment: Shipment(
        id: '',
        orderId: '',
        driverId: '',
        status: 'pending',
        createdAt: DateTime.now(),
        deliveryNoteNumber: '',
      ),
      destination: const LatLng(0, 0),
      currentStatus: 'pending',
    );
  }

  /// Initialize navigation with shipment data
  Future<void> initialize(Shipment shipment) async {
    state = state.copyWith(
      shipment: shipment,
      currentStatus: shipment.status,
      destination: LatLng(
        shipment.destinationLat ?? 0,
        shipment.destinationLng ?? 0,
      ),
      isLoading: true,
    );

    // Get current location
    final position = await _locationService.getCurrentPosition();
    if (position != null) {
      state = state.copyWith(currentLocation: position, isLoading: false);

      // Calculate initial distance and ETA
      _calculateDistanceAndETA();
    } else {
      state = state.copyWith(
        error: 'Tidak dapat mengakses lokasi GPS',
        isLoading: false,
      );
    }
  }

  /// Start navigation and tracking
  Future<void> startNavigation() async {
    if (state.shipment.id.isEmpty) return;

    state = state.copyWith(isLoading: true);

    try {
      // Start location tracking service
      final success = await _locationService.startTracking(state.shipment.id);
      if (!success) {
        state = state.copyWith(
          error: 'Gagal memulai tracking lokasi',
          isLoading: false,
        );
        return;
      }

      // Get current user ID
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(
          error: 'User tidak terautentikasi',
          isLoading: false,
        );
        return;
      }

      // Update shipment status to in_transit
      await _trackingRepository.updateShipmentStatus(
        shipmentId: state.shipment.id,
        status: 'in_transit',
      );

      // Add timeline update
      await _trackingRepository.addTimelineUpdate(
        shipmentId: state.shipment.id,
        status: 'in_transit',
        message: 'Driver memulai pengiriman',
      );

      // Listen to position stream for real-time updates
      _positionSubscription = _locationService.getPositionStream().listen((
        position,
      ) {
        state = state.copyWith(currentLocation: position);
        _calculateDistanceAndETA();
      });

      state = state.copyWith(
        isTracking: true,
        currentStatus: 'in_transit',
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: 'Error: $e', isLoading: false);
    }
  }

  /// Update status to arrived at pickup
  Future<void> markArrivedAtPickup() async {
    await _updateStatus('arrived_pickup', 'Driver sampai di lokasi pickup');
  }

  /// Update status to picked up
  Future<void> markPickedUp() async {
    await _updateStatus('picked_up', 'Barang sudah diambil');
  }

  /// Update status to arrived at destination
  Future<void> markArrivedAtDestination() async {
    await _updateStatus('arrived_destination', 'Driver sampai di tujuan');
  }

  /// Complete delivery
  Future<void> completeDelivery() async {
    state = state.copyWith(isLoading: true);

    try {
      // Update shipment status
      await _trackingRepository.updateShipmentStatus(
        shipmentId: state.shipment.id,
        status: 'completed',
      );

      // Add timeline update
      await _trackingRepository.addTimelineUpdate(
        shipmentId: state.shipment.id,
        status: 'completed',
        message: 'Pengiriman selesai',
      );

      // Stop tracking
      _locationService.stopTracking();
      _positionSubscription?.cancel();

      state = state.copyWith(
        currentStatus: 'completed',
        isTracking: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: 'Error: $e', isLoading: false);
    }
  }

  /// Update status helper
  Future<void> _updateStatus(String status, String message) async {
    state = state.copyWith(isLoading: true);

    try {
      await _trackingRepository.updateShipmentStatus(
        shipmentId: state.shipment.id,
        status: status,
      );

      await _trackingRepository.addTimelineUpdate(
        shipmentId: state.shipment.id,
        status: status,
        message: message,
      );

      state = state.copyWith(currentStatus: status, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: 'Error: $e', isLoading: false);
    }
  }

  /// Calculate distance and ETA
  void _calculateDistanceAndETA() {
    if (state.currentLocation == null) return;

    final distance = Geolocator.distanceBetween(
      state.currentLocation!.latitude,
      state.currentLocation!.longitude,
      state.destination.latitude,
      state.destination.longitude,
    );

    // Calculate ETA based on average speed (40 km/h)
    final averageSpeedKmh = 40.0;
    final distanceKm = distance / 1000;
    final hoursNeeded = distanceKm / averageSpeedKmh;
    final eta = Duration(minutes: (hoursNeeded * 60).round());

    state = state.copyWith(distanceInMeters: distance, eta: eta);
  }

  /// Refresh current location
  Future<void> refreshLocation() async {
    final position = await _locationService.getCurrentPosition();
    if (position != null) {
      state = state.copyWith(currentLocation: position);
      _calculateDistanceAndETA();
    }
  }
}

/// Provider for driver navigation controller
final driverNavigationControllerProvider =
    NotifierProvider<DriverNavigationController, DriverNavigationState>(
      () => DriverNavigationController(),
    );
