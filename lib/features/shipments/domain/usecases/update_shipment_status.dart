import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/models.dart';
import '../repositories/shipment_repository.dart';

/// Use case for updating shipment status
class UpdateShipmentStatus
    implements UseCase<Shipment, UpdateShipmentStatusParams> {
  final ShipmentRepository repository;

  UpdateShipmentStatus(this.repository);

  @override
  Future<dartz.Either<Failure, Shipment>> call(
    UpdateShipmentStatusParams params,
  ) async {
    // Business validation
    if (params.shipmentId.isEmpty) {
      return const dartz.Left(ValidationFailure('Shipment ID cannot be empty'));
    }

    if (params.newStatus.isEmpty) {
      return const dartz.Left(ValidationFailure('Status cannot be empty'));
    }

    return await repository.updateShipmentStatus(
      shipmentId: params.shipmentId,
      newStatus: params.newStatus,
    );
  }
}

/// Parameters for UpdateShipmentStatus use case
class UpdateShipmentStatusParams {
  final String shipmentId;
  final String newStatus;

  const UpdateShipmentStatusParams({
    required this.shipmentId,
    required this.newStatus,
  });
}
