import 'package:equatable/equatable.dart';

/// Order Summary Entity
/// Pure domain entity representing a summary of order for mitra view
class OrderSummary extends Equatable {
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

  const OrderSummary({
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

  // Business Methods

  /// Check if order is pending
  bool isPending() => status == 'pending';

  /// Check if order is confirmed
  bool isConfirmed() => status == 'confirmed';

  /// Check if order is shipped
  bool isShipped() => status == 'shipped';

  /// Check if order is delivered/completed
  bool isDelivered() => status == 'completed' || status == 'delivered';

  /// Check if order is cancelled
  bool isCancelled() => status == 'cancelled';

  /// Check if order can be tracked (has tracking number and driver)
  bool canBeTracked() => trackingNumber != null && driverName != null;

  /// Check if order has location data
  bool hasLocation() => latitude != null && longitude != null;

  /// Check if order is active (not completed or cancelled)
  bool isActive() => !isDelivered() && !isCancelled();

  /// Get status text in Indonesian
  String getStatusText() {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'shipped':
      case 'in_transit':
        return 'Dalam Pengiriman';
      case 'completed':
      case 'delivered':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  /// Get status color indicator
  String getStatusColor() {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'orange';
      case 'confirmed':
        return 'blue';
      case 'shipped':
      case 'in_transit':
        return 'purple';
      case 'completed':
      case 'delivered':
        return 'green';
      case 'cancelled':
        return 'red';
      default:
        return 'grey';
    }
  }

  /// Get estimated delivery time text
  String? getEstimatedDeliveryText() {
    if (shippedDate == null) return null;

    // Estimate 3-5 days delivery
    final estimatedDate = shippedDate!.add(const Duration(days: 4));
    final now = DateTime.now();

    if (now.isAfter(estimatedDate)) {
      return 'Estimasi terlewat';
    }

    final daysLeft = estimatedDate.difference(now).inDays;
    if (daysLeft == 0) {
      return 'Hari ini';
    } else if (daysLeft == 1) {
      return 'Besok';
    } else {
      return '$daysLeft hari lagi';
    }
  }

  /// Get order age in days
  int getOrderAgeInDays() {
    final now = DateTime.now();
    return now.difference(orderDate).inDays;
  }

  /// Check if order is new (less than 7 days old)
  bool isNew() => getOrderAgeInDays() <= 7;

  /// Get processing time in days (from order to confirmed)
  int? getProcessingTimeInDays() {
    if (confirmedDate == null) return null;
    return confirmedDate!.difference(orderDate).inDays;
  }

  /// Get shipping time in days (from confirmed to delivered)
  int? getShippingTimeInDays() {
    if (confirmedDate == null || deliveredDate == null) return null;
    return deliveredDate!.difference(confirmedDate!).inDays;
  }

  /// Get total time in days (from order to delivered)
  int? getTotalTimeInDays() {
    if (deliveredDate == null) return null;
    return deliveredDate!.difference(orderDate).inDays;
  }

  /// Check if order was delivered on time (within 7 days)
  bool? wasDeliveredOnTime() {
    final totalTime = getTotalTimeInDays();
    if (totalTime == null) return null;
    return totalTime <= 7;
  }

  /// Get next action text for mitra
  String getNextActionText() {
    if (isPending()) return 'Menunggu konfirmasi admin';
    if (isConfirmed()) return 'Sedang diproses';
    if (isShipped()) return 'Lacak pengiriman';
    if (isDelivered()) return 'Pesanan selesai';
    if (isCancelled()) return 'Pesanan dibatalkan';
    return 'Lihat detail';
  }

  /// Validate order summary data
  bool validate() {
    if (id.isEmpty) return false;
    if (orderNumber.isEmpty) return false;
    if (status.isEmpty) return false;
    if (totalAmount < 0) return false;
    if (totalItems <= 0) return false;
    return true;
  }

  OrderSummary copyWith({
    String? id,
    String? orderNumber,
    String? status,
    DateTime? orderDate,
    DateTime? confirmedDate,
    DateTime? shippedDate,
    DateTime? deliveredDate,
    double? totalAmount,
    int? totalItems,
    String? notes,
    String? driverName,
    String? driverPhone,
    String? trackingNumber,
    String? deliveryAddress,
    double? latitude,
    double? longitude,
  }) {
    return OrderSummary(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      confirmedDate: confirmedDate ?? this.confirmedDate,
      shippedDate: shippedDate ?? this.shippedDate,
      deliveredDate: deliveredDate ?? this.deliveredDate,
      totalAmount: totalAmount ?? this.totalAmount,
      totalItems: totalItems ?? this.totalItems,
      notes: notes ?? this.notes,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [
    id,
    orderNumber,
    status,
    orderDate,
    confirmedDate,
    shippedDate,
    deliveredDate,
    totalAmount,
    totalItems,
    notes,
    driverName,
    driverPhone,
    trackingNumber,
    deliveryAddress,
    latitude,
    longitude,
  ];
}
