import 'package:dartz/dartz.dart' hide Order;
import '../../../../core/error/failures.dart';
import '../entities/dashboard_stats.dart';
import '../entities/driver_info.dart';
import '../../../orders/domain/entities/order.dart';

/// Admin Repository Interface
/// Defines the contract for admin operations
abstract class AdminRepository {
  /// Get dashboard statistics
  Future<Either<Failure, DashboardStats>> getDashboardStats();

  /// Get all drivers
  Future<Either<Failure, List<DriverInfo>>> getAllDrivers();

  /// Get active drivers only
  Future<Either<Failure, List<DriverInfo>>> getActiveDrivers();

  /// Get available drivers (active and not on duty)
  Future<Either<Failure, List<DriverInfo>>> getAvailableDrivers();

  /// Get driver by ID
  Future<Either<Failure, DriverInfo>> getDriverById(String driverId);

  /// Update driver status (activate/deactivate)
  Future<Either<Failure, DriverInfo>> updateDriverStatus({
    required String driverId,
    required bool isActive,
  });

  /// Get all orders for admin view
  Future<Either<Failure, List<Order>>> getAllOrders({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  /// Get recent orders
  Future<Either<Failure, List<Order>>> getRecentOrders({int limit = 10});

  /// Get orders by status
  Future<Either<Failure, List<Order>>> getOrdersByStatus(String status);

  /// Get system health metrics
  Future<Either<Failure, Map<String, dynamic>>> getSystemHealth();

  /// Get revenue analytics
  Future<Either<Failure, Map<String, dynamic>>> getRevenueAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });
}
