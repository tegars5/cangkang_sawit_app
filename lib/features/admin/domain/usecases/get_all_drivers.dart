import 'package:dartz/dartz.dart' hide Order;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/driver_info.dart';
import '../repositories/admin_repository.dart';

/// Get All Drivers Use Case
/// Retrieves all registered drivers
class GetAllDrivers implements UseCase<List<DriverInfo>, NoParams> {
  final AdminRepository repository;

  GetAllDrivers(this.repository);

  @override
  Future<Either<Failure, List<DriverInfo>>> call(NoParams params) async {
    return await repository.getAllDrivers();
  }
}
