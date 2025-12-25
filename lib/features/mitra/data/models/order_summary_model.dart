import '../../domain/entities/order_summary.dart';

/// Order Summary Model
/// Data transfer object for order summary
class OrderSummaryModel {
  final String id;
  final String orderNumber;
  final String status;
  final DateTime orderDate;
  final DateTime? confirmedDate;
  final DateTime? shippedDate;
  final DateTime? deliveredDate;
  final double totalAmount;
  final int totalItems;
  final String? notes;
  final String? driverName;
  final String? driverPhone;
  final String? trackingNumber;
  final String deliveryAddress;
  final double? latitude;
  final double? longitude;

  OrderSummaryModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.orderDate,
    this.confirmedDate,
    this.shippedDate,
    this.deliveredDate,
    required this.totalAmount,
    required this.totalItems,
    this.notes,
    this.driverName,
    this.driverPhone,
    this.trackingNumber,
    required this.deliveryAddress,
    this.latitude,
    this.longitude,
  });

  factory OrderSummaryModel.fromJson(Map<String, dynamic> json) {
    return OrderSummaryModel(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      status: json['status'] as String,
      orderDate: DateTime.parse(json['created_at'] as String),
      confirmedDate: json['confirmed_at'] != null
          ? DateTime.parse(json['confirmed_at'] as String)
          : null,
      shippedDate: json['shipped_at'] != null
          ? DateTime.parse(json['shipped_at'] as String)
          : null,
      deliveredDate: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      totalAmount: (json['total_amount'] as num).toDouble(),
      totalItems: json['total_items'] as int? ?? 0,
      notes: json['notes'] as String?,
      driverName: json['driver_name'] as String?,
      driverPhone: json['driver_phone'] as String?,
      trackingNumber: json['tracking_number'] as String?,
      deliveryAddress: json['delivery_address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'status': status,
      'created_at': orderDate.toIso8601String(),
      'confirmed_at': confirmedDate?.toIso8601String(),
      'shipped_at': shippedDate?.toIso8601String(),
      'delivered_at': deliveredDate?.toIso8601String(),
      'total_amount': totalAmount,
      'total_items': totalItems,
      'notes': notes,
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'tracking_number': trackingNumber,
      'delivery_address': deliveryAddress,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  OrderSummary toDomain() {
    return OrderSummary(
      id: id,
      orderNumber: orderNumber,
      status: status,
      orderDate: orderDate,
      confirmedDate: confirmedDate,
      shippedDate: shippedDate,
      deliveredDate: deliveredDate,
      totalAmount: totalAmount,
      totalItems: totalItems,
      notes: notes,
      driverName: driverName,
      driverPhone: driverPhone,
      trackingNumber: trackingNumber,
      deliveryAddress: deliveryAddress,
      latitude: latitude,
      longitude: longitude,
    );
  }

  factory OrderSummaryModel.fromDomain(OrderSummary entity) {
    return OrderSummaryModel(
      id: entity.id,
      orderNumber: entity.orderNumber,
      status: entity.status,
      orderDate: entity.orderDate,
      confirmedDate: entity.confirmedDate,
      shippedDate: entity.shippedDate,
      deliveredDate: entity.deliveredDate,
      totalAmount: entity.totalAmount,
      totalItems: entity.totalItems,
      notes: entity.notes,
      driverName: entity.driverName,
      driverPhone: entity.driverPhone,
      trackingNumber: entity.trackingNumber,
      deliveryAddress: entity.deliveryAddress,
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }
}
