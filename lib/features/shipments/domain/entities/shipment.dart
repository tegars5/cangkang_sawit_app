import 'package:equatable/equatable.dart';

/// Shipment entity representing a delivery shipment in the domain layer
///
/// This is a pure business entity with no framework dependencies.
/// Contains all business logic related to shipment operations.
class Shipment extends Equatable {
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

  // Order relation data (from joined query)
  final Map<String, dynamic>? orderData;

  // Computed/Helper properties
  String? get order => null; // Placeholder, should be populated from repository
  DateTime? get completedAt => actualDeliveryDate;
  DateTime? get startedAt => actualPickupDate;
  double? get destinationLat => deliveryLatitude;
  double? get destinationLng => deliveryLongitude;
  String? get destinationAddress => deliveryAddress;
  String? get deliveryNoteNumber => id; // Using id as delivery note number

  // Additional helper properties for driver feature compatibility
  DateTime? get scheduledDeliveryDate => estimatedDeliveryDate;
  DateTime? get pickupDate => scheduledPickupDate; // Alias for scheduled pickup
  String? get priority => null; // Can be extended later if needed

  // Check if shipment has location data
  bool hasLocation() {
    return deliveryLatitude != null && deliveryLongitude != null;
  }

  // Customer info from order relation
  String get customerName {
    if (orderData == null) return 'Customer';
    final profiles = orderData!['profiles'];
    if (profiles is Map) {
      return profiles['full_name'] as String? ?? 'Customer';
    }
    return 'Customer';
  }

  String get customerPhone {
    if (orderData == null) return '-';
    final profiles = orderData!['profiles'];
    if (profiles is Map) {
      return profiles['phone'] as String? ?? '-';
    }
    return '-';
  }

  // Constructor
  const Shipment({
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
    this.orderData,
  });

  /// Create Shipment from JSON map
  factory Shipment.fromJson(Map<String, dynamic> json) {
    return Shipment(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      driverId: json['driver_id'] as String?,
      driverName: json['driver_name'] as String?,
      vehiclePlate: json['vehicle_plate'] as String?,
      status: json['status'] as String,
      pickupAddress: json['pickup_address'] as String,
      deliveryAddress: json['delivery_address'] as String,
      pickupLatitude: (json['pickup_latitude'] as num?)?.toDouble(),
      pickupLongitude: (json['pickup_longitude'] as num?)?.toDouble(),
      deliveryLatitude: (json['delivery_latitude'] as num?)?.toDouble(),
      deliveryLongitude: (json['delivery_longitude'] as num?)?.toDouble(),
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
      orderData: json['orders'] as Map<String, dynamic>?,
    );
  }

  /// Convert Shipment to JSON map
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

  @override
  List<Object?> get props => [
    id,
    orderId,
    driverId,
    driverName,
    vehiclePlate,
    status,
    pickupAddress,
    deliveryAddress,
    pickupLatitude,
    pickupLongitude,
    deliveryLatitude,
    deliveryLongitude,
    scheduledPickupDate,
    actualPickupDate,
    estimatedDeliveryDate,
    actualDeliveryDate,
    totalWeight,
    totalQuantity,
    notes,
    proofOfDeliveryUrl,
    recipientName,
    recipientSignature,
    createdAt,
    updatedAt,
  ];

  // Business logic methods

  /// Check if shipment is pending assignment
  bool isPending() => status == ShipmentStatus.pending;

  /// Check if driver is assigned
  bool isAssigned() => status == ShipmentStatus.assigned && driverId != null;

  /// Check if shipment is in transit
  bool isInTransit() => status == ShipmentStatus.inTransit;

  /// Check if shipment is delivered
  bool isDelivered() => status == ShipmentStatus.delivered;

  /// Check if shipment is cancelled
  bool isCancelled() => status == ShipmentStatus.cancelled;

  /// Check if driver can be assigned
  bool canAssignDriver() =>
      isPending() || (status == ShipmentStatus.assigned && driverId == null);

  /// Check if shipment can be picked up
  bool canPickup() => isAssigned() && actualPickupDate == null;

  /// Check if shipment can be delivered
  bool canDeliver() => isInTransit() && actualDeliveryDate == null;

  /// Check if shipment can be cancelled
  bool canCancel() => isPending() || isAssigned() && actualPickupDate == null;

  /// Check if proof of delivery is required
  bool requiresProofOfDelivery() => isDelivered() && proofOfDeliveryUrl == null;

