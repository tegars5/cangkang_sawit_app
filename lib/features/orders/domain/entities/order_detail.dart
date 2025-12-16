/// OrderDetail domain entity - Represents a line item in an order
class OrderDetail {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final double quantity;
  final double pricePerUnit;
  final double subtotal;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OrderDetail({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.pricePerUnit,
    required this.subtotal,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  // Business logic methods
  bool isValid() => quantity > 0 && pricePerUnit > 0;

  double calculateSubtotal() => quantity * pricePerUnit;

  bool hasCorrectSubtotal() => (subtotal - calculateSubtotal()).abs() < 0.01;

  // Copy with method for immutability
  OrderDetail copyWith({
    String? id,
    String? orderId,
    String? productId,
    String? productName,
    double? quantity,
    double? pricePerUnit,
    double? subtotal,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderDetail(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      subtotal: subtotal ?? this.subtotal,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OrderDetail &&
        other.id == id &&
        other.orderId == orderId &&
        other.productId == productId &&
        other.quantity == quantity &&
        other.pricePerUnit == pricePerUnit &&
        other.subtotal == subtotal;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        orderId.hashCode ^
        productId.hashCode ^
        quantity.hashCode ^
        pricePerUnit.hashCode ^
        subtotal.hashCode;
  }
}
