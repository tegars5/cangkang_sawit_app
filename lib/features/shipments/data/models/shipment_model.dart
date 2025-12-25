import '../../domain/entities/shipment.dart';

/// Data model for Shipment with JSON serialization
///
/// This model handles conversion between JSON (API) and domain entity.
class ShipmentModel {
  final String id;
  final String orderId;
  final String? driverId;
  final String? driverName;
  final String? vehiclePlate;
  final String status;
  final String pickupAddress;
  final String deliveryAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final DateTime? scheduledPickupDate;
  final DateTime? actualPickupDate;
  final DateTime? estimatedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final double totalWeight;
  final int totalQuantity;
  final String? notes;
  final String? proofOfDeliveryUrl;
  final String? recipientName;
  final String? recipientSignature;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ShipmentModel({
    required this.id,
    required this.orderId,
    this.driverId,
    this.driverName,
    this.vehiclePlate,
    required this.status,
    required this.pickupAddress,
    required this.deliveryAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.scheduledPickupDate,
    this.actualPickupDate,
    this.estimatedDeliveryDate,
    this.actualDeliveryDate,
    required this.totalWeight,
    required this.totalQuantity,
    this.notes,
    this.proofOfDeliveryUrl,
    this.recipientName,
    this.recipientSignature,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert from JSON to Model
  factory ShipmentModel.fromJson(Map<String, dynamic> json) {
    return ShipmentModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      driverId: json['driver_id'] as String?,
      driverName: json['driver_name'] as String?,
      vehiclePlate: json['vehicle_plate'] as String?,
      status: json['status'] as String,
      pickupAddress: json['pickup_address'] as String,
      deliveryAddress: json['delivery_address'] as String,
      pickupLatitude: json['pickup_latitude'] != null
          ? (json['pickup_latitude'] as num).toDouble()
          : null,
      pickupLongitude: json['pickup_longitude'] != null
          ? (json['pickup_longitude'] as num).toDouble()
          : null,
      deliveryLatitude: json['delivery_latitude'] != null
          ? (json['delivery_latitude'] as num).toDouble()
          : null,
      deliveryLongitude: json['delivery_longitude'] != null
          ? (json['delivery_longitude'] as num).toDouble()
          : null,
      scheduledPickupDate: json['scheduled_pickup_date'] != null
          ? DateTime.parse(json['scheduled_pickup_date'] as String)
          : null,
      actualPickupDate: json['actual_pickup_date'] != null
          ? DateTime.parse(json['actual_pickup_date'] as String)
          : null,
      estimatedDeliveryDate: json['estimated_delivery_date'] != null
          ? DateTime.parse(json['estimated_delivery_date'] as String)
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
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert from Model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'driver_id': driverId,
      'driver_name': driverName,
      'vehicle_plate': vehiclePlate,
      'status': status,
      'pickup_address': pickupAddress,
      'delivery_address': deliveryAddress,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'delivery_latitude': deliveryLatitude,
      'delivery_longitude': deliveryLongitude,
      'scheduled_pickup_date': scheduledPickupDate?.toIso8601String(),
      'actual_pickup_date': actualPickupDate?.toIso8601String(),
      'estimated_delivery_date': estimatedDeliveryDate?.toIso8601String(),
      'actual_delivery_date': actualDeliveryDate?.toIso8601String(),
      'total_weight': totalWeight,
      'total_quantity': totalQuantity,
      'notes': notes,
      'proof_of_delivery_url': proofOfDeliveryUrl,
      'recipient_name': recipientName,
      'recipient_signature': recipientSignature,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert Model to Domain Entity
  Shipment toDomain() {
    return Shipment(
      id: id,
      orderId: orderId,
      driverId: driverId,
      driverName: driverName,
      vehiclePlate: vehiclePlate,
      status: status,
      pickupAddress: pickupAddress,
      deliveryAddress: deliveryAddress,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
      scheduledPickupDate: scheduledPickupDate,
      actualPickupDate: actualPickupDate,
      estimatedDeliveryDate: estimatedDeliveryDate,
      actualDeliveryDate: actualDeliveryDate,
      totalWeight: totalWeight,
      totalQuantity: totalQuantity,
      notes: notes,
      proofOfDeliveryUrl: proofOfDeliveryUrl,
      recipientName: recipientName,
      recipientSignature: recipientSignature,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert Domain Entity to Model
  factory ShipmentModel.fromDomain(Shipment shipment) {
    return ShipmentModel(
      id: shipment.id,
      orderId: shipment.orderId,
      driverId: shipment.driverId,
      driverName: shipment.driverName,
      vehiclePlate: shipment.vehiclePlate,
      status: shipment.status,
      pickupAddress: shipment.pickupAddress,
      deliveryAddress: shipment.deliveryAddress,
      pickupLatitude: shipment.pickupLatitude,
      pickupLongitude: shipment.pickupLongitude,
      deliveryLatitude: shipment.deliveryLatitude,
      deliveryLongitude: shipment.deliveryLongitude,
      scheduledPickupDate: shipment.scheduledPickupDate,
      actualPickupDate: shipment.actualPickupDate,
      estimatedDeliveryDate: shipment.estimatedDeliveryDate,
      actualDeliveryDate: shipment.actualDeliveryDate,
      totalWeight: shipment.totalWeight,
      totalQuantity: shipment.totalQuantity,
      notes: shipment.notes,
      proofOfDeliveryUrl: shipment.proofOfDeliveryUrl,
      recipientName: shipment.recipientName,
      recipientSignature: shipment.recipientSignature,
      createdAt: shipment.createdAt,
      updatedAt: shipment.updatedAt,
    );
  }

  ShipmentModel copyWith({
    String? id,
    String? orderId,
    String? driverId,
    String? driverName,
    String? vehiclePlate,
    String? status,
    String? pickupAddress,
    String? deliveryAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    double? deliveryLatitude,
    double? deliveryLongitude,
    DateTime? scheduledPickupDate,
    DateTime? actualPickupDate,
    DateTime? estimatedDeliveryDate,
    DateTime? actualDeliveryDate,
    double? totalWeight,
    int? totalQuantity,
    String? notes,
    String? proofOfDeliveryUrl,
    String? recipientName,
    String? recipientSignature,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShipmentModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      status: status ?? this.status,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      deliveryLatitude: deliveryLatitude ?? this.deliveryLatitude,
      deliveryLongitude: deliveryLongitude ?? this.deliveryLongitude,
      scheduledPickupDate: scheduledPickupDate ?? this.scheduledPickupDate,
      actualPickupDate: actualPickupDate ?? this.actualPickupDate,
      estimatedDeliveryDate:
          estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      actualDeliveryDate: actualDeliveryDate ?? this.actualDeliveryDate,
      totalWeight: totalWeight ?? this.totalWeight,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      notes: notes ?? this.notes,
      proofOfDeliveryUrl: proofOfDeliveryUrl ?? this.proofOfDeliveryUrl,
      recipientName: recipientName ?? this.recipientName,
      recipientSignature: recipientSignature ?? this.recipientSignature,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
