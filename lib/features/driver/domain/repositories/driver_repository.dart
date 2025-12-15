import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/error/failures.dart';
import '../../../../shared/models/shipment.dart';

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
}
