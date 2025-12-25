import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order_summary.dart';
import '../repositories/mitra_repository.dart';

/// Get Active Orders Use Case
/// Retrieves all active orders for current mitra
class GetActiveOrders implements UseCase<List<OrderSummary>, NoParams> {
  final MitraRepository repository;

  GetActiveOrders(this.repository);

  @override
  Future<Either<Failure, List<OrderSummary>>> call(NoParams params) async {
    return await repository.getActiveOrders();
  }
}
