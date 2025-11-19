import 'user_profile.dart';
import 'shipment.dart';

/// Model untuk Delivery (Pengiriman Detail) - deliveries table
class Delivery {
  final String id; // UUID primary key
  final String? shipmentId; // Foreign key to shipments
  final String? driverId; // Foreign key to profiles
  final String status; // pending, completed
  final DateTime? pickupTime;
  final DateTime? deliveryTime;
  final String? pickupSignature;
  final String? deliverySignature;
  final String? pickupPhoto;
  final String? deliveryPhoto;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Relasi
  final Shipment? shipment;
  final UserProfile? driver;

  const Delivery({
    required this.id,
    this.shipmentId,
    this.driverId,
    required this.status,
    this.pickupTime,
    this.deliveryTime,
    this.pickupSignature,
    this.deliverySignature,
    this.pickupPhoto,
    this.deliveryPhoto,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.shipment,
    this.driver,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] as String,
      shipmentId: json['shipment_id'] as String?,
      driverId: json['driver_id'] as String?,
      status: json['status'] as String,
      pickupTime: json['pickup_time'] != null
          ? DateTime.parse(json['pickup_time'] as String)
          : null,
      deliveryTime: json['delivery_time'] != null
          ? DateTime.parse(json['delivery_time'] as String)
          : null,
      pickupSignature: json['pickup_signature'] as String?,
      deliverySignature: json['delivery_signature'] as String?,
      pickupPhoto: json['pickup_photo'] as String?,
      deliveryPhoto: json['delivery_photo'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      shipment: json['shipments'] != null
          ? Shipment.fromJson(json['shipments'] as Map<String, dynamic>)
          : null,
      driver: json['profiles'] != null
          ? UserProfile.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shipment_id': shipmentId,
      'driver_id': driverId,
      'status': status,
      'pickup_time': pickupTime?.toIso8601String(),
      'delivery_time': deliveryTime?.toIso8601String(),
      'pickup_signature': pickupSignature,
      'delivery_signature': deliverySignature,
      'pickup_photo': pickupPhoto,
      'delivery_photo': deliveryPhoto,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Helper method untuk mendapatkan nama driver
  String get driverName => driver?.displayName ?? 'Unknown Driver';

  /// Helper method untuk cek apakah delivery sudah selesai
  bool get isCompleted => status == 'completed';

  /// Helper method untuk cek apakah sudah ada pickup signature
  bool get hasPickupSignature =>
      pickupSignature != null && pickupSignature!.isNotEmpty;

  /// Helper method untuk cek apakah sudah ada delivery signature
  bool get hasDeliverySignature =>
      deliverySignature != null && deliverySignature!.isNotEmpty;

  /// Helper method untuk cek apakah sudah ada pickup photo
  bool get hasPickupPhoto => pickupPhoto != null && pickupPhoto!.isNotEmpty;

  /// Helper method untuk cek apakah sudah ada delivery photo
  bool get hasDeliveryPhoto =>
      deliveryPhoto != null && deliveryPhoto!.isNotEmpty;

  /// Helper method untuk format pickup time
  String get formattedPickupTime {
    if (pickupTime == null) return '-';
    return _formatDateTime(pickupTime!);
  }

  /// Helper method untuk format delivery time
  String get formattedDeliveryTime {
    if (deliveryTime == null) return '-';
    return _formatDateTime(deliveryTime!);
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = months[dateTime.month - 1];
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day $month $year $hour:$minute';
  }

  Delivery copyWith({
    String? id,
    String? shipmentId,
    String? driverId,
    String? status,
    DateTime? pickupTime,
    DateTime? deliveryTime,
    String? pickupSignature,
    String? deliverySignature,
    String? pickupPhoto,
    String? deliveryPhoto,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    Shipment? shipment,
    UserProfile? driver,
  }) {
    return Delivery(
      id: id ?? this.id,
      shipmentId: shipmentId ?? this.shipmentId,
      driverId: driverId ?? this.driverId,
      status: status ?? this.status,
      pickupTime: pickupTime ?? this.pickupTime,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      pickupSignature: pickupSignature ?? this.pickupSignature,
      deliverySignature: deliverySignature ?? this.deliverySignature,
      pickupPhoto: pickupPhoto ?? this.pickupPhoto,
      deliveryPhoto: deliveryPhoto ?? this.deliveryPhoto,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shipment: shipment ?? this.shipment,
      driver: driver ?? this.driver,
    );
  }

  @override
  String toString() {
    return 'Delivery(id: $id, status: $status, driverName: $driverName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Delivery && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
