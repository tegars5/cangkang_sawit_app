import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/models/models.dart';
import '../../domain/repositories/driver_repository.dart';
import '../datasources/driver_remote_datasource.dart';

/// Implementation of DriverRepository
class DriverRepositoryImpl implements DriverRepository {
  final DriverRemoteDataSource _remoteDataSource;

  DriverRepositoryImpl({required DriverRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<dartz.Either<Failure, List<Shipment>>> getDriverTasks({
    required String driverId,
    String? status,
  }) async {
    try {
      final tasks = await _remoteDataSource.getDriverTasks(
        driverId: driverId,
        status: status,
      );
      return dartz.Right(tasks);
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, Shipment>> acceptTask({
    required String shipmentId,
  }) async {
    try {
      final shipment = await _remoteDataSource.acceptTask(
        shipmentId: shipmentId,
      );
      return dartz.Right(shipment);
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, Shipment>> startDelivery({
    required String shipmentId,
  }) async {
    try {
      final shipment = await _remoteDataSource.startDelivery(
        shipmentId: shipmentId,
      );
      return dartz.Right(shipment);
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, Shipment>> completeDelivery({
    required String shipmentId,
    String? notes,
  }) async {
    try {
      final shipment = await _remoteDataSource.completeDelivery(
        shipmentId: shipmentId,
        notes: notes,
      );
      return dartz.Right(shipment);
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, void>> updateLocation({
    required String driverId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _remoteDataSource.updateLocation(
        driverId: driverId,
        latitude: latitude,
        longitude: longitude,
      );
      return const dartz.Right(null);
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
