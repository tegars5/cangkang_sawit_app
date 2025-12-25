import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/order_summary.dart';
import '../../domain/repositories/mitra_repository.dart';
import '../datasources/mitra_remote_datasource.dart';

/// Mitra Repository Implementation
class MitraRepositoryImpl implements MitraRepository {
  final MitraRemoteDataSource dataSource;
  final SupabaseClient supabaseClient;

  MitraRepositoryImpl({required this.dataSource, required this.supabaseClient});

  /// Get current user ID (customer ID)
  String? _getCurrentUserId() {
    return supabaseClient.auth.currentUser?.id;
  }

  @override
  Future<Either<Failure, List<OrderSummary>>> getOrderHistory({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final customerId = _getCurrentUserId();
      if (customerId == null) {
        return Left(AuthFailure('User not authenticated'));
      }

      final models = await dataSource.getOrderHistory(
        customerId: customerId,
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
  Future<Either<Failure, List<OrderSummary>>> getActiveOrders() async {
    try {
      final customerId = _getCurrentUserId();
      if (customerId == null) {
        return Left(AuthFailure('User not authenticated'));
      }

      final models = await dataSource.getActiveOrders(customerId: customerId);

      final orders = models.map((m) => m.toDomain()).toList();
      return Right(orders);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<OrderSummary>>> getCompletedOrders() async {
    try {
      final customerId = _getCurrentUserId();
      if (customerId == null) {
        return Left(AuthFailure('User not authenticated'));
      }

      final models = await dataSource.getCompletedOrders(
        customerId: customerId,
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
  Future<Either<Failure, OrderSummary>> getOrderById(String orderId) async {
    try {
      final model = await dataSource.getOrderById(orderId);
      return Right(model.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> trackActiveOrder(
    String orderId,
  ) async {
    try {
      final result = await dataSource.trackActiveOrder(orderId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDashboardStats() async {
    try {
      final customerId = _getCurrentUserId();
      if (customerId == null) {
        return Left(AuthFailure('User not authenticated'));
      }

      final result = await dataSource.getDashboardStats(customerId: customerId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
