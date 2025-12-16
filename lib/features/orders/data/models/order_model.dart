import '../../domain/entities/order.dart';

/// Data model for Order with JSON serialization
class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.orderNumber,
    required super.customerId,
    required super.orderDate,
    required super.status,
    required super.totalQuantity,
    super.confirmedQuantity,
    required super.totalAmount,
    super.adminNotes,
    super.customerNotes,
    super.confirmedAt,
    super.completedAt,
    required super.createdAt,
    super.updatedAt,
    super.pickupAddress,
    super.deliveryAddress,
    super.pickupDate,
    super.deliveryDate,
    super.notes,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      customerId: json['customer_id'] as String,
      orderDate: DateTime.parse(json['order_date'] as String),
      status: json['status'] as String,
      totalQuantity: (json['total_quantity'] as num?)?.toDouble() ?? 0.0,
      confirmedQuantity:
          (json['confirmed_quantity'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      adminNotes: json['admin_notes'] as String?,
      customerNotes: json['customer_notes'] as String?,
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.parse(json['confirmed_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      pickupAddress: json['pickup_address'] as String?,
      deliveryAddress: json['delivery_address'] as String?,
      pickupDate: json['pickup_date'] != null
          ? DateTime.parse(json['pickup_date'] as String)
          : null,
      deliveryDate: json['delivery_date'] != null
          ? DateTime.parse(json['delivery_date'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer_id': customerId,
      'order_date': orderDate.toIso8601String(),
      'status': status,
      'total_quantity': totalQuantity,
      'confirmed_quantity': confirmedQuantity,
      'total_amount': totalAmount,
      'admin_notes': adminNotes,
      'customer_notes': customerNotes,
      'confirmed_at': confirmedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'pickup_address': pickupAddress,
      'delivery_address': deliveryAddress,
      'pickup_date': pickupDate?.toIso8601String(),
      'delivery_date': deliveryDate?.toIso8601String(),
      'notes': notes,
    };
  }

  /// Convert to domain entity
  Order toDomain() {
    return Order(
      id: id,
      orderNumber: orderNumber,
      customerId: customerId,
      orderDate: orderDate,
      status: status,
      totalQuantity: totalQuantity,
      confirmedQuantity: confirmedQuantity,
      totalAmount: totalAmount,
      adminNotes: adminNotes,
      customerNotes: customerNotes,
      confirmedAt: confirmedAt,
      completedAt: completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      pickupAddress: pickupAddress,
      deliveryAddress: deliveryAddress,
      pickupDate: pickupDate,
      deliveryDate: deliveryDate,
      notes: notes,
    );
  }

  /// Create from domain entity
  factory OrderModel.fromDomain(Order order) {
    return OrderModel(
      id: order.id,
      orderNumber: order.orderNumber,
      customerId: order.customerId,
      orderDate: order.orderDate,
      status: order.status,
      totalQuantity: order.totalQuantity,
      confirmedQuantity: order.confirmedQuantity,
      totalAmount: order.totalAmount,
      adminNotes: order.adminNotes,
      customerNotes: order.customerNotes,
      confirmedAt: order.confirmedAt,
      completedAt: order.completedAt,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
      pickupAddress: order.pickupAddress,
      deliveryAddress: order.deliveryAddress,
      pickupDate: order.pickupDate,
      deliveryDate: order.deliveryDate,
      notes: order.notes,
    );
  }
}
