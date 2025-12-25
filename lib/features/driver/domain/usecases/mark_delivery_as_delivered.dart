import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../shipments/domain/entities/shipment.dart';
import '../repositories/driver_repository.dart';

/// Use case for marking delivery as delivered
class MarkDeliveryAsDelivered
    implements UseCase<Shipment, MarkDeliveryAsDeliveredParams> {
  final DriverRepository repository;

  MarkDeliveryAsDelivered(this.repository);

  @override
  Future<Either<Failure, Shipment>> call(MarkDeliveryAsDeliveredParams params) {
    return repository.markAsDelivered(
      shipmentId: params.shipmentId,
      notes: params.notes,
    );
  }
}

class MarkDeliveryAsDeliveredParams {
  final String shipmentId;
  final String? notes;

  const MarkDeliveryAsDeliveredParams({required this.shipmentId, this.notes});
}
