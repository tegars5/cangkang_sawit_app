import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/error/failures.dart';
import '../../../shipments/domain/entities/shipment.dart';

/// Repository interface for Driver operations
abstract class DriverRepository {
  /// Get driver tasks (shipments assigned to driver)
  Future<dartz.Either<Failure, List<Shipment>>> getDriverTasks({
    required String driverId,
    String? status,
  });

  /// Accept task
  Future<dartz.Either<Failure, Shipment>> acceptTask({
    required String shipmentId,
  });

  /// Start delivery
  Future<dartz.Either<Failure, Shipment>> startDelivery({
    required String shipmentId,
  });

  /// Complete delivery
  Future<dartz.Either<Failure, Shipment>> completeDelivery({
    required String shipmentId,
    String? notes,
  });

  /// Update location
  Future<dartz.Either<Failure, void>> updateLocation({
    required String driverId,
    required double latitude,
    required double longitude,
  });

  /// Get assigned deliveries for driver
  Future<dartz.Either<Failure, List<Shipment>>> getAssignedDeliveries({
    required String driverId,
  });

  /// Get today's deliveries for driver
  Future<dartz.Either<Failure, List<Shipment>>> getTodayDeliveries({
    required String driverId,
  });

  /// Mark delivery as picked up
  Future<dartz.Either<Failure, Shipment>> markAsPickedUp({
    required String shipmentId,
  });

  /// Mark delivery as delivered
  Future<dartz.Either<Failure, Shipment>> markAsDelivered({
    required String shipmentId,
    String? notes,
  });

  /// Update delivery status
  Future<dartz.Either<Failure, Shipment>> updateDeliveryStatus({
    required String shipmentId,
    required String status,
  });

  /// Upload proof of delivery
  Future<dartz.Either<Failure, String>> uploadProofOfDelivery({
    required String shipmentId,
    required String imagePath,
  });
}
