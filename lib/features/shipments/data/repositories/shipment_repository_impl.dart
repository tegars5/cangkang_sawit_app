import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/shipment.dart';
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
    String? orderId,
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
    required String driverName,
    String? vehiclePlate,
  }) async {
    try {
      final shipment = await _remoteDataSource.assignDriver(
        shipmentId: shipmentId,
        driverId: driverId,
        driverName: driverName,
        vehiclePlate: vehiclePlate,
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
    required String status,
    DateTime? actualPickupDate,
    DateTime? actualDeliveryDate,
    String? notes,
  }) async {
    try {
      final shipment = await _remoteDataSource.updateShipmentStatus(
        shipmentId: shipmentId,
        newStatus: status,
        actualPickupDate: actualPickupDate,
        actualDeliveryDate: actualDeliveryDate,
        notes: notes,
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
  Future<dartz.Either<Failure, Shipment>> createShipment({
    required String orderId,
    required String pickupAddress,
    required String deliveryAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    double? deliveryLatitude,
    double? deliveryLongitude,
    DateTime? scheduledPickupDate,
    DateTime? estimatedDeliveryDate,
    required double totalWeight,
    required int totalQuantity,
    String? notes,
  }) async {
    try {
      final shipment = await _remoteDataSource.createShipment(
        orderId: orderId,
        pickupAddress: pickupAddress,
        deliveryAddress: deliveryAddress,
        pickupLatitude: pickupLatitude,
        pickupLongitude: pickupLongitude,
        deliveryLatitude: deliveryLatitude,
        deliveryLongitude: deliveryLongitude,
        scheduledPickupDate: scheduledPickupDate,
        estimatedDeliveryDate: estimatedDeliveryDate,
        totalWeight: totalWeight,
        totalQuantity: totalQuantity,
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
  Future<dartz.Either<Failure, Shipment>> markAsPickedUp({
    required String shipmentId,
    DateTime? actualPickupDate,
  }) async {
    try {
      final shipment = await _remoteDataSource.markAsPickedUp(
        shipmentId: shipmentId,
        actualPickupDate: actualPickupDate,
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
  Future<dartz.Either<Failure, Shipment>> markAsDelivered({
    required String shipmentId,
    DateTime? actualDeliveryDate,
    String? proofOfDeliveryUrl,
    String? recipientName,
    String? recipientSignature,
  }) async {
    try {
      final shipment = await _remoteDataSource.markAsDelivered(
        shipmentId: shipmentId,
        actualDeliveryDate: actualDeliveryDate,
        proofOfDeliveryUrl: proofOfDeliveryUrl,
        recipientName: recipientName,
        recipientSignature: recipientSignature,
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
  Future<dartz.Either<Failure, Shipment>> cancelShipment({
    required String shipmentId,
    String? reason,
  }) async {
    try {
      final shipment = await _remoteDataSource.cancelShipment(
        shipmentId: shipmentId,
        reason: reason,
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
  Future<dartz.Either<Failure, Shipment>> updateShipment({
    required String shipmentId,
    String? pickupAddress,
    String? deliveryAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    double? deliveryLatitude,
    double? deliveryLongitude,
    DateTime? scheduledPickupDate,
    DateTime? estimatedDeliveryDate,
    String? notes,
  }) async {
    try {
      final shipment = await _remoteDataSource.updateShipment(
        shipmentId: shipmentId,
        pickupAddress: pickupAddress,
        deliveryAddress: deliveryAddress,
        pickupLatitude: pickupLatitude,
        pickupLongitude: pickupLongitude,
        deliveryLatitude: deliveryLatitude,
        deliveryLongitude: deliveryLongitude,
        scheduledPickupDate: scheduledPickupDate,
        estimatedDeliveryDate: estimatedDeliveryDate,
        notes: notes,
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
  Future<dartz.Either<Failure, List<Shipment>>> getShipmentsByDriver(
    String driverId,
  ) async {
    try {
      final shipments = await _remoteDataSource.getShipmentsByDriver(driverId);
      return dartz.Right(shipments);
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, List<Shipment>>> getShipmentsByOrder(
    String orderId,
  ) async {
    try {
      final shipments = await _remoteDataSource.getShipmentsByOrder(orderId);
      return dartz.Right(shipments);
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, List<Shipment>>> getActiveShipments() async {
    try {
      final shipments = await _remoteDataSource.getActiveShipments();
      return dartz.Right(shipments);
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, List<Shipment>>>
  getShipmentsRequiringAction() async {
    try {
      final shipments = await _remoteDataSource.getShipmentsRequiringAction();
      return dartz.Right(shipments);
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