  /// Check if shipment has location coordinates
  bool hasPickupLocation() => pickupLatitude != null && pickupLongitude != null;

  bool hasDeliveryLocation() =>
      deliveryLatitude != null && deliveryLongitude != null;

  /// Check if shipment is on schedule
  bool isOnSchedule() {
    if (scheduledPickupDate == null) return true;
    if (actualPickupDate != null) {
      return actualPickupDate!.isBefore(scheduledPickupDate!) ||
          actualPickupDate!.isAtSameMomentAs(scheduledPickupDate!);
    }
    return DateTime.now().isBefore(scheduledPickupDate!);
  }

  /// Check if shipment is delayed
  bool isDelayed() => !isOnSchedule();

  /// Get estimated delivery duration in hours
  int? getEstimatedDurationHours() {
    if (scheduledPickupDate == null || estimatedDeliveryDate == null) {
      return null;
    }
    return estimatedDeliveryDate!.difference(scheduledPickupDate!).inHours;
  }

  /// Get actual delivery duration in hours
  int? getActualDurationHours() {
    if (actualPickupDate == null || actualDeliveryDate == null) {
      return null;
    }
    return actualDeliveryDate!.difference(actualPickupDate!).inHours;
  }

  /// Calculate delay in hours (negative means early)
  int? getDelayHours() {
    if (estimatedDeliveryDate == null || actualDeliveryDate == null) {
      return null;
    }
    return actualDeliveryDate!.difference(estimatedDeliveryDate!).inHours;
  }

  /// Get status badge color
  String getStatusColor() {
    switch (status) {
      case ShipmentStatus.pending:
        return '#FFA726'; // Orange
      case ShipmentStatus.assigned:
        return '#42A5F5'; // Blue
      case ShipmentStatus.inTransit:
        return '#66BB6A'; // Green
      case ShipmentStatus.delivered:
        return '#26A69A'; // Teal
      case ShipmentStatus.cancelled:
        return '#EF5350'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Get status display text
  String getStatusText() {
    switch (status) {
      case ShipmentStatus.pending:
        return 'Menunggu Driver';
      case ShipmentStatus.assigned:
        return 'Driver Ditugaskan';
      case ShipmentStatus.inTransit:
        return 'Dalam Perjalanan';
      case ShipmentStatus.delivered:
        return 'Terkirim';
      case ShipmentStatus.cancelled:
        return 'Dibatalkan';
      default:
        return 'Unknown';
    }
  }

  /// Get next possible actions based on current status
  List<String> getAvailableActions() {
    final actions = <String>[];

    if (canAssignDriver()) actions.add('assign_driver');
    if (canPickup()) actions.add('pickup');
    if (canDeliver()) actions.add('deliver');
    if (canCancel()) actions.add('cancel');
    if (isInTransit() || isDelivered()) actions.add('track');

    return actions;
  }

  /// Check if shipment is editable
  bool isEditable() => isPending() || isAssigned();

  /// Validate shipment data
  List<String> validate() {
    final errors = <String>[];

    if (orderId.isEmpty) errors.add('Order ID is required');
    if (pickupAddress.isEmpty) errors.add('Pickup address is required');
    if (deliveryAddress.isEmpty) errors.add('Delivery address is required');
    if (totalWeight <= 0) errors.add('Total weight must be greater than 0');
    if (totalQuantity <= 0) errors.add('Total quantity must be greater than 0');

    if (status == ShipmentStatus.assigned && driverId == null) {
      errors.add('Driver must be assigned for assigned status');
    }

    if (status == ShipmentStatus.inTransit && actualPickupDate == null) {
      errors.add('Actual pickup date required for in-transit status');
    }

    if (status == ShipmentStatus.delivered) {
      if (actualPickupDate == null) {
        errors.add('Actual pickup date required for delivered status');
      }
      if (actualDeliveryDate == null) {
        errors.add('Actual delivery date required for delivered status');
      }
    }

    return errors;
  }

  /// Create a copy with updated fields
  Shipment copyWith({
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
    return Shipment(
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

/// Shipment status constants
abstract class ShipmentStatus {
  static const String pending = 'pending';
  static const String assigned = 'assigned';
  static const String inTransit = 'in_transit';
  static const String delivered = 'delivered';
  static const String cancelled = 'cancelled';

  static const List<String> all = [
    pending,
    assigned,
    inTransit,
    delivered,
    cancelled,
  ];

  static bool isValid(String status) => all.contains(status);
}
