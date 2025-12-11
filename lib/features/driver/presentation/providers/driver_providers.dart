import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/models.dart';
import '../../domain/repositories/driver_repository.dart';
import '../../domain/usecases/get_driver_tasks.dart';
import '../../data/datasources/driver_remote_datasource.dart';
import '../../data/repositories/driver_repository_impl.dart';

/// Data Source Provider
final driverRemoteDataSourceProvider = Provider<DriverRemoteDataSource>((ref) {
  return DriverRemoteDataSource(client: Supabase.instance.client);
});

/// Repository Provider
final driverRepositoryProvider = Provider<DriverRepository>((ref) {
  final dataSource = ref.read(driverRemoteDataSourceProvider);
  return DriverRepositoryImpl(remoteDataSource: dataSource);
});

/// Use Cases Providers
final getDriverTasksUseCaseProvider = Provider<GetDriverTasks>((ref) {
  final repository = ref.read(driverRepositoryProvider);
  return GetDriverTasks(repository);
});

/// Driver tasks provider
final driverTasksProvider = FutureProvider.autoDispose
    .family<List<Shipment>, GetDriverTasksParams>((ref, params) async {
      final useCase = ref.read(getDriverTasksUseCaseProvider);
      final result = await useCase.call(params);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (tasks) => tasks,
      );
    });

/// Driver notifier for task operations
class DriverNotifier extends StateNotifier<AsyncValue<Shipment?>> {
  final DriverRepository _repository;

  DriverNotifier({required DriverRepository repository})
    : _repository = repository,
      super(const AsyncValue.data(null));

  Future<void> acceptTask(String shipmentId) async {
    state = const AsyncValue.loading();

    final result = await _repository.acceptTask(shipmentId: shipmentId);

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (shipment) => AsyncValue.data(shipment),
    );
  }

  Future<void> startDelivery(String shipmentId) async {
    state = const AsyncValue.loading();

    final result = await _repository.startDelivery(shipmentId: shipmentId);

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (shipment) => AsyncValue.data(shipment),
    );
  }

  Future<void> completeDelivery(String shipmentId, {String? notes}) async {
    state = const AsyncValue.loading();

    final result = await _repository.completeDelivery(
      shipmentId: shipmentId,
      notes: notes,
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (shipment) => AsyncValue.data(shipment),
    );
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final driverNotifierProvider =
    StateNotifierProvider<DriverNotifier, AsyncValue<Shipment?>>((ref) {
      return DriverNotifier(repository: ref.read(driverRepositoryProvider));
    });
