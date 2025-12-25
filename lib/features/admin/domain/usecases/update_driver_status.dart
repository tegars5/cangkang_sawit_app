import 'package:dartz/dartz.dart' hide Order;
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/driver_info.dart';
import '../repositories/admin_repository.dart';

/// Update Driver Status Use Case
/// Activates or deactivates a driver
class UpdateDriverStatus
    implements UseCase<DriverInfo, UpdateDriverStatusParams> {
  final AdminRepository repository;

  UpdateDriverStatus(this.repository);

  @override
  Future<Either<Failure, DriverInfo>> call(
    UpdateDriverStatusParams params,
  ) async {
    return await repository.updateDriverStatus(
      driverId: params.driverId,
      isActive: params.isActive,
    );
  }
}

class UpdateDriverStatusParams extends Equatable {
  final String driverId;
  final bool isActive;

  const UpdateDriverStatusParams({
    required this.driverId,
    required this.isActive,
  });

  @override
  List<Object> get props => [driverId, isActive];
}
