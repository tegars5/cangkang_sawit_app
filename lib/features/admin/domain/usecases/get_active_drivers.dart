import 'package:dartz/dartz.dart' hide Order;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/driver_info.dart';
import '../repositories/admin_repository.dart';

/// Get Active Drivers Use Case
/// Retrieves all currently active drivers
class GetActiveDrivers implements UseCase<List<DriverInfo>, NoParams> {
  final AdminRepository repository;

  GetActiveDrivers(this.repository);

  @override
  Future<Either<Failure, List<DriverInfo>>> call(NoParams params) async {
    return await repository.getActiveDrivers();
  }
}
