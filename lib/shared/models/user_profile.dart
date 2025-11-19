import 'role.dart';

/// Model untuk User Profile (profiles table)
class UserProfile {
  final String id; // UUID primary key
  final String email;
  final String? fullName;
  final int? roleId; // Foreign key to roles table
  final String? phone;
  final String? address;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? role; // Role as string (admin, mitra, driver)
  final String? avatarUrl;
  final String? city;
  final String? province;
  final String? postalCode;
  // Driver specific fields
  final String? driverLicense;
  final String? vehicleType;
  final String? vehiclePlate;

  // Relasi
  final Role? roleObject; // Renamed to avoid conflict with role string

  const UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    this.roleId,
    this.phone,
    this.address,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.role,
    this.avatarUrl,
    this.city,
    this.province,
    this.postalCode,
    this.driverLicense,
    this.vehicleType,
    this.vehiclePlate,
    this.roleObject,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      roleId: json['role_id'] as int?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      role: json['role'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      city: json['city'] as String?,
      province: json['province'] as String?,
      postalCode: json['postal_code'] as String?,
      driverLicense: json['driver_license'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      vehiclePlate: json['vehicle_plate'] as String?,
      roleObject: json['roles'] != null
          ? Role.fromJson(json['roles'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role_id': roleId,
      'phone': phone,
      'address': address,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'role': role,
      'avatar_url': avatarUrl,
      'city': city,
      'province': province,
      'postal_code': postalCode,
      'driver_license': driverLicense,
      'vehicle_type': vehicleType,
      'vehicle_plate': vehiclePlate,
    };
  }

  /// Helper method untuk mendapatkan nama role
  String get roleName => roleObject?.namaPenan ?? role ?? 'Unknown';

  /// Helper method untuk mengecek apakah user adalah admin
  bool get isAdmin => role == 'admin' || roleId == 1;

  /// Helper method untuk mengecek apakah user adalah mitra bisnis
  bool get isMitra => role == 'mitra' || roleId == 2;

  /// Helper method untuk mengecek apakah user adalah driver
  bool get isDriver => role == 'driver' || roleId == 3;

  /// Helper method untuk format nama lengkap
  String get displayName => fullName ?? email.split('@').first;

  /// Helper method untuk mendapatkan alamat lengkap
  String get fullAddress {
    final parts = [
      address,
      city,
      province,
      postalCode,
    ].where((part) => part != null && part.isNotEmpty).toList();
    return parts.isEmpty ? 'Alamat tidak tersedia' : parts.join(', ');
  }

  /// Helper method untuk cek apakah driver sudah lengkap data
  bool get isDriverDataComplete {
    if (!isDriver) return true;
    return driverLicense != null &&
        vehicleType != null &&
        vehiclePlate != null &&
        phone != null;
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    int? roleId,
    String? phone,
    String? address,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? role,
    String? avatarUrl,
    String? city,
    String? province,
    String? postalCode,
    String? driverLicense,
    String? vehicleType,
    String? vehiclePlate,
    Role? roleObject,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      roleId: roleId ?? this.roleId,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      driverLicense: driverLicense ?? this.driverLicense,
      vehicleType: vehicleType ?? this.vehicleType,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      roleObject: roleObject ?? this.roleObject,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, email: $email, fullName: $fullName, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
