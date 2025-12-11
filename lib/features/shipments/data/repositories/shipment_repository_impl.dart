import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/models/models.dart';
import '../../domain/repositories/shipment_repository.dart';
import '../datasources/shipment_remote_datasource.dart';

/// Implementation of ShipmentRepository
class ShipmentRepositoryImpl implements ShipmentRepository {
  final ShipmentRemoteDataSource _remoteDataSource;

  ShipmentRepositoryImpl({required ShipmentRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<dartz.Either<Failure, List<Shipment>>> getShipments({
    String? status,
    String? driverId,
  }) async {
    try {
      final shipments = await _remoteDataSource.getShipments(
        status: status,
        driverId: driverId,
      );
      return dartz.Right(shipments);
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, Shipment>> getShipmentById(
    String shipmentId,
  ) async {
    try {
      final shipment = await _remoteDataSource.getShipmentById(shipmentId);
      return dartz.Right(shipment);
    } on NotFoundException catch (e) {
      return dartz.Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, Shipment>> assignDriver({
    required String shipmentId,
    required String driverId,
  }) async {
    try {
      final shipment = await _remoteDataSource.assignDriver(
        shipmentId: shipmentId,
        driverId: driverId,
      );
      return dartz.Right(shipment);
    } on NotFoundException catch (e) {
      return dartz.Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, Shipment>> updateShipmentStatus({
    required String shipmentId,
    required String newStatus,
  }) async {
    try {
      final shipment = await _remoteDataSource.updateShipmentStatus(
        shipmentId: shipmentId,
        newStatus: newStatus,
      );
      return dartz.Right(shipment);
    } on NotFoundException catch (e) {
      return dartz.Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, void>> addTimelineEvent({
    required String shipmentId,
    required ShipmentTimeline event,
  }) async {
    try {
      await _remoteDataSource.addTimelineEvent(
        shipmentId: shipmentId,
        event: event,
      );
      return const dartz.Right(null);
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
