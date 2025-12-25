import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/order_summary.dart';

/// Mitra Repository Interface
/// Defines the contract for mitra (partner/customer) operations
abstract class MitraRepository {
  /// Get order history for current mitra
  Future<Either<Failure, List<OrderSummary>>> getOrderHistory({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  /// Get active orders for current mitra
  Future<Either<Failure, List<OrderSummary>>> getActiveOrders();

  /// Get completed orders for current mitra
  Future<Either<Failure, List<OrderSummary>>> getCompletedOrders();

  /// Get order by ID
  Future<Either<Failure, OrderSummary>> getOrderById(String orderId);

  /// Track active order (get real-time location)
  Future<Either<Failure, Map<String, dynamic>>> trackActiveOrder(
    String orderId,
  );

  /// Get dashboard statistics for mitra
  Future<Either<Failure, Map<String, dynamic>>> getDashboardStats();
}
