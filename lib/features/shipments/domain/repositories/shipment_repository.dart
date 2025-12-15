import 'package:cangkang_sawit_app/shared/models/shipment.dart';
import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/error/failures.dart';
import '../../../../shared/models/shipment_timeline.dart';

/// Repository interface for Shipment operations
abstract class ShipmentRepository {
  /// Get all shipments with optional filtering
  Future<dartz.Either<Failure, List<Shipment>>> getShipments({
    String? status,
    String? driverId,
  });

  /// Get shipment by ID
  Future<dartz.Either<Failure, Shipment>> getShipmentById(String shipmentId);

  /// Assign driver to shipment
  Future<dartz.Either<Failure, Shipment>> assignDriver({
    required String shipmentId,
    required String driverId,
  });

  /// Update shipment status
  Future<dartz.Either<Failure, Shipment>> updateShipmentStatus({
    required String shipmentId,
    required String newStatus,
  });

  /// Add timeline event
  Future<dartz.Either<Failure, void>> addTimelineEvent({
    required String shipmentId,
    required ShipmentTimeline event,
  });
}
