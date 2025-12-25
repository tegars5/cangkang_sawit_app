import 'package:flutter_riverpod/legacy.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../shipments/domain/entities/shipment.dart';
import '../models/driver_navigation_state.dart';

/// Driver Navigation Controller Provider
final driverNavigationControllerProvider =
    StateNotifierProvider<DriverNavigationController, DriverNavigationState>(
      (ref) => DriverNavigationController(),
    );

/// Controller for driver navigation and tracking
class DriverNavigationController extends StateNotifier<DriverNavigationState> {
  DriverNavigationController()
    : super(
        DriverNavigationState(
          shipment: Shipment.fromJson({
            'id': '',
            'order_id': '',
            'status': 'pending',
            'pickup_address': '',
            'delivery_address': '',
            'total_weight': 0.0,
            'total_quantity': 0,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          }),
          destination: const LatLng(0, 0),
          currentStatus: 'pending',
        ),
      );

  /// Initialize navigation with shipment details
  void initialize(Shipment shipment) {
    final destination = LatLng(
      shipment.deliveryLatitude ?? 0,
      shipment.deliveryLongitude ?? 0,
    );
    state = DriverNavigationState(
      shipment: shipment,
      destination: destination,
      currentStatus: shipment.status,
      isTracking: false,
    );
  }

  /// Mark arrived at pickup location
  void markArrivedAtPickup() {
    state = state.copyWith(currentStatus: 'arrived_pickup');
  }

  /// Mark picked up
  void markPickedUp() {
    state = state.copyWith(currentStatus: 'picked_up');
  }

  /// Mark arrived at destination
  void markArrivedAtDestination() {
    state = state.copyWith(currentStatus: 'arrived_destination');
  }

  /// Complete delivery
  void completeDelivery() {
    state = state.copyWith(currentStatus: 'completed', isTracking: false);
  }

  /// Start navigation to destination
  void startNavigation() {
    state = state.copyWith(isTracking: true);
  }

  /// Stop navigation
  void stopNavigation() {
    state = state.copyWith(isTracking: false);
  }

  /// Update current location
  void updateLocation(double lat, double lng) {
    // Update only if tracking is active
    if (state.isTracking) {
      // This will be implemented with actual location updates
    }
  }

  /// Update destination
  void setDestination(double lat, double lng) {
    state = state.copyWith(destination: LatLng(lat, lng));
  }

  /// Complete navigation
  void completeNavigation() {
    state = state.copyWith(isTracking: false);
  }

  /// Reset state
  void reset() {
    state = DriverNavigationState(
      shipment: Shipment(
        id: '',
        orderId: '',
        deliveryAddress: '',
        pickupAddress: '',
        status: 'pending',
        totalWeight: 0,
        totalQuantity: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      destination: const LatLng(0, 0),
      currentStatus: 'pending',
    );
  }
}
