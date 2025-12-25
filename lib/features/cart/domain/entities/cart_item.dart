import 'package:equatable/equatable.dart';

/// Cart Item Entity
/// Represents a product item in the shopping cart
class CartItem extends Equatable {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? imageUrl;
  final String? unit;
  final int? stock;
  final DateTime addedAt;

  const CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.unit,
    this.stock,
    required this.addedAt,
  });

  // Business Methods

  /// Calculate subtotal for this item
  double get subtotal => price * quantity;

  /// Check if quantity is valid (> 0)
  bool get hasValidQuantity => quantity > 0;

  /// Check if item is in stock
  bool get isInStock {
    if (stock == null) return true; // No stock info means assume in stock
    return stock! > 0;
  }

  /// Check if requested quantity exceeds stock
  bool get exceedsStock {
    if (stock == null) return false; // No stock info means no limit
    return quantity > stock!;
  }

  /// Get remaining stock after current quantity
  int? get remainingStock {
    if (stock == null) return null;
    return stock! - quantity;
  }

  /// Check if can increase quantity
  bool canIncreaseQuantity() {
    if (stock == null) return true; // No stock limit
    return quantity < stock!;
  }

  /// Check if can decrease quantity
  bool canDecreaseQuantity() {
    return quantity > 1;
  }

  /// Get maximum allowed quantity based on stock
  int getMaxAllowedQuantity() {
    if (stock == null) return 999; // Default max if no stock info
    return stock!;
  }

  /// Check if item was added today
  bool isAddedToday() {
    final now = DateTime.now();
    return addedAt.year == now.year &&
        addedAt.month == now.month &&
        addedAt.day == now.day;
  }

  /// Get age of item in cart (in days)
  int getAgeInDays() {
    return DateTime.now().difference(addedAt).inDays;
  }

  /// Check if item is old (more than 7 days)
  bool isOld() {
    return getAgeInDays() > 7;
  }

  /// Format price with currency
  String getFormattedPrice() {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  /// Format subtotal with currency
  String getFormattedSubtotal() {
    return 'Rp ${subtotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  /// Get display text for unit
  String getUnitText() {
    return unit ?? 'pcs';
  }

  /// Get quantity with unit text
  String getQuantityWithUnit() {
    return '$quantity ${getUnitText()}';
  }

  /// Create a copy with updated quantity
  CartItem increaseQuantity() {
    return copyWith(quantity: quantity + 1);
  }

  /// Create a copy with decreased quantity
  CartItem decreaseQuantity() {
    if (quantity > 1) {
      return copyWith(quantity: quantity - 1);
    }
    return this;
  }

  /// Create a copy with specific quantity
  CartItem updateQuantity(int newQuantity) {
    if (newQuantity < 1) return this;
    if (stock != null && newQuantity > stock!) {
      return copyWith(quantity: stock!);
    }
    return copyWith(quantity: newQuantity);
  }

  /// Validate cart item
  List<String> validate() {
    final errors = <String>[];

    if (productId.isEmpty) {
      errors.add('Product ID is required');
    }

    if (productName.isEmpty) {
      errors.add('Product name is required');
    }

    if (price <= 0) {
      errors.add('Price must be greater than 0');
    }

    if (quantity <= 0) {
      errors.add('Quantity must be greater than 0');
    }

    if (stock != null && quantity > stock!) {
      errors.add('Quantity exceeds available stock ($stock!)');
    }

    return errors;
  }

  /// Check if item is valid
  bool get isValid => validate().isEmpty;

  CartItem copyWith({
    String? productId,
    String? productName,
    double? price,
    int? quantity,
    String? imageUrl,
    String? unit,
    int? stock,
    DateTime? addedAt,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  List<Object?> get props => [
    productId,
    productName,
    price,
    quantity,
    imageUrl,
    unit,
    stock,
    addedAt,
  ];
}
