import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/models/models.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

/// Implementation of OrderRepository
/// Connects domain layer with data layer
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;

  OrderRepositoryImpl({required OrderRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<dartz.Either<Failure, List<Order>>> getOrders({
    String? status,
    String? customerId,
  }) async {
    try {
      final orders = await _remoteDataSource.getOrders(
        status: status,
        customerId: customerId,
      );
      return dartz.Right(orders);
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return dartz.Left(NetworkFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, Order>> getOrderById(String orderId) async {
    try {
      final order = await _remoteDataSource.getOrderById(orderId);
      return dartz.Right(order);
    } on NotFoundException catch (e) {
      return dartz.Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, Order>> createOrder({
    required Order order,
    required List<OrderDetail> items,
  }) async {
    try {
      final createdOrder = await _remoteDataSource.createOrder(
        order: order,
        items: items,
      );
      return dartz.Right(createdOrder);
    } on ValidationException catch (e) {
      return dartz.Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, Order>> confirmOrder({
    required String orderId,
    required List<Map<String, dynamic>> confirmedItems,
  }) async {
    try {
      final confirmedOrder = await _remoteDataSource.confirmOrder(
        orderId: orderId,
        confirmedItems: confirmedItems,
      );
      return dartz.Right(confirmedOrder);
    } on NotFoundException catch (e) {
      return dartz.Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, Order>> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    try {
      final cancelledOrder = await _remoteDataSource.cancelOrder(
        orderId: orderId,
        reason: reason,
      );
      return dartz.Right(cancelledOrder);
    } on NotFoundException catch (e) {
      return dartz.Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, Order>> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    try {
      final updatedOrder = await _remoteDataSource.updateOrderStatus(
        orderId: orderId,
        newStatus: newStatus,
      );
      return dartz.Right(updatedOrder);
    } on NotFoundException catch (e) {
      return dartz.Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
