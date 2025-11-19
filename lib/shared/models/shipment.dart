import 'user_profile.dart';
import 'order.dart';

/// Model untuk Shipment (Pengiriman) - shipments table
class Shipment {
  final String id; // UUID primary key
  final String orderId; // Foreign key to orders
  final String driverId; // Foreign key to profiles
  final String deliveryNoteNumber; // UNIQUE
  final String? deliveryNoteUrl;
  final String? proofOfDeliveryUrl;
  final String status; // pending, in_transit, arrived, completed
  final DateTime assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? estimatedArrival;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? estimatedDelivery;
  final DateTime? actualDelivery;
  final String? trackingNumber;

  // Relasi
  final UserProfile? driver;
  final Order? order;

  const Shipment({
    required this.id,
    required this.orderId,
    required this.driverId,
    required this.deliveryNoteNumber,
    this.deliveryNoteUrl,
    this.proofOfDeliveryUrl,
    required this.status,
    required this.assignedAt,
    this.startedAt,
    this.completedAt,
    this.estimatedArrival,
    required this.createdAt,
    this.updatedAt,
    this.estimatedDelivery,
    this.actualDelivery,
    this.trackingNumber,
    this.driver,
    this.order,
  });

  factory Shipment.fromJson(Map<String, dynamic> json) {
    return Shipment(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      driverId: json['driver_id'] as String,
      deliveryNoteNumber: json['delivery_note_number'] as String,
      deliveryNoteUrl: json['delivery_note_url'] as String?,
      proofOfDeliveryUrl: json['proof_of_delivery_url'] as String?,
      status: json['status'] as String,
      assignedAt: DateTime.parse(json['assigned_at'] as String),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      estimatedArrival: json['estimated_arrival'] != null
          ? DateTime.parse(json['estimated_arrival'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      estimatedDelivery: json['estimated_delivery'] != null
          ? DateTime.parse(json['estimated_delivery'] as String)
          : null,
      actualDelivery: json['actual_delivery'] != null
          ? DateTime.parse(json['actual_delivery'] as String)
          : null,
      trackingNumber: json['tracking_number'] as String?,
      driver: json['profiles'] != null
          ? UserProfile.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
      order: json['orders'] != null
          ? Order.fromJson(json['orders'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'driver_id': driverId,
      'delivery_note_number': deliveryNoteNumber,
      'delivery_note_url': deliveryNoteUrl,
      'proof_of_delivery_url': proofOfDeliveryUrl,
      'status': status,
      'assigned_at': assignedAt.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'estimated_arrival': estimatedArrival?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'estimated_delivery': estimatedDelivery?.toIso8601String(),
      'actual_delivery': actualDelivery?.toIso8601String(),
      'tracking_number': trackingNumber,
    };
  }

  /// Helper method untuk mendapatkan nama driver
  String get driverName => driver?.fullName ?? 'Unknown Driver';

  /// Helper method untuk mendapatkan nomor pesanan
  String get orderNumber => order?.orderNumber ?? 'Unknown Order';

  /// Helper method untuk cek apakah pengiriman bisa dimulai
  bool get canStart => status == 'pending';

  /// Helper method untuk cek apakah pengiriman sedang dalam perjalanan
  bool get inProgress => status == 'in_transit';

  /// Helper method untuk cek apakah pengiriman sudah tiba
  bool get hasArrived => status == 'arrived';

  /// Helper method untuk cek apakah pengiriman sudah selesai
  bool get isCompleted => status == 'completed';

  /// Helper method untuk cek apakah ada delivery note
  bool get hasDeliveryNote =>
      deliveryNoteUrl != null && deliveryNoteUrl!.isNotEmpty;

  /// Helper method untuk cek apakah ada bukti kirim
  bool get hasProofOfDelivery =>
      proofOfDeliveryUrl != null && proofOfDeliveryUrl!.isNotEmpty;

  /// Helper method untuk format tanggal mulai
  String get formattedStartedAt {
    if (startedAt == null) return '-';
    return _formatDateTime(startedAt!);
  }

  /// Helper method untuk format tanggal selesai
  String get formattedCompletedAt {
    if (completedAt == null) return '-';
    return _formatDateTime(completedAt!);
  }

  /// Helper method untuk format durasi pengiriman
  String get durasiPengiriman {
    if (startedAt == null || completedAt == null) return '-';

    final duration = completedAt!.difference(startedAt!);
    if (duration.inDays > 0) {
      return '${duration.inDays} hari ${duration.inHours % 24} jam';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} jam ${duration.inMinutes % 60} menit';
    } else {
      return '${duration.inMinutes} menit';
    }
  }

  /// Helper method untuk format estimated delivery
  String get formattedEstimatedDelivery {
    if (estimatedDelivery == null) return '-';
    return _formatDateTime(estimatedDelivery!);
  }

  /// Helper method untuk format actual delivery
  String get formattedActualDelivery {
    if (actualDelivery == null) return '-';
    return _formatDateTime(actualDelivery!);
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

  Shipment copyWith({
    String? id,
    String? orderId,
    String? driverId,
    String? deliveryNoteNumber,
    String? deliveryNoteUrl,
    String? proofOfDeliveryUrl,
    String? status,
    DateTime? assignedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? estimatedArrival,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? estimatedDelivery,
    DateTime? actualDelivery,
    String? trackingNumber,
    UserProfile? driver,
    Order? order,
  }) {
    return Shipment(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      driverId: driverId ?? this.driverId,
      deliveryNoteNumber: deliveryNoteNumber ?? this.deliveryNoteNumber,
      deliveryNoteUrl: deliveryNoteUrl ?? this.deliveryNoteUrl,
      proofOfDeliveryUrl: proofOfDeliveryUrl ?? this.proofOfDeliveryUrl,
      status: status ?? this.status,
      assignedAt: assignedAt ?? this.assignedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      actualDelivery: actualDelivery ?? this.actualDelivery,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      driver: driver ?? this.driver,
      order: order ?? this.order,
    );
  }

  @override
  String toString() {
    return 'Shipment(id: $id, deliveryNoteNumber: $deliveryNoteNumber, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Shipment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
