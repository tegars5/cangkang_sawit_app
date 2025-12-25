import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart_item.dart';

/// Cart Repository Interface
/// Defines contract for cart data operations
abstract class CartRepository {
  /// Get all items in cart
  Future<Either<Failure, List<CartItem>>> getCartItems();

  /// Add item to cart (or update quantity if already exists)
  Future<Either<Failure, void>> addToCart(CartItem item);

  /// Remove item from cart
  Future<Either<Failure, void>> removeFromCart(String productId);

  /// Update item quantity in cart
  Future<Either<Failure, void>> updateQuantity(String productId, int quantity);

  /// Clear all items from cart
  Future<Either<Failure, void>> clearCart();

  /// Get cart item by product ID
  Future<Either<Failure, CartItem?>> getCartItemByProductId(String productId);

  /// Get total number of items in cart
  Future<Either<Failure, int>> getCartItemCount();

  /// Get total cart value
  Future<Either<Failure, double>> getCartTotal();
}
