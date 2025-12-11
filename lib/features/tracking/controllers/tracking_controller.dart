import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tracking_state.dart';
import '../../../shared/repositories/tracking_repository.dart';

/// Controller for managing tracking state with real-time subscriptions
class TrackingController extends Notifier<TrackingState> {
  final TrackingRepository _repository = TrackingRepository();
  StreamSubscription? _timelineSubscription;
  StreamSubscription? _locationSubscription;

  @override
  TrackingState build() => const TrackingState();

  /// Start tracking a shipment by ID
  Future<void> startTracking(String shipmentId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Fetch initial shipment details
      final shipment = await _repository.getShipmentDetails(shipmentId);

      if (shipment == null) {
        state = state.copyWith(isLoading: false, error: 'Shipment not found');
        return;
      }

      // Fetch initial timeline
      final timeline = await _repository.getTimelineHistory(shipmentId);

      // Fetch initial driver location
      final location = await _repository.getLatestDriverLocation(shipmentId);

      state = state.copyWith(
        shipment: shipment,
        timeline: timeline,
        driverLocation: location,
        isLoading: false,
      );

      // Subscribe to real-time updates
      _subscribeToUpdates(shipmentId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load tracking data: $e',
      );
    }
  }

  /// Subscribe to real-time timeline and location updates
  void _subscribeToUpdates(String shipmentId) {
    // Subscribe to timeline updates
    _timelineSubscription = _repository
        .watchTimelineUpdates(shipmentId)
        .listen(
          (timeline) {
            state = state.copyWith(timeline: timeline, isSubscribed: true);
          },
          onError: (error) {
            state = state.copyWith(error: 'Real-time update error: $error');
          },
        );

    // Subscribe to driver location updates
    _locationSubscription = _repository
        .watchDriverLocation(shipmentId)
        .listen(
          (location) {
            state = state.copyWith(
              driverLocation: location,
              isSubscribed: true,
            );
          },
          onError: (error) {
            state = state.copyWith(error: 'Location update error: $error');
          },
        );
  }

  /// Stop tracking and cleanup subscriptions
  void stopTracking() {
    _timelineSubscription?.cancel();
    _locationSubscription?.cancel();
    _timelineSubscription = null;
    _locationSubscription = null;

    state = state.copyWith(isSubscribed: false);
  }

  /// Refresh tracking data manually
  Future<void> refresh() async {
    if (state.shipment == null) return;
    await startTracking(state.shipment!.id);
  }

  /// Cleanup subscriptions when controller is disposed
  void cleanup() {
    stopTracking();
  }
}

/// Provider for tracking controller
final trackingControllerProvider =
    NotifierProvider<TrackingController, TrackingState>(
      () => TrackingController(),
    );

/// Provider for tracking by shipment ID
final trackingByShipmentProvider = FutureProvider.family<TrackingState, String>(
  (ref, shipmentId) async {
    final controller = ref.read(trackingControllerProvider.notifier);
    await controller.startTracking(shipmentId);
    return ref.watch(trackingControllerProvider);
  },
);
