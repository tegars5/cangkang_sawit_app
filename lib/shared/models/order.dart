import 'user_profile.dart';
import 'product.dart';

/// Model untuk Order (Pesanan) - orders table
class Order {
  final String id; // UUID primary key
  final String orderNumber; // UNIQUE
  final String customerId; // Foreign key to profiles
  final DateTime orderDate;
  final String status; // pending, confirmed, shipped, completed, cancelled
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

  // Relasi
  final UserProfile? customer;
  final List<OrderDetail>? orderDetails;

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
    this.customer,
    this.orderDetails,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      customerId: json['customer_id'] as String,
      orderDate: DateTime.parse(json['order_date'] as String),
      status: json['status'] as String,
      totalQuantity: (json['total_quantity'] as num).toDouble(),
      confirmedQuantity: (json['confirmed_quantity'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['total_amount'] as num).toDouble(),
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

  /// Helper method untuk format total amount
  String get formattedTotalAmount {
    return 'Rp ${totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  /// Helper method untuk mendapatkan nama customer
  String get customerName => customer?.fullName ?? 'Unknown';

  /// Helper method untuk cek apakah pesanan bisa dikonfirmasi
  bool get canBeConfirmed => status == 'pending';

  /// Helper method untuk cek apakah pesanan bisa dikirim
  bool get canBeShipped => status == 'confirmed';

  /// Helper method untuk cek apakah pesanan sudah selesai
  bool get isCompleted => status == 'completed';

  /// Helper method untuk cek apakah pesanan dibatalkan
  bool get isCancelled => status == 'cancelled';

  /// Helper method untuk cek apakah pesanan dalam pengiriman
  bool get isShipped => status == 'shipped';

  /// Helper method untuk menghitung total quantity yang dipesan
  double get totalQuantityOrdered {
    if (orderDetails == null) return totalQuantity;
    return orderDetails!.fold(
      0,
      (sum, detail) => sum + detail.requestedQuantity,
    );
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
    UserProfile? customer,
    List<OrderDetail>? orderDetails,
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

/// Model untuk Order Detail (Detail Pesanan) - order_details table
class OrderDetail {
  final String id; // UUID primary key
  final String orderId; // Foreign key to orders
  final String productId; // Foreign key to products
  final double requestedQuantity;
  final double confirmedQuantity;
  final double unitPrice;
  final double subtotal;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Relasi
  final Product? product;

  const OrderDetail({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.requestedQuantity,
    this.confirmedQuantity = 0,
    required this.unitPrice,
    required this.subtotal,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.product,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String,
      requestedQuantity: (json['requested_quantity'] as num).toDouble(),
      confirmedQuantity: (json['confirmed_quantity'] as num?)?.toDouble() ?? 0,
      unitPrice: (json['unit_price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
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
      'requested_quantity': requestedQuantity,
      'confirmed_quantity': confirmedQuantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Helper method untuk mendapatkan nama produk
  String get productName => product?.name ?? 'Unknown Product';

  /// Helper method untuk mendapatkan satuan produk
  String get productUnit => product?.unit ?? 'ton';

  /// Helper method untuk format unit price
  String get formattedUnitPrice {
    return 'Rp ${unitPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  /// Helper method untuk format subtotal
  String get formattedSubtotal {
    return 'Rp ${subtotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  /// Helper method untuk cek apakah ada selisih quantity (partial acceptance)
  bool get isPartiallyAccepted => confirmedQuantity < requestedQuantity;

  /// Helper method untuk mendapatkan selisih quantity
  double get quantityDifference => requestedQuantity - confirmedQuantity;

  /// Helper method untuk cek apakah sudah dikonfirmasi
  bool get isConfirmed => confirmedQuantity > 0;

  OrderDetail copyWith({
    String? id,
    String? orderId,
    String? productId,
    double? requestedQuantity,
    double? confirmedQuantity,
    double? unitPrice,
    double? subtotal,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    Product? product,
  }) {
    return OrderDetail(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      requestedQuantity: requestedQuantity ?? this.requestedQuantity,
      confirmedQuantity: confirmedQuantity ?? this.confirmedQuantity,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      product: product ?? this.product,
    );
  }

  @override
  String toString() {
    return 'OrderDetail(id: $id, productName: $productName, requestedQuantity: $requestedQuantity, confirmedQuantity: $confirmedQuantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderDetail && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
