import 'dart:math';

/// Model untuk Driver Location (Lokasi GPS Driver) - driver_locations table
class DriverLocation {
  final String id; // UUID primary key
  final String driverId; // Foreign key to profiles
  final String? shipmentId; // Foreign key to shipments
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

  factory DriverLocation.fromJson(Map<String, dynamic> json) {
    return DriverLocation(
      id: json['id'] as String,
      driverId: json['driver_id'] as String,
      shipmentId: json['shipment_id'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: json['accuracy'] != null
          ? (json['accuracy'] as num).toDouble()
          : null,
      altitude: json['altitude'] != null
          ? (json['altitude'] as num).toDouble()
          : null,
      speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
      heading: json['heading'] != null
          ? (json['heading'] as num).toDouble()
          : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'shipment_id': shipmentId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Helper method untuk format koordinat
  String get coordinates => '$latitude, $longitude';

  /// Format coordinates untuk display
  String get formattedCoordinates =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  /// Helper method untuk format waktu
  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  /// Helper method untuk format tanggal waktu lengkap
  String get formattedDateTime {
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

    final day = timestamp.day.toString().padLeft(2, '0');
    final month = months[timestamp.month - 1];
    final year = timestamp.year.toString();

    return '$day $month $year $formattedTime';
  }

  /// Helper method untuk format kecepatan
  String get formattedSpeed {
    if (speed == null) return '-';
    return '${speed!.toStringAsFixed(1)} km/h';
  }

  /// Helper method untuk format akurasi
  String get formattedAccuracy {
    if (accuracy == null) return '-';
    return '±${accuracy!.toStringAsFixed(1)}m';
  }

  /// Helper method untuk cek apakah lokasi masih fresh (dalam 5 menit)
  bool get isFresh {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference.inMinutes <= 5;
  }

  /// Alias untuk isFresh - cek apakah lokasi masih recent
  bool get isRecent => isFresh;

  /// Helper method untuk format heading sebagai arah mata angin
  String get formattedHeading {
    if (heading == null) return '-';

    // Konversi heading (0-360 derajat) ke arah mata angin
    const directions = ['U', 'TL', 'T', 'TG', 'S', 'BD', 'B', 'BL'];
    final index = ((heading! + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  /// Helper method untuk format altitude
  String get formattedAltitude {
    if (altitude == null) return 'N/A';
    return '${altitude!.toStringAsFixed(1)} m';
  }

  /// Helper method untuk menghitung jarak ke koordinat lain (dalam meter)
  /// Menggunakan formula Haversine
  double distanceTo(double lat2, double lon2) {
    const double earthRadius = 6371000; // radius bumi dalam meter

    final double lat1Rad = latitude * (pi / 180);
    final double lat2Rad = lat2 * (pi / 180);
    final double deltaLatRad = (lat2 - latitude) * (pi / 180);
    final double deltaLonRad = (lon2 - longitude) * (pi / 180);

    final double a =
        sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) *
            cos(lat2Rad) *
            sin(deltaLonRad / 2) *
            sin(deltaLonRad / 2);

    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

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
  String toString() {
    return 'DriverLocation(id: $id, driverId: $driverId, coordinates: $formattedCoordinates, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DriverLocation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Extension untuk operasi matematika pada DriverLocation
extension DriverLocationMath on DriverLocation {
  /// Konversi derajat ke radian
  double get latitudeRad => latitude * (pi / 180);
  double get longitudeRad => longitude * (pi / 180);
}
