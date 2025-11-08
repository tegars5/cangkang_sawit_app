/// Model untuk Roles (Peran User)
class Role {
  final int roleId;
  final String namaPenan;

  const Role({required this.roleId, required this.namaPenan});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      roleId: json['role_id'] as int,
      namaPenan: json['nama_peran'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'role_id': roleId, 'nama_peran': namaPenan};
  }

  @override
  String toString() => 'Role(roleId: $roleId, namaPenan: $namaPenan)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Role &&
        other.roleId == roleId &&
        other.namaPenan == namaPenan;
  }

  @override
  int get hashCode => roleId.hashCode ^ namaPenan.hashCode;
}
