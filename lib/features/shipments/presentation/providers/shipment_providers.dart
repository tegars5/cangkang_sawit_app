import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/models.dart';
import '../../domain/repositories/shipment_repository.dart';
import '../../domain/usecases/get_shipments.dart';
import '../../domain/usecases/assign_driver.dart';
import '../../domain/usecases/update_shipment_status.dart';
import '../../data/datasources/shipment_remote_datasource.dart';
import '../../data/repositories/shipment_repository_impl.dart';

/// Data Source Provider
final shipmentRemoteDataSourceProvider = Provider<ShipmentRemoteDataSource>((
  ref,
) {
  return ShipmentRemoteDataSource(client: Supabase.instance.client);
});

/// Repository Provider
final shipmentRepositoryProvider = Provider<ShipmentRepository>((ref) {
  final dataSource = ref.read(shipmentRemoteDataSourceProvider);
  return ShipmentRepositoryImpl(remoteDataSource: dataSource);
});

/// Use Cases Providers
final getShipmentsUseCaseProvider = Provider<GetShipments>((ref) {
  final repository = ref.read(shipmentRepositoryProvider);
  return GetShipments(repository);
});

final assignDriverUseCaseProvider = Provider<AssignDriver>((ref) {
  final repository = ref.read(shipmentRepositoryProvider);
  return AssignDriver(repository);
});

final updateShipmentStatusUseCaseProvider = Provider<UpdateShipmentStatus>((
  ref,
) {
  final repository = ref.read(shipmentRepositoryProvider);
  return UpdateShipmentStatus(repository);
});

/// State Providers

/// Get shipments with filtering
final shipmentsProvider = FutureProvider.autoDispose
    .family<List<Shipment>, GetShipmentsParams>((ref, params) async {
      final useCase = ref.read(getShipmentsUseCaseProvider);
      final result = await useCase.call(params);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (shipments) => shipments,
      );
    });

/// State notifier for shipment operations
class ShipmentNotifier extends StateNotifier<AsyncValue<Shipment?>> {
  final AssignDriver _assignDriver;
  final UpdateShipmentStatus _updateStatus;

  ShipmentNotifier({
    required AssignDriver assignDriver,
    required UpdateShipmentStatus updateStatus,
  }) : _assignDriver = assignDriver,
       _updateStatus = updateStatus,
       super(const AsyncValue.data(null));

  /// Assign driver to shipment
  Future<void> assignDriver({
    required String shipmentId,
    required String driverId,
  }) async {
    state = const AsyncValue.loading();

    final result = await _assignDriver.call(
      AssignDriverParams(shipmentId: shipmentId, driverId: driverId),
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (shipment) => AsyncValue.data(shipment),
    );
  }

  /// Update shipment status
  Future<void> updateStatus({
    required String shipmentId,
    required String newStatus,
  }) async {
    state = const AsyncValue.loading();

    final result = await _updateStatus.call(
      UpdateShipmentStatusParams(shipmentId: shipmentId, newStatus: newStatus),
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (shipment) => AsyncValue.data(shipment),
    );
  }

  /// Reset state
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Shipment notifier provider
final shipmentNotifierProvider =
    StateNotifierProvider<ShipmentNotifier, AsyncValue<Shipment?>>((ref) {
      return ShipmentNotifier(
        assignDriver: ref.read(assignDriverUseCaseProvider),
        updateStatus: ref.read(updateShipmentStatusUseCaseProvider),
      );
    });
