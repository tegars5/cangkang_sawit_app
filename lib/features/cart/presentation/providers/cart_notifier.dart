import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/usecases/get_cart_items.dart';
import '../../domain/usecases/add_to_cart.dart';
import '../../domain/usecases/remove_from_cart.dart';
import '../../domain/usecases/update_cart_quantity.dart';
import '../../domain/usecases/clear_cart.dart';
import 'cart_state.dart';

/// Cart Notifier
/// State management for cart operations
class CartNotifier extends Notifier<CartState> {
  late final GetCartItems _getCartItems;
  late final AddToCart _addToCart;
  late final RemoveFromCart _removeFromCart;
  late final UpdateCartQuantity _updateCartQuantity;
  late final ClearCart _clearCart;

  @override
  CartState build() {
    // Initialize use cases from dependency injection
    _getCartItems = ref.read(getCartItemsUseCaseProvider);
    _addToCart = ref.read(addToCartUseCaseProvider);
    _removeFromCart = ref.read(removeFromCartUseCaseProvider);
    _updateCartQuantity = ref.read(updateCartQuantityUseCaseProvider);
    _clearCart = ref.read(clearCartUseCaseProvider);

    return const CartState();
  }

  /// Load cart items from local storage
  Future<void> loadCart() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getCartItems(NoParams());

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (items) => state = state.copyWith(isLoading: false, items: items),
    );
  }

  /// Add product to cart
  Future<void> addProductToCart(CartItem item) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _addToCart(AddToCartParams(item: item));

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) async {
        // Reload cart to get updated items
        await loadCart();
        state = state.copyWith(
          successMessage: '${item.productName} ditambahkan ke keranjang',
        );
      },
    );
  }

  /// Remove product from cart
  Future<void> removeProductFromCart(String productId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _removeFromCart(
      RemoveFromCartParams(productId: productId),
    );

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) async {
        // Reload cart to get updated items
        await loadCart();
        state = state.copyWith(successMessage: 'Produk dihapus dari keranjang');
      },
    );
  }

  /// Update quantity of product in cart
  Future<void> updateProductQuantity(String productId, int quantity) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _updateCartQuantity(
      UpdateCartQuantityParams(productId: productId, quantity: quantity),
    );

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) async {
        // Reload cart to get updated items
        await loadCart();
      },
    );
  }

  /// Increase quantity of product in cart
  Future<void> increaseQuantity(String productId) async {
    final item = state.getItemByProductId(productId);
    if (item != null && item.canIncreaseQuantity()) {
      await updateProductQuantity(productId, item.quantity + 1);
    } else {
      state = state.copyWith(
        error: 'Tidak dapat menambah jumlah, stok tidak mencukupi',
      );
    }
  }

  /// Decrease quantity of product in cart
  Future<void> decreaseQuantity(String productId) async {
    final item = state.getItemByProductId(productId);
    if (item != null) {
      if (item.canDecreaseQuantity()) {
        await updateProductQuantity(productId, item.quantity - 1);
      } else {
        // If quantity is 1, remove the item
        await removeProductFromCart(productId);
      }
    }
  }

  /// Clear all items from cart
  Future<void> clearAllCart() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _clearCart(NoParams());

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) {
        state = state.copyWith(
          isLoading: false,
          items: [],
          successMessage: 'Keranjang dikosongkan',
        );
      },
    );
  }

  /// Remove old items from cart (items older than 7 days)
  Future<void> removeOldItems() async {
    final oldItems = state.oldItems;
    for (final item in oldItems) {
      await removeProductFromCart(item.productId);
    }

    if (oldItems.isNotEmpty) {
      state = state.copyWith(
        successMessage: '${oldItems.length} produk lama dihapus dari keranjang',
      );
    }
  }

  /// Remove out of stock items
  Future<void> removeOutOfStockItems() async {
    final outOfStockItems = state.outOfStockItems;
    for (final item in outOfStockItems) {
      await removeProductFromCart(item.productId);
    }

    if (outOfStockItems.isNotEmpty) {
      state = state.copyWith(
        successMessage:
            '${outOfStockItems.length} produk habis dihapus dari keranjang',
      );
    }
  }

  /// Quick add product with basic info
  Future<void> quickAddProduct({
    required String productId,
    required String productName,
    required double price,
    int quantity = 1,
    String? imageUrl,
    String? unit,
    int? stock,
  }) async {
    final item = CartItem(
      productId: productId,
      productName: productName,
      price: price,
      quantity: quantity,
      imageUrl: imageUrl,
      unit: unit,
      stock: stock,
      addedAt: DateTime.now(),
    );

    await addProductToCart(item);
  }

  /// Check if product is in cart
  bool isProductInCart(String productId) {
    return state.hasProduct(productId);
  }

  /// Get product quantity in cart
  int getProductQuantityInCart(String productId) {
    return state.getProductQuantity(productId);
  }

  /// Clear error message
  void clearError() {
    state = state.clearError();
  }

  /// Clear success message
  void clearSuccessMessage() {
    state = state.clearSuccessMessage();
  }

  /// Refresh cart (reload from storage)
  Future<void> refreshCart() async {
    await loadCart();
  }
}
