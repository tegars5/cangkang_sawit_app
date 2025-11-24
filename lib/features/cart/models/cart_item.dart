import '../../../shared/models/product.dart';

class CartItem {
  final String id;
  final Product product;
  final double quantity;
  final double unitPrice;
  final double subtotal;
  final DateTime addedAt;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.addedAt,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as String? ?? '',
      product: Product.fromJson(map['product'] as Map<String, dynamic>),
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      unitPrice: (map['price_per_ton'] as num?)?.toDouble() ?? 0.0,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      addedAt: map['added_at'] != null
          ? DateTime.parse(map['added_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'price_per_ton': unitPrice,
      'subtotal': subtotal,
      'added_at': addedAt.toIso8601String(),
    };
  }

  factory CartItem.fromProduct({
    required String id,
    required Product product,
    required double quantity,
  }) {
    final unitPrice = product.pricePerTon;
    final subtotal = quantity * unitPrice;

    return CartItem(
      id: id,
      product: product,
      quantity: quantity,
      unitPrice: unitPrice,
      subtotal: subtotal,
      addedAt: DateTime.now(),
    );
  }

  CartItem copyWith({
    String? id,
    Product? product,
    double? quantity,
    double? unitPrice,
    double? subtotal,
    DateTime? addedAt,
  }) {
    final newQuantity = quantity ?? this.quantity;
    final newUnitPrice = unitPrice ?? this.unitPrice;
    final newSubtotal = subtotal ?? (newQuantity * newUnitPrice);

    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: newQuantity,
      unitPrice: newUnitPrice,
      subtotal: newSubtotal,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  CartItem updateQuantity(double newQuantity) {
    return copyWith(quantity: newQuantity, subtotal: newQuantity * unitPrice);
  }

  String get productId => product.id;
  String get productName => product.name;
  String get productUnit => product.unit;
  double get stockAvailable => product.stockAvailable;
  bool get hasStock => product.hasStock;

  String get formattedQuantity => '${quantity.toStringAsFixed(1)} $productUnit';
  String get formattedUnitPrice => 'Rp ${unitPrice.toStringAsFixed(0)}';
  String get formattedSubtotal => 'Rp ${subtotal.toStringAsFixed(0)}';

  bool get isQuantityValid => quantity <= stockAvailable && quantity > 0;

  String? get stockValidationMessage {
    if (quantity <= 0) return 'Quantity harus lebih dari 0';
    if (quantity > stockAvailable) {
      return 'Quantity melebihi stok tersedia (${stockAvailable.toStringAsFixed(1)} $productUnit)';
    }
    return null;
  }

  @override
  String toString() {
    return 'CartItem(id: $id, productName: $productName, quantity: $formattedQuantity, subtotal: $formattedSubtotal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
