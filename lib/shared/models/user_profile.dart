import 'role.dart';

/// Model untuk User Profile
class UserProfile {
  final String userId;
  final String fullName;
  final int roleId;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Relasi
  final Role? role;

  const UserProfile({
    required this.userId,
    required this.fullName,
    required this.roleId,
    this.phone,
    this.createdAt,
    this.updatedAt,
    this.role,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      roleId: json['role_id'] as int,
      phone: json['phone'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      role: json['roles'] != null
          ? Role.fromJson(json['roles'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'role_id': roleId,
      'phone': phone,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Helper method untuk mendapatkan nama role
  String get roleName => role?.namaPenan ?? 'Unknown';

  /// Helper method untuk mengecek apakah user adalah admin
  bool get isAdmin => roleId == 1;

  /// Helper method untuk mengecek apakah user adalah mitra bisnis
  bool get isMitraBisnis => roleId == 2;

  /// Helper method untuk mengecek apakah user adalah logistik/driver
  bool get isDriver => roleId == 3;

  UserProfile copyWith({
    String? userId,
    String? fullName,
    int? roleId,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    Role? role,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      roleId: roleId ?? this.roleId,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      role: role ?? this.role,
    );
  }

  @override
  String toString() {
    return 'UserProfile(userId: $userId, fullName: $fullName, roleId: $roleId, roleName: $roleName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}
