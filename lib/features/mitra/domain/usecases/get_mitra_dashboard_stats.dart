import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/mitra_repository.dart';

/// Get Dashboard Stats Use Case
/// Retrieves dashboard statistics for current mitra
class GetMitraDashboardStats
    implements UseCase<Map<String, dynamic>, NoParams> {
  final MitraRepository repository;

  GetMitraDashboardStats(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(NoParams params) async {
    return await repository.getDashboardStats();
  }
}
