import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../shipments/domain/entities/shipment.dart';
import '../repositories/driver_repository.dart';

/// Use case for updating delivery status
class UpdateDeliveryStatus
    implements UseCase<Shipment, UpdateDeliveryStatusParams> {
  final DriverRepository repository;

  UpdateDeliveryStatus(this.repository);

  @override
  Future<Either<Failure, Shipment>> call(UpdateDeliveryStatusParams params) {
    return repository.updateDeliveryStatus(
      shipmentId: params.shipmentId,
      status: params.status,
    );
  }
}

class UpdateDeliveryStatusParams {
  final String shipmentId;
  final String status;

  const UpdateDeliveryStatusParams({
    required this.shipmentId,
    required this.status,
  });
}
