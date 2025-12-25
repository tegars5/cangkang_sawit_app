import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/driver_location.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../datasources/tracking_remote_datasource.dart';
import '../models/driver_location_model.dart';

/// Implementation of TrackingRepository
class TrackingRepositoryImpl implements TrackingRepository {
  final TrackingRemoteDataSource remoteDataSource;

  TrackingRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, DriverLocation>> subscribeToDriverLocation(
    String shipmentId,
  ) async* {
    try {
      final locationStream = remoteDataSource.subscribeToDriverLocation(
        shipmentId,
      );

      await for (final locationModel in locationStream) {
        yield Right(locationModel.toDomain());
      }
    } on ServerException catch (e) {
      yield Left(ServerFailure(e.message));
    } on NotFoundException catch (e) {
      yield Left(NotFoundFailure(e.message));
    } catch (e) {
      yield Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, DriverLocation>> getCurrentLocation(
    String driverId,
  ) async {
    try {
      final locationModel = await remoteDataSource.getCurrentLocation(driverId);
      return Right(locationModel.toDomain());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DriverLocation>>> getLocationHistory(
    String shipmentId, {
    int limit = 100,
  }) async {
    try {
      final locationModels = await remoteDataSource.getLocationHistory(
        shipmentId,
        limit: limit,
      );
      return Right(locationModels.map((model) => model.toDomain()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, DriverLocation>> updateDriverLocation(
    DriverLocation location,
  ) async {
    try {
      final locationModel = DriverLocationModel.fromDomain(location);
      final updatedModel = await remoteDataSource.updateDriverLocation(
        locationModel,
      );
      return Right(updatedModel.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, DriverLocation>>>
  getMultipleDriverLocations(List<String> driverIds) async {
    try {
      final locationModels = await remoteDataSource.getMultipleDriverLocations(
        driverIds,
      );
      final locations = locationModels.map(
        (key, model) => MapEntry(key, model.toDomain()),
      );
      return Right(locations);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> stopTracking(String shipmentId) async {
    try {
      await remoteDataSource.stopTracking(shipmentId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
