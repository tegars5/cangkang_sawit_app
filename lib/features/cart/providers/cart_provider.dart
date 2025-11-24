import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/models/product.dart';
import '../models/cart_item.dart';

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void addItem({required Product product, required double quantity}) {
    final existingIndex = state.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingIndex >= 0) {
      final existingItem = state[existingIndex];
      final newQuantity = existingItem.quantity + quantity;

      if (newQuantity <= product.stockAvailable) {
        final updatedItem = existingItem.updateQuantity(newQuantity);
        state = [
          ...state.sublist(0, existingIndex),
          updatedItem,
          ...state.sublist(existingIndex + 1),
        ];
      }
    } else {
      if (quantity <= product.stockAvailable) {
        final cartItem = CartItem.fromProduct(
          id: const Uuid().v4(),
          product: product,
          quantity: quantity,
        );
        state = [...state, cartItem];
      }
    }
  }

  void removeItem(String itemId) {
    state = state.where((item) => item.id != itemId).toList();
  }

  void updateItemQuantity(String itemId, double newQuantity) {
    final itemIndex = state.indexWhere((item) => item.id == itemId);

    if (itemIndex >= 0) {
      final item = state[itemIndex];

      if (newQuantity <= 0) {
        removeItem(itemId);
        return;
      }

      if (newQuantity <= item.stockAvailable) {
        final updatedItem = item.updateQuantity(newQuantity);
        state = [
          ...state.sublist(0, itemIndex),
          updatedItem,
          ...state.sublist(itemIndex + 1),
        ];
      }
    }
  }

  void clearCart() {
    state = [];
  }

  double get totalAmount {
    return state.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  double get totalQuantity {
    return state.fold(0.0, (sum, item) => sum + item.quantity);
  }

  int get itemCount => state.length;

  bool get isEmpty => state.isEmpty;
  bool get isNotEmpty => state.isNotEmpty;

  List<CartItem> get validItems {
    return state.where((item) => item.isQuantityValid).toList();
  }

  bool get hasInvalidItems {
    return state.any((item) => !item.isQuantityValid);
  }

  String get formattedTotalAmount => 'Rp ${totalAmount.toStringAsFixed(0)}';
  String get formattedTotalQuantity =>
      '${totalQuantity.toStringAsFixed(1)} ton';
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(() {
  return CartNotifier();
});

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.subtotal);
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).length;
});

final cartValidationProvider = Provider<Map<String, dynamic>>((ref) {
  final cart = ref.watch(cartProvider);

  final hasInvalidItems = cart.any((item) => !item.isQuantityValid);
  final invalidItems = cart.where((item) => !item.isQuantityValid).toList();

  return {
    'isValid': !hasInvalidItems,
    'hasInvalidItems': hasInvalidItems,
    'invalidItems': invalidItems,
    'errorMessage': hasInvalidItems
        ? 'Beberapa item memiliki quantity tidak valid'
        : null,
  };
});

final formattedCartTotalProvider = Provider<String>((ref) {
  final total = ref.watch(cartTotalProvider);
  return 'Rp ${total.toStringAsFixed(0)}';
});

final cartSummaryProvider = Provider<Map<String, dynamic>>((ref) {
  final cart = ref.watch(cartProvider);
  final total = ref.watch(cartTotalProvider);

  final totalQuantity = cart.fold(0.0, (sum, item) => sum + item.quantity);

  return {
    'itemCount': cart.length,
    'totalQuantity': totalQuantity,
    'formattedTotalQuantity': '${totalQuantity.toStringAsFixed(1)} ton',
    'totalAmount': total,
    'formattedTotalAmount': 'Rp ${total.toStringAsFixed(0)}',
    'isEmpty': cart.isEmpty,
    'isNotEmpty': cart.isNotEmpty,
  };
});
