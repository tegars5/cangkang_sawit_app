import 'package:dartz/dartz.dart' hide Order;
import '../../../core/error/failures.dart';
import '../../../shared/models/models.dart';

/// Repository interface for Order operations
/// This defines the contract that the data layer must implement
abstract class OrderRepository {
  /// Get all orders with optional filtering
  Future<Either<Failure, List<Order>>> getOrders({
    String? status,
    String? customerId,
  });

  /// Get order by ID with details
  Future<Either<Failure, Order>> getOrderById(String orderId);

  /// Create new order with items
  Future<Either<Failure, Order>> createOrder({
    required Order order,
    required List<OrderDetail> items,
  });

  /// Confirm order (admin only)
  Future<Either<Failure, Order>> confirmOrder({
    required String orderId,
    required List<Map<String, dynamic>> confirmedItems,
  });

  /// Cancel order
  Future<Either<Failure, Order>> cancelOrder({
    required String orderId,
    required String reason,
  });

  /// Update order status
  Future<Either<Failure, Order>> updateOrderStatus({
    required String orderId,
    required String newStatus,
  });
}
