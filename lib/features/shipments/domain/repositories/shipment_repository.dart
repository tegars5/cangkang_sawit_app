import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/shipment.dart';

/// Repository interface for shipment operations
///
/// Defines the contract for shipment data operations.
/// Implementations should handle data source communication and error handling.
abstract class ShipmentRepository {
  /// Get all shipments with optional filtering
  ///
  /// [status] - Filter by shipment status
  /// [driverId] - Filter by assigned driver
  /// [orderId] - Filter by order ID
  Future<Either<Failure, List<Shipment>>> getShipments({
    String? status,
    String? driverId,
    String? orderId,
  });

  /// Get a single shipment by ID
  Future<Either<Failure, Shipment>> getShipmentById(String id);

  /// Create a new shipment from an order
  Future<Either<Failure, Shipment>> createShipment({
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
  });

  /// Assign a driver to a shipment
  Future<Either<Failure, Shipment>> assignDriver({
    required String shipmentId,
    required String driverId,
    required String driverName,
    String? vehiclePlate,
  });

  /// Update shipment status
  Future<Either<Failure, Shipment>> updateShipmentStatus({
    required String shipmentId,
    required String status,
    DateTime? actualPickupDate,
    DateTime? actualDeliveryDate,
    String? notes,
  });

  /// Mark shipment as picked up
  Future<Either<Failure, Shipment>> markAsPickedUp({
    required String shipmentId,
    DateTime? actualPickupDate,
  });

  /// Mark shipment as delivered
  Future<Either<Failure, Shipment>> markAsDelivered({
    required String shipmentId,
    DateTime? actualDeliveryDate,
    String? proofOfDeliveryUrl,
    String? recipientName,
    String? recipientSignature,
  });

  /// Cancel a shipment
  Future<Either<Failure, Shipment>> cancelShipment({
    required String shipmentId,
    String? reason,
  });

  /// Update shipment details
  Future<Either<Failure, Shipment>> updateShipment({
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
  });

  /// Get shipments by driver
  Future<Either<Failure, List<Shipment>>> getShipmentsByDriver(String driverId);

  /// Get shipments by order
  Future<Either<Failure, List<Shipment>>> getShipmentsByOrder(String orderId);

  /// Get active shipments (not delivered or cancelled)
  Future<Either<Failure, List<Shipment>>> getActiveShipments();

  /// Get shipments requiring action (pending, assigned without pickup)
  Future<Either<Failure, List<Shipment>>> getShipmentsRequiringAction();
}
