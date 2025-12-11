import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/models.dart';
import '../repositories/order_repository.dart';

/// Use case for getting orders
class GetOrders implements UseCase<List<Order>, GetOrdersParams> {
  final OrderRepository repository;

  GetOrders(this.repository);

  @override
  Future<dartz.Either<Failure, List<Order>>> call(
    GetOrdersParams params,
  ) async {
    return await repository.getOrders(
      status: params.status,
      customerId: params.customerId,
    );
  }
}

/// Parameters for GetOrders use case
class GetOrdersParams {
  final String? status;
  final String? customerId;

  const GetOrdersParams({this.status, this.customerId});
}
