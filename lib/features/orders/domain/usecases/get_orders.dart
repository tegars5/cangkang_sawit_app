import 'package:dartz/dartz.dart' hide Order;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// Use case for getting orders with optional filters
class GetOrders implements UseCase<List<Order>, GetOrdersParams> {
  final OrderRepository repository;

  GetOrders(this.repository);

  @override
  Future<Either<Failure, List<Order>>> call(GetOrdersParams params) async {
    return await repository.getOrders(
      customerId: params.customerId,
      status: params.status,
    );
  }
}

/// Parameters for GetOrders use case
class GetOrdersParams {
  final String? customerId;
  final String? status;

  const GetOrdersParams({this.customerId, this.status});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GetOrdersParams &&
        other.customerId == customerId &&
        other.status == status;
  }

  @override
  int get hashCode => customerId.hashCode ^ status.hashCode;
}
