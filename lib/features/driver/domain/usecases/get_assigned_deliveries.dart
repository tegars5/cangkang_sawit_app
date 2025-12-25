import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../shipments/domain/entities/shipment.dart';
import '../repositories/driver_repository.dart';

/// Use case for getting assigned deliveries for a driver
class GetAssignedDeliveries
    implements UseCase<List<Shipment>, GetAssignedDeliveriesParams> {
  final DriverRepository repository;

  GetAssignedDeliveries(this.repository);

  @override
  Future<Either<Failure, List<Shipment>>> call(
    GetAssignedDeliveriesParams params,
  ) {
    return repository.getAssignedDeliveries(driverId: params.driverId);
  }
}

class GetAssignedDeliveriesParams {
  final String driverId;

  const GetAssignedDeliveriesParams({required this.driverId});
}
