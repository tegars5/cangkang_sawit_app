/// Order domain entity - Pure business logic without JSON serialization
class Order {
  final String id;
  final String orderNumber;
  final String customerId;
  final DateTime orderDate;
  final String status;
  final double totalQuantity;
  final double confirmedQuantity;
  final double totalAmount;
  final String? adminNotes;
  final String? customerNotes;
  final DateTime? confirmedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? pickupAddress;
  final String? deliveryAddress;
  final DateTime? pickupDate;
  final DateTime? deliveryDate;
  final String? notes;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.orderDate,
    required this.status,
    required this.totalQuantity,
    this.confirmedQuantity = 0,
    required this.totalAmount,
    this.adminNotes,
    this.customerNotes,
    this.confirmedAt,
    this.completedAt,
    required this.createdAt,
    this.updatedAt,
    this.pickupAddress,
    this.deliveryAddress,
    this.pickupDate,
    this.deliveryDate,
    this.notes,
  });

  // Business logic methods
  bool isPending() => status == 'pending';
  bool isConfirmed() => status == 'confirmed';
  bool isShipped() => status == 'shipped';
  bool isCompleted() => status == 'completed';
  bool isCancelled() => status == 'cancelled';

  bool canBeCancelled() => isPending() || isConfirmed();
  bool canBeConfirmed() => isPending();
  bool canBeShipped() => isConfirmed();
  bool canBeCompleted() => isShipped();

  bool hasConfirmedQuantity() => confirmedQuantity > 0;
  bool isFullyConfirmed() => confirmedQuantity >= totalQuantity;
  bool isPartiallyConfirmed() =>
      confirmedQuantity > 0 && confirmedQuantity < totalQuantity;

  // Copy with method for immutability
  Order copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    DateTime? orderDate,
    String? status,
    double? totalQuantity,
    double? confirmedQuantity,
    double? totalAmount,
    String? adminNotes,
    String? customerNotes,
    DateTime? confirmedAt,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? pickupAddress,
    String? deliveryAddress,
    DateTime? pickupDate,
    DateTime? deliveryDate,
    String? notes,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      confirmedQuantity: confirmedQuantity ?? this.confirmedQuantity,
      totalAmount: totalAmount ?? this.totalAmount,
      adminNotes: adminNotes ?? this.adminNotes,
      customerNotes: customerNotes ?? this.customerNotes,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      pickupDate: pickupDate ?? this.pickupDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Order &&
        other.id == id &&
        other.orderNumber == orderNumber &&
        other.customerId == customerId &&
        other.orderDate == orderDate &&
        other.status == status &&
        other.totalQuantity == totalQuantity &&
        other.confirmedQuantity == confirmedQuantity &&
        other.totalAmount == totalAmount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        orderNumber.hashCode ^
        customerId.hashCode ^
        orderDate.hashCode ^
        status.hashCode ^
        totalQuantity.hashCode ^
        confirmedQuantity.hashCode ^
        totalAmount.hashCode;
  }
}
