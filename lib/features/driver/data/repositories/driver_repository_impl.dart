import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../shipments/domain/entities/shipment.dart';
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

  @override
  Future<dartz.Either<Failure, List<Shipment>>> getAssignedDeliveries({
    required String driverId,
  }) async {
    try {
      final deliveries = await _remoteDataSource.getDriverTasks(
        driverId: driverId,
        status: 'assigned',
      );
      return dartz.Right(deliveries);
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, List<Shipment>>> getTodayDeliveries({
    required String driverId,
  }) async {
    try {
      final deliveries = await _remoteDataSource.getDriverTasks(
        driverId: driverId,
      );
      // Filter today's deliveries at application level
      final today = DateTime.now();
      final todayDeliveries = deliveries.where((shipment) {
        final createdAt = shipment.createdAt;
        return createdAt.year == today.year &&
            createdAt.month == today.month &&
            createdAt.day == today.day;
      }).toList();
      return dartz.Right(todayDeliveries);
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, Shipment>> markAsPickedUp({
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
  Future<dartz.Either<Failure, Shipment>> markAsDelivered({
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
  Future<dartz.Either<Failure, Shipment>> updateDeliveryStatus({
    required String shipmentId,
    required String status,
  }) async {
    try {
      final shipment = await _remoteDataSource.updateShipmentStatus(
        shipmentId: shipmentId,
        status: status,
      );
      return dartz.Right(shipment);
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, String>> uploadProofOfDelivery({
    required String shipmentId,
    required String imagePath,
  }) async {
    try {
      // TODO: Implement actual file upload to Supabase Storage
      // For now, return the local path
      // In production, this should upload to Supabase Storage and return the URL
      return dartz.Right(imagePath);
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
