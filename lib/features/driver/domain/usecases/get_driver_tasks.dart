import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/models.dart';
import '../repositories/driver_repository.dart';

/// Use case for getting driver tasks
class GetDriverTasks implements UseCase<List<Shipment>, GetDriverTasksParams> {
  final DriverRepository repository;

  GetDriverTasks(this.repository);

  @override
  Future<dartz.Either<Failure, List<Shipment>>> call(
    GetDriverTasksParams params,
  ) async {
    if (params.driverId.isEmpty) {
      return const dartz.Left(ValidationFailure('Driver ID cannot be empty'));
    }

    return await repository.getDriverTasks(
      driverId: params.driverId,
      status: params.status,
    );
  }
}

class GetDriverTasksParams {
  final String driverId;
  final String? status;

  const GetDriverTasksParams({required this.driverId, this.status});
}
