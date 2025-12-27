import 'package:equatable/equatable.dart';

/// Domain entity for User
/// This is a pure domain object with no JSON serialization
class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final int? roleId;
  final String? roleName;
  final String? phone;
  final String? address;
  final String? city;
  final String? province;
  final String? postalCode;
  final String? avatarUrl;
  final String? companyName;
  final String? jobTitle;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Driver-specific fields
  final String? driverLicense;
  final String? vehicleType;
  final String? vehiclePlate;

  // Location fields
  final double? latitude;
  final double? longitude;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.roleId,
    this.roleName,
    this.phone,
    this.address,
    this.city,
    this.province,
    this.postalCode,
    this.avatarUrl,
    this.companyName,
    this.jobTitle,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.driverLicense,
    this.vehicleType,
    this.vehiclePlate,
    this.latitude,
    this.longitude,
  });

  /// Check if user is admin
  bool get isAdmin => roleId == 1;

  /// Check if user is mitra (customer)
  bool get isMitra => roleId == 2;

  /// Check if user is driver
  bool get isDriver => roleId == 3;

  /// Get role display name
  String get roleDisplayName {
    if (roleName != null) return roleName!;
    switch (roleId) {
      case 1:
        return 'Admin';
      case 2:
        return 'Mitra Bisnis';
      case 3:
        return 'Driver';
      default:
        return 'Unknown';
    }
  }

  /// Check if profile is complete
  bool get isProfileComplete {
    return phone != null && address != null;
  }

  /// Create User from JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? json['name'] as String? ?? '',
      roleId: json['role_id'] as int?,
      roleName: json['role_name'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      province: json['province'] as String?,
      postalCode: json['postal_code'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      companyName: json['company_name'] as String?,
      jobTitle: json['job_title'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      driverLicense: json['driver_license'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      vehiclePlate: json['vehicle_plate'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  /// Convert User to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role_id': roleId,
      'role_name': roleName,
      'phone': phone,
      'address': address,
      'city': city,
      'province': province,
      'postal_code': postalCode,
      'avatar_url': avatarUrl,
      'company_name': companyName,
      'job_title': jobTitle,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'driver_license': driverLicense,
      'vehicle_type': vehicleType,
      'vehicle_plate': vehiclePlate,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    int? roleId,
    String? roleName,
    String? phone,
    String? address,
    String? city,
    String? province,
    String? postalCode,
    String? avatarUrl,
    String? companyName,
    String? jobTitle,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? driverLicense,
    String? vehicleType,
    String? vehiclePlate,
    double? latitude,
    double? longitude,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      companyName: companyName ?? this.companyName,
      jobTitle: jobTitle ?? this.jobTitle,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      driverLicense: driverLicense ?? this.driverLicense,
      vehicleType: vehicleType ?? this.vehicleType,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    roleId,
    roleName,
    phone,
    address,
    city,
    province,
    postalCode,
    avatarUrl,
    companyName,
    jobTitle,
    isActive,
    createdAt,
    updatedAt,
    driverLicense,
    vehicleType,
    vehiclePlate,
    latitude,
    longitude,
  ];

  @override
  String toString() =>
      'User(id: $id, email: $email, fullName: $fullName, role: $roleDisplayName)';
}
