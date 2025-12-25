import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:state_notifier/state_notifier.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/usecases/subscribe_driver_location.dart';
import '../../domain/usecases/get_location_history.dart';
import '../../domain/usecases/get_current_location.dart';
import '../../domain/usecases/update_driver_location.dart';
import 'tracking_state.dart';

/// StateNotifier for managing tracking state
class TrackingNotifier extends StateNotifier<TrackingState> {
  final SubscribeDriverLocation subscribeDriverLocationUseCase;
  final GetLocationHistory getLocationHistoryUseCase;
  final GetCurrentLocation getCurrentLocationUseCase;
  final UpdateDriverLocation updateDriverLocationUseCase;

  StreamSubscription<dynamic>? _locationSubscription;

  TrackingNotifier({
    required this.subscribeDriverLocationUseCase,
    required this.getLocationHistoryUseCase,
    required this.getCurrentLocationUseCase,
    required this.updateDriverLocationUseCase,
  }) : super(const TrackingState());

  /// Start tracking shipment
  Future<void> startTracking(String shipmentId) async {
    state = state.copyWith(
      isLoading: true,
      isTracking: true,
      shipmentId: shipmentId,
      clearError: true,
    );

    // Load history first
    await loadLocationHistory(shipmentId);

    // Subscribe to real-time updates
    final locationStream = subscribeDriverLocationUseCase(
      SubscribeDriverLocationParams(shipmentId: shipmentId),
    );

    _locationSubscription = locationStream.listen(
      (either) {
        either.fold(
          (failure) {
            state = state.copyWith(
              isLoading: false,
              errorMessage: failure.message,
            );
          },
          (location) {
            // Calculate total distance
            double? newTotalDistance = state.totalDistance;
            if (state.currentLocation != null) {
              final distance = state.currentLocation!.distanceTo(location);
              newTotalDistance = (state.totalDistance ?? 0) + distance;
            }

            // Update state with new location
            state = state.copyWith(
              currentLocation: location,
              locationHistory: [location, ...state.locationHistory],
              totalDistance: newTotalDistance,
              isLoading: false,
              clearError: true,
            );
          },
        );
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        );
      },
    );
  }

  /// Load location history
  Future<void> loadLocationHistory(String shipmentId, {int limit = 100}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await getLocationHistoryUseCase(
      GetLocationHistoryParams(shipmentId: shipmentId, limit: limit),
    );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (locations) {
        // Calculate total distance from history
        double totalDist = 0;
        for (int i = 0; i < locations.length - 1; i++) {
          totalDist += locations[i].distanceTo(locations[i + 1]);
        }

        state = state.copyWith(
          locationHistory: locations,
          currentLocation: locations.isNotEmpty ? locations.first : null,
          totalDistance: totalDist,
          isLoading: false,
          clearError: true,
        );
      },
    );
  }

  /// Get current location
  Future<void> getCurrentLocation(String driverId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await getCurrentLocationUseCase(driverId);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (location) {
        state = state.copyWith(
          currentLocation: location,
          isLoading: false,
          clearError: true,
        );
      },
    );
  }

  /// Update driver location (for driver app)
  Future<bool> updateLocation(UpdateDriverLocationParams params) async {
    final result = await updateDriverLocationUseCase(params);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (location) {
        state = state.copyWith(currentLocation: location, clearError: true);
        return true;
      },
    );
  }

  /// Stop tracking
  Future<void> stopTracking() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;

    state = state.copyWith(
      isTracking: false,
      clearCurrentLocation: true,
      clearError: true,
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}

/// Provider for TrackingNotifier
final trackingNotifierProvider =
    StateNotifierProvider<TrackingNotifier, TrackingState>((ref) {
      return TrackingNotifier(
        subscribeDriverLocationUseCase: ref.read(
          subscribeDriverLocationUseCaseProvider,
        ),
        getLocationHistoryUseCase: ref.read(getLocationHistoryUseCaseProvider),
        getCurrentLocationUseCase: ref.read(getCurrentLocationUseCaseProvider),
        updateDriverLocationUseCase: ref.read(
          updateDriverLocationUseCaseProvider,
        ),
      );
    });
