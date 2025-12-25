// Import for math functions
import 'dart:math';

/// Domain entity for driver location tracking - Pure business logic
class DriverLocation {
  final String id;
  final String driverId;
  final String? shipmentId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final double? heading;
  final DateTime timestamp;
  final DateTime createdAt;

  const DriverLocation({
    required this.id,
    required this.driverId,
    this.shipmentId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    required this.timestamp,
    required this.createdAt,
  });

  // Business logic methods

  /// Check if location is recent (within last 5 minutes)
  bool isRecent() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference.inMinutes <= 5;
  }

  /// Check if location is stale (more than 30 minutes old)
  bool isStale() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference.inMinutes > 30;
  }

  /// Check if location has high accuracy (< 10 meters)
  bool hasHighAccuracy() {
    return accuracy != null && accuracy! < 10;
  }

  /// Check if driver is moving (speed > 1 km/h)
  bool isMoving() {
    return speed != null && speed! > 0.28; // 0.28 m/s = ~1 km/h
  }

  /// Get time ago string
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} detik yang lalu';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else {
      return '${difference.inDays} hari yang lalu';
    }
  }

  /// Get formatted speed in km/h
  String getFormattedSpeed() {
    if (speed == null) return 'N/A';
    final kmh = speed! * 3.6; // Convert m/s to km/h
    return '${kmh.toStringAsFixed(1)} km/h';
  }

  /// Get direction text from heading
  String getDirectionText() {
    if (heading == null) return 'N/A';

    if (heading! >= 337.5 || heading! < 22.5) return 'Utara';
    if (heading! >= 22.5 && heading! < 67.5) return 'Timur Laut';
    if (heading! >= 67.5 && heading! < 112.5) return 'Timur';
    if (heading! >= 112.5 && heading! < 157.5) return 'Tenggara';
    if (heading! >= 157.5 && heading! < 202.5) return 'Selatan';
    if (heading! >= 202.5 && heading! < 247.5) return 'Barat Daya';
    if (heading! >= 247.5 && heading! < 292.5) return 'Barat';
    return 'Barat Laut';
  }

  /// Calculate distance to another location in meters
  double distanceTo(DriverLocation other) {
    const double earthRadius = 6371000; // meters

    final lat1 = latitude * pi / 180;
    final lat2 = other.latitude * pi / 180;
    final deltaLat = (other.latitude - latitude) * pi / 180;
    final deltaLng = (other.longitude - longitude) * pi / 180;

    final a =
        sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLng / 2) * sin(deltaLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  // Copy with method for immutability
  DriverLocation copyWith({
    String? id,
    String? driverId,
    String? shipmentId,
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    DateTime? timestamp,
    DateTime? createdAt,
  }) {
    return DriverLocation(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      shipmentId: shipmentId ?? this.shipmentId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DriverLocation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
