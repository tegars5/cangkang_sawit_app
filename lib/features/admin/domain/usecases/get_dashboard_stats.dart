import 'package:dartz/dartz.dart' hide Order;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_stats.dart';
import '../repositories/admin_repository.dart';

/// Get Dashboard Statistics Use Case
/// Retrieves comprehensive dashboard statistics for admin view
class GetDashboardStats implements UseCase<DashboardStats, NoParams> {
  final AdminRepository repository;

  GetDashboardStats(this.repository);

  @override
  Future<Either<Failure, DashboardStats>> call(NoParams params) async {
    return await repository.getDashboardStats();
  }
}
