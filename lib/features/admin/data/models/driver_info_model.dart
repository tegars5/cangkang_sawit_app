import '../../domain/entities/driver_info.dart';

/// Driver Information Model
/// Data transfer object for driver information
class DriverInfoModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? vehicleNumber;
  final String? vehicleType;
  final bool isActive;
  final int completedDeliveries;
  final int activeDeliveries;
  final double? rating;
  final DateTime? lastActive;
  final DateTime joinedDate;
  final String? currentLocation;
  final double? latitude;
  final double? longitude;

  DriverInfoModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.vehicleNumber,
    this.vehicleType,
    required this.isActive,
    required this.completedDeliveries,
    required this.activeDeliveries,
    this.rating,
    this.lastActive,
    required this.joinedDate,
    this.currentLocation,
    this.latitude,
    this.longitude,
  });

  factory DriverInfoModel.fromJson(Map<String, dynamic> json) {
    return DriverInfoModel(
      id: json['id'] as String,
      name: json['full_name'] as String? ?? json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      vehicleNumber: json['vehicle_number'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      isActive: json['is_active'] as bool? ?? false,
      completedDeliveries: json['completed_deliveries'] as int? ?? 0,
      activeDeliveries: json['active_deliveries'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble(),
      lastActive: json['last_active'] != null
          ? DateTime.parse(json['last_active'] as String)
          : null,
      joinedDate: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      currentLocation: json['current_location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': name,
      'email': email,
      'phone': phone,
      'vehicle_number': vehicleNumber,
      'vehicle_type': vehicleType,
      'is_active': isActive,
      'completed_deliveries': completedDeliveries,
      'active_deliveries': activeDeliveries,
      'rating': rating,
      'last_active': lastActive?.toIso8601String(),
      'created_at': joinedDate.toIso8601String(),
      'current_location': currentLocation,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  DriverInfo toDomain() {
    return DriverInfo(
      id: id,
      name: name,
      email: email,
      phone: phone,
      vehicleNumber: vehicleNumber,
      vehicleType: vehicleType,
      isActive: isActive,
      completedDeliveries: completedDeliveries,
      activeDeliveries: activeDeliveries,
      rating: rating,
      lastActive: lastActive,
      joinedDate: joinedDate,
      currentLocation: currentLocation,
      latitude: latitude,
      longitude: longitude,
    );
  }

  factory DriverInfoModel.fromDomain(DriverInfo entity) {
    return DriverInfoModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      vehicleNumber: entity.vehicleNumber,
      vehicleType: entity.vehicleType,
      isActive: entity.isActive,
      completedDeliveries: entity.completedDeliveries,
      activeDeliveries: entity.activeDeliveries,
      rating: entity.rating,
      lastActive: entity.lastActive,
      joinedDate: entity.joinedDate,
      currentLocation: entity.currentLocation,
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }
}
