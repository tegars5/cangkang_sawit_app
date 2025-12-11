/// Model for shipment timeline updates
/// Represents status changes and events during shipment delivery
class ShipmentTimeline {
  final String id;
  final String shipmentId;
  final String status;
  final String message;
  final double? locationLat;
  final double? locationLng;
  final DateTime createdAt;

  const ShipmentTimeline({
    required this.id,
    required this.shipmentId,
    required this.status,
    required this.message,
    this.locationLat,
    this.locationLng,
    required this.createdAt,
  });

  factory ShipmentTimeline.fromJson(Map<String, dynamic> json) {
    return ShipmentTimeline(
      id: json['id'] as String,
      shipmentId: json['shipment_id'] as String,
      status: json['status'] as String,
      message: json['message'] as String,
      locationLat: json['location_lat'] != null
          ? (json['location_lat'] as num).toDouble()
          : null,
      locationLng: json['location_lng'] != null
          ? (json['location_lng'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shipment_id': shipmentId,
      'status': status,
      'message': message,
      'location_lat': locationLat,
      'location_lng': locationLng,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Get formatted time (e.g., "10:30")
  String get formattedTime {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get formatted date (e.g., "10 Des 2024")
  String get formattedDate {
    const months = [
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
    final day = createdAt.day;
    final month = months[createdAt.month - 1];
    final year = createdAt.year;
    return '$day $month $year';
  }

  /// Get status icon based on status
  String get statusIcon {
    switch (status.toLowerCase()) {
      case 'assigned':
        return '📋';
      case 'picked_up':
        return '📦';
      case 'in_transit':
        return '🚚';
      case 'arrived':
        return '📍';
      case 'delivered':
      case 'completed':
        return '✅';
      default:
        return '📌';
    }
  }

  /// Get status color
  int get statusColor {
    switch (status.toLowerCase()) {
      case 'assigned':
        return 0xFF2196F3; // Blue
      case 'picked_up':
        return 0xFFFF9800; // Orange
      case 'in_transit':
        return 0xFF9C27B0; // Purple
      case 'arrived':
        return 0xFFFFEB3B; // Yellow
      case 'delivered':
      case 'completed':
        return 0xFF4CAF50; // Green
      default:
        return 0xFF757575; // Grey
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShipmentTimeline && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ShipmentTimeline(id: $id, status: $status, message: $message)';
  }
}
