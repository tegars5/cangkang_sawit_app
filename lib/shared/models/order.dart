import 'user_profile.dart';
import 'product.dart';

/// Model untuk Order (Pesanan)
class Order {
  final String id;
  final String customerId;
  final String orderNumber;
  final DateTime createdAt;
  final String status;
  final double? totalAmount;
  final String? customerNotes;
  final DateTime? updatedAt;

  // Relasi
  final UserProfile? customer;
  final List<OrderDetail>? orderDetails;

  const Order({
    required this.id,
    required this.customerId,
    required this.orderNumber,
    required this.createdAt,
    required this.status,
    this.totalAmount,
    this.customerNotes,
    this.updatedAt,
    this.customer,
    this.orderDetails,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      orderNumber: json['order_number'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: json['status'] as String,
      totalAmount: json['total_amount'] != null
          ? (json['total_amount'] as num).toDouble()
          : null,
      customerNotes: json['customer_notes'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      customer: json['profiles'] != null
          ? UserProfile.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
      orderDetails: json['order_details'] != null
          ? (json['order_details'] as List)
                .map(
                  (detail) =>
                      OrderDetail.fromJson(detail as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'order_number': orderNumber,
      'created_at': createdAt.toIso8601String(),
      'status': status,
      'total_amount': totalAmount,
      'customer_notes': customerNotes,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Helper method untuk format total amount
  String get formattedTotalAmount {
    if (totalAmount == null) return 'Rp 0';
    return 'Rp ${totalAmount!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  /// Helper method untuk mendapatkan nama customer
  String get customerName => customer?.fullName ?? 'Unknown';

  /// Helper method untuk cek apakah pesanan bisa dikonfirmasi
  bool get canBeConfirmed => status == 'pending';

  /// Helper method untuk cek apakah pesanan bisa dikirim
  bool get canBeShipped => status == 'confirmed';

  /// Helper method untuk cek apakah pesanan sudah selesai
  bool get isCompleted => status == 'delivered';

  /// Helper method untuk menghitung total quantity yang dipesan
  double get totalQuantityOrdered {
    if (orderDetails == null) return 0;
    return orderDetails!.fold(0, (sum, detail) => sum + detail.totalQuantity);
  }

  /// Helper method untuk menghitung total quantity yang diterima
  double get totalQuantityConfirmed {
    if (orderDetails == null) return 0;
    return orderDetails!.fold(
      0,
      (sum, detail) => sum + detail.confirmedQuantity,
    );
  }

  Order copyWith({
    String? id,
    String? customerId,
    String? orderNumber,
    DateTime? createdAt,
    String? status,
    double? totalAmount,
    String? customerNotes,
    DateTime? updatedAt,
    UserProfile? customer,
    List<OrderDetail>? orderDetails,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      orderNumber: orderNumber ?? this.orderNumber,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      customerNotes: customerNotes ?? this.customerNotes,
      updatedAt: updatedAt ?? this.updatedAt,
      customer: customer ?? this.customer,
      orderDetails: orderDetails ?? this.orderDetails,
    );
  }

  @override
  String toString() {
    return 'Order(id: $id, orderNumber: $orderNumber, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Model untuk Order Detail (Detail Pesanan)
class OrderDetail {
  final String id;
  final String orderId;
  final String productId;
  final double totalQuantity;
  final double confirmedQuantity;
  final double unitPrice;
  final double? subtotal;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Relasi
  final Product? product;

  const OrderDetail({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.totalQuantity,
    required this.confirmedQuantity,
    required this.unitPrice,
    this.subtotal,
    this.createdAt,
    this.updatedAt,
    this.product,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String,
      totalQuantity: (json['total_quantity'] as num).toDouble(),
      confirmedQuantity: (json['confirmed_quantity'] as num).toDouble(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      subtotal: json['subtotal'] != null
          ? (json['subtotal'] as num).toDouble()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      product: json['products'] != null
          ? Product.fromJson(json['products'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'total_quantity': totalQuantity,
      'confirmed_quantity': confirmedQuantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Helper method untuk mendapatkan nama produk
  String get productName => product?.name ?? 'Unknown Product';

  /// Helper method untuk mendapatkan satuan produk
  String get productUnit => product?.unit ?? '';

  /// Helper method untuk format unit price
  String get formattedUnitPrice {
    return 'Rp ${unitPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  /// Helper method untuk format subtotal
  String get formattedSubtotal {
    final calculatedSubtotal = subtotal ?? (confirmedQuantity * unitPrice);
    return 'Rp ${calculatedSubtotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  /// Helper method untuk cek apakah ada selisih quantity (partial acceptance)
  bool get isPartiallyAccepted => confirmedQuantity < totalQuantity;

  /// Helper method untuk mendapatkan selisih quantity
  double get quantityDifference => totalQuantity - confirmedQuantity;

  OrderDetail copyWith({
    String? id,
    String? orderId,
    String? productId,
    double? totalQuantity,
    double? confirmedQuantity,
    double? unitPrice,
    double? subtotal,
    DateTime? createdAt,
    DateTime? updatedAt,
    Product? product,
  }) {
    return OrderDetail(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      confirmedQuantity: confirmedQuantity ?? this.confirmedQuantity,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      product: product ?? this.product,
    );
  }

  @override
  String toString() {
    return 'OrderDetail(id: $id, productName: $productName, totalQuantity: $totalQuantity, confirmedQuantity: $confirmedQuantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderDetail && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
