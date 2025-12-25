import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';

/// Cart State
/// Immutable state class for cart feature
class CartState extends Equatable {
  final List<CartItem> items;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const CartState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  // Computed Properties

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart has items
  bool get isNotEmpty => items.isNotEmpty;

  /// Get total number of items (sum of quantities)
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Get number of unique products
  int get uniqueProducts => items.length;

  /// Get total cart value
  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.subtotal);

  /// Get formatted total amount
  String get formattedTotal {
    return 'Rp ${totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  /// Check if any item exceeds stock
  bool get hasStockIssue => items.any((item) => item.exceedsStock);

  /// Get items that exceed stock
  List<CartItem> get itemsWithStockIssue =>
      items.where((item) => item.exceedsStock).toList();

  /// Get items that are out of stock
  List<CartItem> get outOfStockItems =>
      items.where((item) => !item.isInStock).toList();

  /// Check if cart has out of stock items
  bool get hasOutOfStockItems => outOfStockItems.isNotEmpty;

  /// Get valid items (in stock and not exceeding stock)
  List<CartItem> get validItems =>
      items.where((item) => item.isInStock && !item.exceedsStock).toList();

  /// Check if cart can be checked out (all items valid)
  bool get canCheckout => isNotEmpty && !hasStockIssue && !hasOutOfStockItems;

  /// Get old items (added more than 7 days ago)
  List<CartItem> get oldItems => items.where((item) => item.isOld()).toList();

  /// Check if cart has old items
  bool get hasOldItems => oldItems.isNotEmpty;

  /// Check if there are any errors
  bool get hasError => error != null;

  /// Check if there is a success message
  bool get hasSuccessMessage => successMessage != null;

  /// Get item by product ID
  CartItem? getItemByProductId(String productId) {
    try {
      return items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  /// Check if product is in cart
  bool hasProduct(String productId) {
    return items.any((item) => item.productId == productId);
  }

  /// Get quantity of product in cart
  int getProductQuantity(String productId) {
    final item = getItemByProductId(productId);
    return item?.quantity ?? 0;
  }

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }

  CartState clearError() {
    return copyWith(error: '');
  }

  CartState clearSuccessMessage() {
    return copyWith(successMessage: '');
  }

  @override
  List<Object?> get props => [items, isLoading, error, successMessage];
}
