import '../../domain/entities/order_detail.dart';

/// Data model for OrderDetail with JSON serialization
class OrderDetailModel extends OrderDetail {
  const OrderDetailModel({
    required super.id,
    required super.orderId,
    required super.productId,
    required super.productName,
    required super.quantity,
    required super.pricePerUnit,
    required super.subtotal,
    super.notes,
    required super.createdAt,
    super.updatedAt,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      pricePerUnit: (json['price_per_unit'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price_per_unit': pricePerUnit,
      'subtotal': subtotal,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to domain entity
  OrderDetail toDomain() {
    return OrderDetail(
      id: id,
      orderId: orderId,
      productId: productId,
      productName: productName,
      quantity: quantity,
      pricePerUnit: pricePerUnit,
      subtotal: subtotal,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory OrderDetailModel.fromDomain(OrderDetail detail) {
    return OrderDetailModel(
      id: detail.id,
      orderId: detail.orderId,
      productId: detail.productId,
      productName: detail.productName,
      quantity: detail.quantity,
      pricePerUnit: detail.pricePerUnit,
      subtotal: detail.subtotal,
      notes: detail.notes,
      createdAt: detail.createdAt,
      updatedAt: detail.updatedAt,
    );
  }
}
