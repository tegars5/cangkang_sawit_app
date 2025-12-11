import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/models.dart';
import '../repositories/order_repository.dart';

/// Use case for creating orders
class CreateOrder implements UseCase<Order, CreateOrderParams> {
  final OrderRepository repository;

  CreateOrder(this.repository);

  @override
  Future<dartz.Either<Failure, Order>> call(CreateOrderParams params) async {
    // Business validation
    if (params.items.isEmpty) {
      return const dartz.Left(
        ValidationFailure('Order must have at least one item'),
      );
    }

    if (params.order.totalQuantity <= 0) {
      return const dartz.Left(
        ValidationFailure('Total quantity must be greater than zero'),
      );
    }

    if (params.order.totalAmount <= 0) {
      return const dartz.Left(
        ValidationFailure('Total amount must be greater than zero'),
      );
    }

    return await repository.createOrder(
      order: params.order,
      items: params.items,
    );
  }
}

/// Parameters for CreateOrder use case
class CreateOrderParams {
  final Order order;
  final List<OrderDetail> items;

  const CreateOrderParams({required this.order, required this.items});
}
