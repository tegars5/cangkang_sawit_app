import 'package:dartz/dartz.dart' hide Order;
import '../../../../core/error/failures.dart';
import '../entities/order.dart';

/// Repository interface for Order operations
abstract class OrderRepository {
  /// Get all orders with optional filters
  ///
  /// [customerId] - Filter by customer ID
  /// [status] - Filter by order status (pending, confirmed, shipped, completed, cancelled)
  Future<Either<Failure, List<Order>>> getOrders({
    String? customerId,
    String? status,
  });

  /// Get a single order by ID
  ///
  /// Returns [NotFoundFailure] if order doesn't exist
  Future<Either<Failure, Order>> getOrderById(String id);

  /// Create a new order
  ///
  /// Returns the created order with generated ID and order number
  Future<Either<Failure, Order>> createOrder(Order order);

  /// Confirm an order (Admin only)
  ///
  /// [id] - Order ID to confirm
  /// [confirmedQuantity] - Quantity confirmed by admin
  ///
  /// Returns [ValidationFailure] if order is not in pending status
  Future<Either<Failure, Order>> confirmOrder(
    String id,
    double confirmedQuantity,
  );

  /// Cancel an order
  ///
  /// [id] - Order ID to cancel
  /// [reason] - Cancellation reason
  ///
  /// Returns [ValidationFailure] if order cannot be cancelled
  Future<Either<Failure, Order>> cancelOrder(String id, String reason);

  /// Update order status
  ///
  /// [id] - Order ID
  /// [status] - New status
  Future<Either<Failure, Order>> updateOrderStatus(String id, String status);
}
