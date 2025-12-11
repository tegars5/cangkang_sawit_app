import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/models.dart';
import '../repositories/order_repository.dart';

/// Use case for confirming orders (admin only)
class ConfirmOrder implements UseCase<Order, ConfirmOrderParams> {
  final OrderRepository repository;

  ConfirmOrder(this.repository);

  @override
  Future<dartz.Either<Failure, Order>> call(ConfirmOrderParams params) async {
    // Business validation
    if (params.confirmedItems.isEmpty) {
      return const dartz.Left(
        ValidationFailure('Must confirm at least one item'),
      );
    }

    return await repository.confirmOrder(
      orderId: params.orderId,
      confirmedItems: params.confirmedItems,
    );
  }
}

/// Parameters for ConfirmOrder use case
class ConfirmOrderParams {
  final String orderId;
  final List<Map<String, dynamic>> confirmedItems;

  const ConfirmOrderParams({
    required this.orderId,
    required this.confirmedItems,
  });
}
