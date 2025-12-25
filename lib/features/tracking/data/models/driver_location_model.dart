import '../../domain/entities/driver_location.dart' as entity;

/// Data model for DriverLocation with JSON serialization
class DriverLocationModel extends entity.DriverLocation {
  const DriverLocationModel({
    required super.id,
    required super.driverId,
    super.shipmentId,
    required super.latitude,
    required super.longitude,
    super.accuracy,
    super.altitude,
    super.speed,
    super.heading,
    required super.timestamp,
    required super.createdAt,
  });

  factory DriverLocationModel.fromJson(Map<String, dynamic> json) {
    return DriverLocationModel(
      id: json['id'] as String,
      driverId: json['driver_id'] as String,
      shipmentId: json['shipment_id'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      accuracy: json['accuracy'] != null
          ? (json['accuracy'] as num?)?.toDouble()
          : null,
      altitude: json['altitude'] != null
          ? (json['altitude'] as num?)?.toDouble()
          : null,
      speed: json['speed'] != null ? (json['speed'] as num?)?.toDouble() : null,
      heading: json['heading'] != null
          ? (json['heading'] as num?)?.toDouble()
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

  /// Convert to domain entity
  entity.DriverLocation toDomain() {
    return entity.DriverLocation(
      id: id,
      driverId: driverId,
      shipmentId: shipmentId,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      altitude: altitude,
      speed: speed,
      heading: heading,
      timestamp: timestamp,
      createdAt: createdAt,
    );
  }

  /// Create from domain entity
  factory DriverLocationModel.fromDomain(entity.DriverLocation location) {
    return DriverLocationModel(
      id: location.id,
      driverId: location.driverId,
      shipmentId: location.shipmentId,
      latitude: location.latitude,
      longitude: location.longitude,
      accuracy: location.accuracy,
      altitude: location.altitude,
      speed: location.speed,
      heading: location.heading,
      timestamp: location.timestamp,
      createdAt: location.createdAt,
    );
  }

  @override
  DriverLocationModel copyWith({
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
    return DriverLocationModel(
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
}
