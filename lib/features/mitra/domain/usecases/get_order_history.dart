import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order_summary.dart';
import '../repositories/mitra_repository.dart';

/// Get Order History Use Case
/// Retrieves order history for current mitra with optional filtering
class GetOrderHistory
    implements UseCase<List<OrderSummary>, GetOrderHistoryParams> {
  final MitraRepository repository;

  GetOrderHistory(this.repository);

  @override
  Future<Either<Failure, List<OrderSummary>>> call(
    GetOrderHistoryParams params,
  ) async {
    return await repository.getOrderHistory(
      status: params.status,
      startDate: params.startDate,
      endDate: params.endDate,
      limit: params.limit,
    );
  }
}

class GetOrderHistoryParams extends Equatable {
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? limit;

  const GetOrderHistoryParams({
    this.status,
    this.startDate,
    this.endDate,
    this.limit,
  });

  @override
  List<Object?> get props => [status, startDate, endDate, limit];
}
