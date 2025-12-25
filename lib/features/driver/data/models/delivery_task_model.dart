import '../../domain/entities/delivery_task.dart';

/// Data model for DeliveryTask with JSON serialization
class DeliveryTaskModel {
  final String id;
  final String shipmentId;
  final String orderId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String status;
  final DateTime? scheduledDeliveryDate;
  final DateTime? actualDeliveryDate;
  final double totalWeight;
  final int totalQuantity;
  final String? notes;
  final String? proofOfDeliveryUrl;
  final String? recipientName;
  final String? recipientSignature;
  final DateTime? pickupDate;
  final bool isPriority;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeliveryTaskModel({
    required this.id,
    required this.shipmentId,
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    required this.status,
    this.scheduledDeliveryDate,
    this.actualDeliveryDate,
    required this.totalWeight,
    required this.totalQuantity,
    this.notes,
    this.proofOfDeliveryUrl,
    this.recipientName,
    this.recipientSignature,
    this.pickupDate,
    this.isPriority = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert from JSON to Model
  factory DeliveryTaskModel.fromJson(Map<String, dynamic> json) {
    return DeliveryTaskModel(
      id: json['id'] as String,
      shipmentId: json['shipment_id'] as String,
      orderId: json['order_id'] as String,
      customerId: json['customer_id'] as String,
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String,
      deliveryAddress: json['delivery_address'] as String,
      deliveryLatitude: json['delivery_latitude'] != null
          ? (json['delivery_latitude'] as num).toDouble()
          : null,
      deliveryLongitude: json['delivery_longitude'] != null
          ? (json['delivery_longitude'] as num).toDouble()
          : null,
      status: json['status'] as String,
      scheduledDeliveryDate: json['scheduled_delivery_date'] != null
          ? DateTime.parse(json['scheduled_delivery_date'] as String)
          : null,
      actualDeliveryDate: json['actual_delivery_date'] != null
          ? DateTime.parse(json['actual_delivery_date'] as String)
          : null,
      totalWeight: (json['total_weight'] as num).toDouble(),
      totalQuantity: json['total_quantity'] as int,
      notes: json['notes'] as String?,
      proofOfDeliveryUrl: json['proof_of_delivery_url'] as String?,
      recipientName: json['recipient_name'] as String?,
      recipientSignature: json['recipient_signature'] as String?,
      pickupDate: json['pickup_date'] != null
          ? DateTime.parse(json['pickup_date'] as String)
          : null,
      isPriority: json['is_priority'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert from Model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shipment_id': shipmentId,
      'order_id': orderId,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'delivery_address': deliveryAddress,
      'delivery_latitude': deliveryLatitude,
      'delivery_longitude': deliveryLongitude,
      'status': status,
      'scheduled_delivery_date': scheduledDeliveryDate?.toIso8601String(),
      'actual_delivery_date': actualDeliveryDate?.toIso8601String(),
      'total_weight': totalWeight,
      'total_quantity': totalQuantity,
      'notes': notes,
      'proof_of_delivery_url': proofOfDeliveryUrl,
      'recipient_name': recipientName,
      'recipient_signature': recipientSignature,
      'pickup_date': pickupDate?.toIso8601String(),
      'is_priority': isPriority,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert Model to Domain Entity
  DeliveryTask toDomain() {
    return DeliveryTask(
      id: id,
      shipmentId: shipmentId,
      orderId: orderId,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      deliveryAddress: deliveryAddress,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
      status: status,
      scheduledDeliveryDate: scheduledDeliveryDate,
      actualDeliveryDate: actualDeliveryDate,
      totalWeight: totalWeight,
      totalQuantity: totalQuantity,
      notes: notes,
      proofOfDeliveryUrl: proofOfDeliveryUrl,
      recipientName: recipientName,
      recipientSignature: recipientSignature,
      pickupDate: pickupDate,
      isPriority: isPriority,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert Domain Entity to Model
  factory DeliveryTaskModel.fromDomain(DeliveryTask task) {
    return DeliveryTaskModel(
      id: task.id,
      shipmentId: task.shipmentId,
      orderId: task.orderId,
      customerId: task.customerId,
      customerName: task.customerName,
      customerPhone: task.customerPhone,
      deliveryAddress: task.deliveryAddress,
      deliveryLatitude: task.deliveryLatitude,
      deliveryLongitude: task.deliveryLongitude,
      status: task.status,
      scheduledDeliveryDate: task.scheduledDeliveryDate,
      actualDeliveryDate: task.actualDeliveryDate,
      totalWeight: task.totalWeight,
      totalQuantity: task.totalQuantity,
      notes: task.notes,
      proofOfDeliveryUrl: task.proofOfDeliveryUrl,
      recipientName: task.recipientName,
      recipientSignature: task.recipientSignature,
      pickupDate: task.pickupDate,
      isPriority: task.isPriority,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
  }
}
