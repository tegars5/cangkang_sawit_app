import '../../domain/entities/cart_item.dart';

/// Cart Item Model
/// Data transfer object for cart items with JSON serialization
class CartItemModel extends CartItem {
  const CartItemModel({
    required super.productId,
    required super.productName,
    required super.price,
    required super.quantity,
    super.imageUrl,
    super.unit,
    super.stock,
    required super.addedAt,
  });

  /// Create CartItemModel from JSON
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      imageUrl: json['image_url'] as String?,
      unit: json['unit'] as String?,
      stock: json['stock'] as int?,
      addedAt: DateTime.parse(json['added_at'] as String),
    );
  }

  /// Convert CartItemModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'image_url': imageUrl,
      'unit': unit,
      'stock': stock,
      'added_at': addedAt.toIso8601String(),
    };
  }

  /// Create CartItemModel from domain entity
  factory CartItemModel.fromDomain(CartItem item) {
    return CartItemModel(
      productId: item.productId,
      productName: item.productName,
      price: item.price,
      quantity: item.quantity,
      imageUrl: item.imageUrl,
      unit: item.unit,
      stock: item.stock,
      addedAt: item.addedAt,
    );
  }

  /// Convert to domain entity
  CartItem toDomain() {
    return CartItem(
      productId: productId,
      productName: productName,
      price: price,
      quantity: quantity,
      imageUrl: imageUrl,
      unit: unit,
      stock: stock,
      addedAt: addedAt,
    );
  }

  @override
  CartItemModel copyWith({
    String? productId,
    String? productName,
    double? price,
    int? quantity,
    String? imageUrl,
    String? unit,
    int? stock,
    DateTime? addedAt,
  }) {
    return CartItemModel(
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
}
