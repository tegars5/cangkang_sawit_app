import 'package:dartz/dartz.dart' hide Order;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// Use case for cancelling an order
class CancelOrder implements UseCase<Order, CancelOrderParams> {
  final OrderRepository repository;

  CancelOrder(this.repository);

  @override
  Future<Either<Failure, Order>> call(CancelOrderParams params) async {
    // Validation
    if (params.orderId.isEmpty) {
      return Left(ValidationFailure('Order ID cannot be empty'));
    }

    if (params.reason.isEmpty) {
      return Left(ValidationFailure('Cancellation reason cannot be empty'));
    }

    return await repository.cancelOrder(params.orderId, params.reason);
  }
}

/// Parameters for CancelOrder use case
class CancelOrderParams {
  final String orderId;
  final String reason;

  const CancelOrderParams({required this.orderId, required this.reason});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CancelOrderParams &&
        other.orderId == orderId &&
        other.reason == reason;
  }

  @override
  int get hashCode => orderId.hashCode ^ reason.hashCode;
}
