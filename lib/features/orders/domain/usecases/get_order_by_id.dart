import 'package:dartz/dartz.dart' hide Order;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// Use case for getting a single order by ID
class GetOrderById implements UseCase<Order, String> {
  final OrderRepository repository;

  GetOrderById(this.repository);

  @override
  Future<Either<Failure, Order>> call(String id) async {
    if (id.isEmpty) {
      return Left(ValidationFailure('Order ID cannot be empty'));
    }

    return await repository.getOrderById(id);
  }
}
