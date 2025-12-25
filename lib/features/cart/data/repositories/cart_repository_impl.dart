import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_datasource.dart';
import '../models/cart_item_model.dart';

/// Cart Repository Implementation
/// Implements cart repository using local data source
class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<CartItem>>> getCartItems() async {
    try {
      final models = await localDataSource.getCartItems();
      final entities = models.map((model) => model.toDomain()).toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get cart items: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> addToCart(CartItem item) async {
    try {
      final model = CartItemModel.fromDomain(item);
      await localDataSource.addToCart(model);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to add to cart: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCart(String productId) async {
    try {
      await localDataSource.removeFromCart(productId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to remove from cart: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateQuantity(
    String productId,
    int quantity,
  ) async {
    try {
      await localDataSource.updateQuantity(productId, quantity);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to update quantity: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      await localDataSource.clearCart();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to clear cart: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CartItem?>> getCartItemByProductId(
    String productId,
  ) async {
    try {
      final model = await localDataSource.getCartItemByProductId(productId);
      return Right(model?.toDomain());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get cart item: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getCartItemCount() async {
    try {
      final models = await localDataSource.getCartItems();
      final totalItems = models.fold<int>(
        0,
        (sum, item) => sum + item.quantity,
      );
      return Right(totalItems);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(
        CacheFailure('Failed to get cart item count: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, double>> getCartTotal() async {
    try {
      final models = await localDataSource.getCartItems();
      final total = models.fold<double>(
        0.0,
        (sum, item) => sum + item.subtotal,
      );
      return Right(total);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get cart total: ${e.toString()}'));
    }
  }
}
