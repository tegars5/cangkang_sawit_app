import 'package:dartz/dartz.dart' hide Order;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// Use case for creating a new order
class CreateOrder implements UseCase<Order, Order> {
  final OrderRepository repository;

  CreateOrder(this.repository);

  @override
  Future<Either<Failure, Order>> call(Order order) async {
    // Validation
    if (order.totalQuantity <= 0) {
      return Left(ValidationFailure('Total quantity must be greater than 0'));
    }

    if (order.totalAmount <= 0) {
      return Left(ValidationFailure('Total amount must be greater than 0'));
    }

    return await repository.createOrder(order);
  }
}
