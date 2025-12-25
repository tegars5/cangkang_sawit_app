import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/cart_item_model.dart';

/// Cart Local Data Source
/// Manages cart data in local storage using SharedPreferences
abstract class CartLocalDataSource {
  /// Get all cart items from local storage
  Future<List<CartItemModel>> getCartItems();

  /// Add or update cart item in local storage
  Future<void> addToCart(CartItemModel item);

  /// Remove cart item from local storage
  Future<void> removeFromCart(String productId);

  /// Update item quantity in local storage
  Future<void> updateQuantity(String productId, int quantity);

  /// Clear all cart items from local storage
  Future<void> clearCart();

  /// Get cart item by product ID
  Future<CartItemModel?> getCartItemByProductId(String productId);
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _cartKey = 'CART_ITEMS';

  CartLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<CartItemModel>> getCartItems() async {
    try {
      final jsonString = sharedPreferences.getString(_cartKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Failed to get cart items: ${e.toString()}');
    }
  }

  @override
  Future<void> addToCart(CartItemModel item) async {
    try {
      final items = await getCartItems();

      // Check if item already exists
      final existingIndex = items.indexWhere(
        (i) => i.productId == item.productId,
      );

      if (existingIndex != -1) {
        // Update quantity if item exists
        final existingItem = items[existingIndex];
        items[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + item.quantity,
        );
      } else {
        // Add new item
        items.add(item);
      }

      await _saveCartItems(items);
    } catch (e) {
      throw CacheException('Failed to add to cart: ${e.toString()}');
    }
  }

  @override
  Future<void> removeFromCart(String productId) async {
    try {
      final items = await getCartItems();
      items.removeWhere((item) => item.productId == productId);
      await _saveCartItems(items);
    } catch (e) {
      throw CacheException('Failed to remove from cart: ${e.toString()}');
    }
  }

  @override
  Future<void> updateQuantity(String productId, int quantity) async {
    try {
      final items = await getCartItems();
      final index = items.indexWhere((item) => item.productId == productId);

      if (index != -1) {
        items[index] = items[index].copyWith(quantity: quantity);
        await _saveCartItems(items);
      } else {
        throw CacheException('Cart item not found');
      }
    } catch (e) {
      throw CacheException('Failed to update quantity: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await sharedPreferences.remove(_cartKey);
    } catch (e) {
      throw CacheException('Failed to clear cart: ${e.toString()}');
    }
  }

  @override
  Future<CartItemModel?> getCartItemByProductId(String productId) async {
    try {
      final items = await getCartItems();
      final index = items.indexWhere((item) => item.productId == productId);
      return index != -1 ? items[index] : null;
    } catch (e) {
      throw CacheException('Failed to get cart item: ${e.toString()}');
    }
  }

  /// Save cart items to local storage
  Future<void> _saveCartItems(List<CartItemModel> items) async {
    try {
      final jsonList = items.map((item) => item.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await sharedPreferences.setString(_cartKey, jsonString);
    } catch (e) {
      throw CacheException('Failed to save cart items: ${e.toString()}');
    }
  }
}
