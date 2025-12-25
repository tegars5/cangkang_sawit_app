import 'package:dartz/dartz.dart' hide Order;
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/driver_info.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';
import '../../../orders/domain/entities/order.dart';

/// Admin Repository Implementation
class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource dataSource;

  AdminRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() async {
    try {
      final model = await dataSource.getDashboardStats();
      return Right(model.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DriverInfo>>> getAllDrivers() async {
    try {
      final models = await dataSource.getAllDrivers();
      final drivers = models.map((m) => m.toDomain()).toList();
      return Right(drivers);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DriverInfo>>> getActiveDrivers() async {
    try {
      final models = await dataSource.getActiveDrivers();
      final drivers = models.map((m) => m.toDomain()).toList();
      return Right(drivers);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DriverInfo>>> getAvailableDrivers() async {
    try {
      final models = await dataSource.getAvailableDrivers();
      final drivers = models.map((m) => m.toDomain()).toList();
      return Right(drivers);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DriverInfo>> getDriverById(String driverId) async {
    try {
      final model = await dataSource.getDriverById(driverId);
      return Right(model.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DriverInfo>> updateDriverStatus({
    required String driverId,
    required bool isActive,
  }) async {
    try {
      final model = await dataSource.updateDriverStatus(
        driverId: driverId,
        isActive: isActive,
      );
      return Right(model.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getAllOrders({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final models = await dataSource.getAllOrders(
        status: status,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
      final orders = models.map((m) => m.toDomain()).toList();
      return Right(orders);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getRecentOrders({int limit = 10}) async {
    try {
      final models = await dataSource.getRecentOrders(limit: limit);
      final orders = models.map((m) => m.toDomain()).toList();
      return Right(orders);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getOrdersByStatus(String status) async {
    try {
      final models = await dataSource.getOrdersByStatus(status);
      final orders = models.map((m) => m.toDomain()).toList();
      return Right(orders);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSystemHealth() async {
    try {
      final result = await dataSource.getSystemHealth();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRevenueAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await dataSource.getRevenueAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
