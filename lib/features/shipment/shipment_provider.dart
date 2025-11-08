import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:developer';

import '../../shared/models/shipment.dart';
import '../../core/repositories/shipment_repository.dart';

// Providers for shipment management

// Current driver shipments
final driverShipmentsProvider =
    StateNotifierProvider<DriverShipmentsNotifier, AsyncValue<List<Shipment>>>((
      ref,
    ) {
      return DriverShipmentsNotifier();
    });

// Active shipments (assigned + picked_up)
final activeShipmentsProvider = Provider<List<Shipment>>((ref) {
  final shipments = ref.watch(driverShipmentsProvider);
  return shipments.maybeWhen(
    data: (data) => data
        .where((s) => s.status == 'assigned' || s.status == 'picked_up')
        .toList(),
    orElse: () => [],
  );
});

// Shipment statistics
final shipmentStatsProvider =
    StateNotifierProvider<ShipmentStatsNotifier, AsyncValue<Map<String, int>>>((
      ref,
    ) {
      return ShipmentStatsNotifier();
    });

class DriverShipmentsNotifier
    extends StateNotifier<AsyncValue<List<Shipment>>> {
  DriverShipmentsNotifier() : super(const AsyncValue.loading()) {
    _initialize();
  }

  StreamSubscription<List<Shipment>>? _subscription;
  String? _currentDriverId;

  void _initialize() {
    // TODO: Get actual driver ID from authentication
    _currentDriverId = 'driver_001';
    _setupRealtimeSubscription();
    loadShipments();
  }

  void _setupRealtimeSubscription() {
    _subscription = ShipmentRepository.shipmentsStream.listen(
      (allShipments) {
        if (_currentDriverId != null) {
          final driverShipments = allShipments
              .where((s) => s.driverId == _currentDriverId)
              .toList();
          state = AsyncValue.data(driverShipments);
          log('Updated driver shipments: ${driverShipments.length}');
        }
      },
      onError: (error, stackTrace) {
        log(
          'Error in shipments stream: $error',
          error: error,
          stackTrace: stackTrace,
        );
        state = AsyncValue.error(error, stackTrace);
      },
    );
  }

  Future<void> loadShipments() async {
    if (_currentDriverId == null) return;

    try {
      state = const AsyncValue.loading();
      final shipments = await ShipmentRepository.getDriverShipments(
        _currentDriverId!,
      );
      state = AsyncValue.data(shipments);
    } catch (e, stackTrace) {
      log(
        'Error loading driver shipments: $e',
        error: e,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> startShipment(String shipmentId) async {
    try {
      await ShipmentRepository.startShipment(shipmentId);
      log('Started shipment: $shipmentId');
      // State will be updated via real-time subscription
    } catch (e, stackTrace) {
      log('Error starting shipment: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> completeShipment(
    String shipmentId,
    String deliveryPhotoUrl,
  ) async {
    try {
      await ShipmentRepository.completeShipment(shipmentId, deliveryPhotoUrl);
      log('Completed shipment: $shipmentId');
      // State will be updated via real-time subscription
    } catch (e, stackTrace) {
      log('Error completing shipment: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> cancelShipment(String shipmentId, {String? reason}) async {
    try {
      await ShipmentRepository.cancelShipment(shipmentId, reason: reason);
      log('Cancelled shipment: $shipmentId');
      // State will be updated via real-time subscription
    } catch (e, stackTrace) {
      log('Error cancelling shipment: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  void setDriverId(String driverId) {
    _currentDriverId = driverId;
    loadShipments();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class ShipmentStatsNotifier
    extends StateNotifier<AsyncValue<Map<String, int>>> {
  ShipmentStatsNotifier() : super(const AsyncValue.loading()) {
    loadStats();
  }

  String? _currentDriverId = 'driver_001'; // TODO: Get from auth

  Future<void> loadStats() async {
    if (_currentDriverId == null) return;

    try {
      state = const AsyncValue.loading();
      final stats = await ShipmentRepository.getShipmentStatistics(
        driverId: _currentDriverId,
      );
      state = AsyncValue.data(stats);
    } catch (e, stackTrace) {
      log('Error loading shipment stats: $e', error: e, stackTrace: stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() => loadStats();

  void setDriverId(String driverId) {
    _currentDriverId = driverId;
    loadStats();
  }
}

// Individual shipment provider
final shipmentProvider =
    StateNotifierProvider.family<
      ShipmentNotifier,
      AsyncValue<Shipment?>,
      String
    >((ref, shipmentId) {
      return ShipmentNotifier(shipmentId);
    });

class ShipmentNotifier extends StateNotifier<AsyncValue<Shipment?>> {
  ShipmentNotifier(this.shipmentId) : super(const AsyncValue.loading()) {
    _loadShipment();
    _setupSubscription();
  }

  final String shipmentId;
  StreamSubscription<Shipment>? _subscription;

  void _setupSubscription() {
    _subscription = ShipmentRepository.shipmentUpdatesStream
        .where((shipment) => shipment.id == shipmentId)
        .listen(
          (shipment) {
            state = AsyncValue.data(shipment);
          },
          onError: (error, stackTrace) {
            state = AsyncValue.error(error, stackTrace);
          },
        );
  }

  Future<void> _loadShipment() async {
    try {
      state = const AsyncValue.loading();
      final shipment = await ShipmentRepository.getShipmentById(shipmentId);
      state = AsyncValue.data(shipment);
    } catch (e, stackTrace) {
      log('Error loading shipment: $e', error: e, stackTrace: stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() => _loadShipment();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// Photo upload provider
final photoUploadProvider =
    StateNotifierProvider<PhotoUploadNotifier, PhotoUploadState>((ref) {
      return PhotoUploadNotifier();
    });

class PhotoUploadState {
  final bool isUploading;
  final double progress;
  final List<String> uploadedUrls;
  final String? error;

  const PhotoUploadState({
    this.isUploading = false,
    this.progress = 0.0,
    this.uploadedUrls = const [],
    this.error,
  });

  PhotoUploadState copyWith({
    bool? isUploading,
    double? progress,
    List<String>? uploadedUrls,
    String? error,
  }) {
    return PhotoUploadState(
      isUploading: isUploading ?? this.isUploading,
      progress: progress ?? this.progress,
      uploadedUrls: uploadedUrls ?? this.uploadedUrls,
      error: error,
    );
  }
}

class PhotoUploadNotifier extends StateNotifier<PhotoUploadState> {
  PhotoUploadNotifier() : super(const PhotoUploadState());

  void startUpload() {
    state = state.copyWith(isUploading: true, progress: 0.0, error: null);
  }

  void updateProgress(double progress) {
    state = state.copyWith(progress: progress);
  }

  void uploadSuccess(List<String> urls) {
    state = state.copyWith(
      isUploading: false,
      uploadedUrls: urls,
      progress: 1.0,
    );
  }

  void uploadError(String error) {
    state = state.copyWith(isUploading: false, error: error, progress: 0.0);
  }

  void reset() {
    state = const PhotoUploadState();
  }
}
