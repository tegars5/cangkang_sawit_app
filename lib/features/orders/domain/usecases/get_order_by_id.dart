import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/models.dart';
import '../repositories/order_repository.dart';

/// Use case for getting order by ID
class GetOrderById implements UseCase<Order, String> {
  final OrderRepository repository;

  GetOrderById(this.repository);

  @override
  Future<dartz.Either<Failure, Order>> call(String orderId) async {
    if (orderId.isEmpty) {
      return const dartz.Left(ValidationFailure('Order ID cannot be empty'));
    }

    return await repository.getOrderById(orderId);
  }
}
