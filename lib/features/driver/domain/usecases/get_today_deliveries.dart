import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../shipments/domain/entities/shipment.dart';
import '../repositories/driver_repository.dart';

/// Use case for getting today's deliveries for a driver
class GetTodayDeliveries implements UseCase<List<Shipment>, String> {
  final DriverRepository repository;

  GetTodayDeliveries(this.repository);

  @override
  Future<Either<Failure, List<Shipment>>> call(String driverId) {
    return repository.getTodayDeliveries(driverId: driverId);
  }
}
