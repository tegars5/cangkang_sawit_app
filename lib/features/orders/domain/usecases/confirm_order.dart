import 'package:dartz/dartz.dart' hide Order;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// Use case for confirming an order (Admin only)
class ConfirmOrder implements UseCase<Order, ConfirmOrderParams> {
  final OrderRepository repository;

  ConfirmOrder(this.repository);

  @override
  Future<Either<Failure, Order>> call(ConfirmOrderParams params) async {
    // Validation
    if (params.orderId.isEmpty) {
      return Left(ValidationFailure('Order ID cannot be empty'));
    }

    if (params.confirmedQuantity <= 0) {
      return Left(
        ValidationFailure('Confirmed quantity must be greater than 0'),
      );
    }

    return await repository.confirmOrder(
      params.orderId,
      params.confirmedQuantity,
    );
  }
}

/// Parameters for ConfirmOrder use case
class ConfirmOrderParams {
  final String orderId;
  final double confirmedQuantity;

  const ConfirmOrderParams({
    required this.orderId,
    required this.confirmedQuantity,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConfirmOrderParams &&
        other.orderId == orderId &&
        other.confirmedQuantity == confirmedQuantity;
  }

  @override
  int get hashCode => orderId.hashCode ^ confirmedQuantity.hashCode;
}
