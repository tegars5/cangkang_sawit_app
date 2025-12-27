import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../shipments/domain/entities/shipment.dart';
import '../models/driver_navigation_state.dart';

/// Driver navigation controller
class DriverNavigationController extends Notifier<DriverNavigationState> {
  @override
  DriverNavigationState build() {
    return DriverNavigationState(
      shipment: _createEmptyShipment(),
      destination: const LatLng(0, 0),
      currentStatus: 'pending',
    );
  }

  static Shipment _createEmptyShipment() => Shipment(
    id: '',
    orderId: '',
    deliveryAddress: '',
    pickupAddress: '',
    status: 'pending',
    totalWeight: 0,
    totalQuantity: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  void initialize(Shipment shipment) {
    if (shipment.id.isEmpty || shipment.deliveryLatitude == null) {
      throw ArgumentError('Invalid shipment data');
    }

    state = DriverNavigationState(
      shipment: shipment,
      destination: LatLng(
        shipment.deliveryLatitude!,
        shipment.deliveryLongitude!,
      ),
      currentStatus: shipment.status,
    );
  }

  void markArrivedAtPickup() =>
      state = state.copyWith(currentStatus: 'arrived_pickup');

  void markPickedUp() =>
      state = state.copyWith(currentStatus: 'picked_up', isTracking: true);

  void markArrivedAtDestination() =>
      state = state.copyWith(currentStatus: 'arrived_destination');

  void completeDelivery() =>
      state = state.copyWith(currentStatus: 'completed', isTracking: false);

  void startNavigation() => state = state.copyWith(isTracking: true);
  void stopNavigation() => state = state.copyWith(isTracking: false);

  void updateLocation(double lat, double lng) {
    if (!state.isTracking) return;
    state = state.copyWith(currentLocation: LatLng(lat, lng));
  }

  void setDestination(double lat, double lng) =>
      state = state.copyWith(destination: LatLng(lat, lng));

  void reset() => state = DriverNavigationState(
    shipment: _createEmptyShipment(),
    destination: const LatLng(0, 0),
    currentStatus: 'pending',
  );
}

/// Provider for driver navigation controller
final driverNavigationControllerProvider =
    NotifierProvider.autoDispose<
      DriverNavigationController,
      DriverNavigationState
    >(DriverNavigationController.new);
