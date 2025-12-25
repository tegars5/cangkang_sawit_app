import 'package:equatable/equatable.dart';

/// Delivery Task entity representing a driver's delivery assignment
///
/// This is a pure business entity with no framework dependencies.
/// Contains all business logic related to delivery operations for drivers.
class DeliveryTask extends Equatable {
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

  const DeliveryTask({
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

  @override
  List<Object?> get props => [
    id,
    shipmentId,
    orderId,
    customerId,
    customerName,
    customerPhone,
    deliveryAddress,
    deliveryLatitude,
    deliveryLongitude,
    status,
    scheduledDeliveryDate,
    actualDeliveryDate,
    totalWeight,
    totalQuantity,
    notes,
    proofOfDeliveryUrl,
    recipientName,
    recipientSignature,
    pickupDate,
    isPriority,
    createdAt,
    updatedAt,
  ];

  // Business logic methods

  /// Check if task is pending (assigned but not picked up)
  bool isPending() => status == DeliveryTaskStatus.pending;

  /// Check if task is picked up (in transit)
  bool isPickedUp() => status == DeliveryTaskStatus.inTransit;

  /// Check if task is delivered
  bool isDelivered() => status == DeliveryTaskStatus.delivered;

  /// Check if task is cancelled
  bool isCancelled() => status == DeliveryTaskStatus.cancelled;

  /// Check if task can be picked up
  bool canPickup() => isPending() && pickupDate == null;

  /// Check if task can be delivered
  bool canDeliver() => isPickedUp() && actualDeliveryDate == null;

  /// Check if proof of delivery is required
  bool requiresProof() => isDelivered() && proofOfDeliveryUrl == null;

  /// Check if task has location coordinates
  bool hasLocation() => deliveryLatitude != null && deliveryLongitude != null;

  /// Check if task is overdue
  bool isOverdue() {
    if (scheduledDeliveryDate == null || isDelivered() || isCancelled()) {
      return false;
    }
    return DateTime.now().isAfter(scheduledDeliveryDate!);
  }

  /// Check if task is scheduled for today
  bool isScheduledToday() {
    if (scheduledDeliveryDate == null) return false;
    final now = DateTime.now();
    final scheduled = scheduledDeliveryDate!;
    return now.year == scheduled.year &&
        now.month == scheduled.month &&
        now.day == scheduled.day;
  }

  /// Check if task is scheduled for tomorrow
  bool isScheduledTomorrow() {
    if (scheduledDeliveryDate == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final scheduled = scheduledDeliveryDate!;
    return tomorrow.year == scheduled.year &&
        tomorrow.month == scheduled.month &&
        tomorrow.day == scheduled.day;
  }

  /// Get time until scheduled delivery
  Duration? getTimeUntilDelivery() {
    if (scheduledDeliveryDate == null) return null;
    return scheduledDeliveryDate!.difference(DateTime.now());
  }

  /// Get hours until scheduled delivery
  int? getHoursUntilDelivery() {
    final duration = getTimeUntilDelivery();
    return duration?.inHours;
  }

  /// Get delivery duration in hours (pickup to delivery)
  int? getDeliveryDurationHours() {
    if (pickupDate == null || actualDeliveryDate == null) return null;
    return actualDeliveryDate!.difference(pickupDate!).inHours;
  }

  /// Calculate delay in hours (negative means early delivery)
  int? getDelayHours() {
    if (scheduledDeliveryDate == null || actualDeliveryDate == null) {
      return null;
    }
    return actualDeliveryDate!.difference(scheduledDeliveryDate!).inHours;
  }

  /// Check if delivery was on time
  bool wasOnTime() {
    final delay = getDelayHours();
    return delay != null && delay <= 0;
  }

  /// Get status badge color
  String getStatusColor() {
    switch (status) {
      case DeliveryTaskStatus.pending:
        return '#FFA726'; // Orange
      case DeliveryTaskStatus.inTransit:
        return '#66BB6A'; // Green
      case DeliveryTaskStatus.delivered:
        return '#26A69A'; // Teal
      case DeliveryTaskStatus.cancelled:
        return '#EF5350'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Get status display text
  String getStatusText() {
    switch (status) {
      case DeliveryTaskStatus.pending:
        return 'Belum Diambil';
      case DeliveryTaskStatus.inTransit:
        return 'Dalam Perjalanan';
      case DeliveryTaskStatus.delivered:
        return 'Terkirim';
      case DeliveryTaskStatus.cancelled:
        return 'Dibatalkan';
      default:
        return 'Unknown';
    }
  }

  /// Get priority badge text
  String getPriorityText() => isPriority ? 'PRIORITAS' : '';

  /// Get next action text for driver
  String? getNextAction() {
    if (canPickup()) return 'Ambil Barang';
    if (canDeliver()) return 'Kirim Barang';
    if (requiresProof()) return 'Upload Bukti';
    return null;
  }

  /// Validate delivery task data
  List<String> validate() {
    final errors = <String>[];

    if (shipmentId.isEmpty) errors.add('Shipment ID is required');
    if (orderId.isEmpty) errors.add('Order ID is required');
    if (customerId.isEmpty) errors.add('Customer ID is required');
    if (customerName.isEmpty) errors.add('Customer name is required');
    if (customerPhone.isEmpty) errors.add('Customer phone is required');
    if (deliveryAddress.isEmpty) errors.add('Delivery address is required');
    if (totalWeight <= 0) errors.add('Total weight must be greater than 0');
    if (totalQuantity <= 0) {
      errors.add('Total quantity must be greater than 0');
    }

    if (status == DeliveryTaskStatus.inTransit && pickupDate == null) {
      errors.add('Pickup date required for in-transit status');
    }

    if (status == DeliveryTaskStatus.delivered) {
      if (pickupDate == null) {
        errors.add('Pickup date required for delivered status');
      }
      if (actualDeliveryDate == null) {
        errors.add('Delivery date required for delivered status');
      }
    }

    return errors;
  }

  /// Create a copy with updated fields
  DeliveryTask copyWith({
    String? id,
    String? shipmentId,
    String? orderId,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? deliveryAddress,
    double? deliveryLatitude,
    double? deliveryLongitude,
    String? status,
    DateTime? scheduledDeliveryDate,
    DateTime? actualDeliveryDate,
    double? totalWeight,
    int? totalQuantity,
    String? notes,
    String? proofOfDeliveryUrl,
    String? recipientName,
    String? recipientSignature,
    DateTime? pickupDate,
    bool? isPriority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeliveryTask(
      id: id ?? this.id,
      shipmentId: shipmentId ?? this.shipmentId,
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryLatitude: deliveryLatitude ?? this.deliveryLatitude,
      deliveryLongitude: deliveryLongitude ?? this.deliveryLongitude,
      status: status ?? this.status,
      scheduledDeliveryDate:
          scheduledDeliveryDate ?? this.scheduledDeliveryDate,
      actualDeliveryDate: actualDeliveryDate ?? this.actualDeliveryDate,
      totalWeight: totalWeight ?? this.totalWeight,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      notes: notes ?? this.notes,
      proofOfDeliveryUrl: proofOfDeliveryUrl ?? this.proofOfDeliveryUrl,
      recipientName: recipientName ?? this.recipientName,
      recipientSignature: recipientSignature ?? this.recipientSignature,
      pickupDate: pickupDate ?? this.pickupDate,
      isPriority: isPriority ?? this.isPriority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Delivery task status constants
abstract class DeliveryTaskStatus {
  static const String pending = 'pending';
  static const String inTransit = 'in_transit';
  static const String delivered = 'delivered';
  static const String cancelled = 'cancelled';

  static const List<String> all = [pending, inTransit, delivered, cancelled];

  static bool isValid(String status) => all.contains(status);
}
