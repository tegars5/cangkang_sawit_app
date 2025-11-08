import 'user_profile.dart';
import 'order.dart';

/// Model untuk Shipment (Pengiriman)
class Shipment {
  final String id;
  final String orderId;
  final String driverId;
  final String deliveryNoteNumber;
  final String? deliveryNoteUrl;
  final String? deliveryPhotoUrl;
  final DateTime? pickupDate;
  final DateTime? deliveryDate;
  final String status;
  final String? destinationAddress;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Relasi
  final UserProfile? driver;
  final Order? order;

  const Shipment({
    required this.id,
    required this.orderId,
    required this.driverId,
    required this.deliveryNoteNumber,
    this.deliveryNoteUrl,
    this.deliveryPhotoUrl,
    this.pickupDate,
    this.deliveryDate,
    required this.status,
    this.destinationAddress,
    this.notes,
    required this.createdAt,
    this.updatedAt,
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
      deliveryPhotoUrl: json['delivery_photo_url'] as String?,
          ? DateTime.parse(json['pickup_date'] as String)
          : null,
      deliveryDate: json['delivery_date'] != null
          ? DateTime.parse(json['delivery_date'] as String)
          : null,
      status: json['status'] as String,
      destinationAddress: json['destination_address'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
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
      'delivery_photo_url': deliveryPhotoUrl,
      'pickup_date': pickupDate?.toIso8601String(),
      'delivery_date': deliveryDate?.toIso8601String(),
      'status': status,
      'destination_address': destinationAddress,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Helper method untuk mendapatkan nama driver
  String get driverName => driver?.fullName ?? 'Unknown Driver';

  /// Helper method untuk mendapatkan nomor pesanan
  String get orderNumber => order?.orderNumber ?? 'Unknown Order';

  /// Helper method untuk cek apakah pengiriman bisa dimulai
  bool get canStart => status == 'assigned';

  /// Helper method untuk cek apakah pengiriman sedang dalam perjalanan
  bool get inProgress => status == 'picked_up';

  /// Helper method untuk cek apakah pengiriman sudah selesai
  bool get isCompleted => status == 'delivered';

  /// Helper method untuk cek apakah ada delivery note
  bool get hasDeliveryNote => deliveryNoteUrl != null && deliveryNoteUrl!.isNotEmpty;

  /// Helper method untuk cek apakah ada bukti kirim
  bool get hasDeliveryPhoto => deliveryPhotoUrl != null && deliveryPhotoUrl!.isNotEmpty;

  /// Helper method untuk format tanggal pickup
  String get formattedPickupDate {
    if (pickupDate == null) return '-';
    return _formatDateTime(pickupDate!);
  }

  /// Helper method untuk format tanggal delivery
  String get formattedDeliveryDate {
    if (deliveryDate == null) return '-';
    return _formatDateTime(deliveryDate!);
  }

  /// Helper method untuk format durasi pengiriman
  String get durasiPengiriman {
    if (tanggalKirim == null || tanggalTiba == null) return '-';

    final duration = tanggalTiba!.difference(tanggalKirim!);
    if (duration.inDays > 0) {
      return '${duration.inDays} hari ${duration.inHours % 24} jam';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} jam ${duration.inMinutes % 60} menit';
    } else {
      return '${duration.inMinutes} menit';
    }
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
    String? deliveryPhotoUrl,
    DateTime? pickupDate,
    DateTime? deliveryDate,
    String? status,
    String? destinationAddress,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserProfile? driver,
    Order? order,
  }) {
    return Shipment(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      driverId: driverId ?? this.driverId,
      deliveryNoteNumber: deliveryNoteNumber ?? this.deliveryNoteNumber,
      deliveryNoteUrl: deliveryNoteUrl ?? this.deliveryNoteUrl,
      deliveryPhotoUrl: deliveryPhotoUrl ?? this.deliveryPhotoUrl,
      pickupDate: pickupDate ?? this.pickupDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      status: status ?? this.status,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
