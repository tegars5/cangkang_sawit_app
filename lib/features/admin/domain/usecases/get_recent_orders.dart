import 'package:dartz/dartz.dart' hide Order;
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../orders/domain/entities/order.dart';
import '../repositories/admin_repository.dart';

/// Get Recent Orders Use Case
/// Retrieves the most recent orders
class GetRecentOrders implements UseCase<List<Order>, GetRecentOrdersParams> {
  final AdminRepository repository;

  GetRecentOrders(this.repository);

  @override
  Future<Either<Failure, List<Order>>> call(
    GetRecentOrdersParams params,
  ) async {
    return await repository.getRecentOrders(limit: params.limit);
  }
}

class GetRecentOrdersParams extends Equatable {
  final int limit;

  const GetRecentOrdersParams({this.limit = 10});

  @override
  List<Object> get props => [limit];
}
