import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../shipments/domain/entities/shipment.dart';
import '../repositories/driver_repository.dart';

/// Use case for marking delivery as picked up
class MarkDeliveryAsPickedUp implements UseCase<Shipment, String> {
  final DriverRepository repository;

  MarkDeliveryAsPickedUp(this.repository);

  @override
  Future<Either<Failure, Shipment>> call(String shipmentId) {
    return repository.markAsPickedUp(shipmentId: shipmentId);
  }
}
