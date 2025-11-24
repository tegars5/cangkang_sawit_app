// ===============================================================
// UPDATED Profile Model for Flutter
// After adding company columns to Supabase profiles table
// Date: November 25, 2025
// ===============================================================

class Profile {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? address;
  final String role;

  // ✅ NEW COMPANY FIELDS (Added November 2025)
  final String? companyName; // Company name (PT/CV)
  final String? jobTitle; // PIC job title/position
  final double? latitude; // Warehouse/office latitude coordinate
  final double? longitude; // Warehouse/office longitude coordinate

  Profile({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.address,
    required this.role,
    // New fields
    this.companyName,
    this.jobTitle,
    this.latitude,
    this.longitude,
  });

  // From JSON (Supabase response)
  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['full_name'] ?? '',
      phone: map['phone'],
      address: map['address'],
      role: map['role'] ?? '',
      // ✅ New fields mapping
      companyName: map['company_name'],
      jobTitle: map['job_title'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }

  // To JSON (for Supabase insert/update)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'role': role,
      // ✅ New fields
      'company_name': companyName,
      'job_title': jobTitle,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Copy with method for updates
  Profile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? address,
    String? role,
    String? companyName,
    String? jobTitle,
    double? latitude,
    double? longitude,
  }) {
    return Profile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
      companyName: companyName ?? this.companyName,
      jobTitle: jobTitle ?? this.jobTitle,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  // Helper methods for company data
  bool get hasCompanyInfo => companyName != null && companyName!.isNotEmpty;
  bool get hasLocationInfo => latitude != null && longitude != null;

  // Format company display name
  String get companyDisplayName {
    if (!hasCompanyInfo) return 'Company not specified';
    return companyName!;
  }

  // Format PIC info
  String get picInfo {
    if (jobTitle != null && jobTitle!.isNotEmpty) {
      return '$fullName - $jobTitle';
    }
    return fullName;
  }

  @override
  String toString() {
    return 'Profile(id: $id, email: $email, fullName: $fullName, role: $role, '
        'companyName: $companyName, jobTitle: $jobTitle, '
        'latitude: $latitude, longitude: $longitude)';
  }
}
