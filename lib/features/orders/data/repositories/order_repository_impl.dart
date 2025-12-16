import 'package:dartz/dartz.dart' hide Order;
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';
import '../models/order_model.dart';

/// Implementation of OrderRepository
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Order>>> getOrders({
    String? customerId,
    String? status,
  }) async {
    try {
      final orderModels = await remoteDataSource.getOrders(
        customerId: customerId,
        status: status,
      );
      return Right(orderModels.map((model) => model.toDomain()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Order>> getOrderById(String id) async {
    try {
      final orderModel = await remoteDataSource.getOrderById(id);
      return Right(orderModel.toDomain());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Order>> createOrder(Order order) async {
    try {
      final orderModel = OrderModel.fromDomain(order);
      final createdOrderModel = await remoteDataSource.createOrder(orderModel);
      return Right(createdOrderModel.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Order>> confirmOrder(
    String id,
    double confirmedQuantity,
  ) async {
    try {
      final orderModel = await remoteDataSource.confirmOrder(
        id,
        confirmedQuantity,
      );
      return Right(orderModel.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Order>> cancelOrder(String id, String reason) async {
    try {
      final orderModel = await remoteDataSource.cancelOrder(id, reason);
      return Right(orderModel.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Order>> updateOrderStatus(
    String id,
    String status,
  ) async {
    try {
      final orderModel = await remoteDataSource.updateOrderStatus(id, status);
      return Right(orderModel.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
