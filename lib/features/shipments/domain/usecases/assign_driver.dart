import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/models.dart';
import '../repositories/shipment_repository.dart';

/// Use case for assigning driver to shipment
class AssignDriver implements UseCase<Shipment, AssignDriverParams> {
  final ShipmentRepository repository;

  AssignDriver(this.repository);

  @override
  Future<dartz.Either<Failure, Shipment>> call(
    AssignDriverParams params,
  ) async {
    // Business validation
    if (params.shipmentId.isEmpty) {
      return const dartz.Left(ValidationFailure('Shipment ID cannot be empty'));
    }

    if (params.driverId.isEmpty) {
      return const dartz.Left(ValidationFailure('Driver ID cannot be empty'));
    }

    return await repository.assignDriver(
      shipmentId: params.shipmentId,
      driverId: params.driverId,
    );
  }
}

/// Parameters for AssignDriver use case
class AssignDriverParams {
  final String shipmentId;
  final String driverId;

  const AssignDriverParams({required this.shipmentId, required this.driverId});
}
