/// Model untuk Roles (Peran User)
class Role {
  final int id;
  final String namaPenan;
  final DateTime? createdAt;

  const Role({required this.id, required this.namaPenan, this.createdAt});

  factory Role.fromJson(Map<String, dynamic> json) {
    try {
      return Role(
        id: (json['id'] as num?)?.toInt() ?? 0,
        namaPenan: json['name'] as String? ?? 'Unknown',
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );
    } catch (e) {
      print('❌ Error parsing Role: $e');
      print('📊 JSON: $json');
      // Return default role if parsing fails
      return const Role(id: 0, namaPenan: 'Unknown', createdAt: null);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': namaPenan,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  String toString() => 'Role(id: $id, name: $namaPenan)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Role && other.id == id && other.namaPenan == namaPenan;
  }

  @override
  int get hashCode => id.hashCode ^ namaPenan.hashCode;
}
