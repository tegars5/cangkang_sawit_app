import 'package:dartz/dartz.dart' hide Order;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// Use case for updating order status
class UpdateOrderStatus implements UseCase<Order, UpdateOrderStatusParams> {
  final OrderRepository repository;

  UpdateOrderStatus(this.repository);

  @override
  Future<Either<Failure, Order>> call(UpdateOrderStatusParams params) async {
    // Validation
    if (params.orderId.isEmpty) {
      return Left(ValidationFailure('Order ID cannot be empty'));
    }

    if (params.status.isEmpty) {
      return Left(ValidationFailure('Status cannot be empty'));
    }

    // Validate status values
    const validStatuses = [
      'pending',
      'confirmed',
      'shipped',
      'completed',
      'cancelled',
    ];
    if (!validStatuses.contains(params.status.toLowerCase())) {
      return Left(
        ValidationFailure(
          'Invalid status. Valid values: ${validStatuses.join(', ')}',
        ),
      );
    }

    return await repository.updateOrderStatus(params.orderId, params.status);
  }
}

/// Parameters for UpdateOrderStatus use case
class UpdateOrderStatusParams {
  final String orderId;
  final String status;

  const UpdateOrderStatusParams({required this.orderId, required this.status});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UpdateOrderStatusParams &&
        other.orderId == orderId &&
        other.status == status;
  }

  @override
  int get hashCode => orderId.hashCode ^ status.hashCode;
}
