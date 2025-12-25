import 'package:equatable/equatable.dart';

/// Driver Information Entity
/// Pure domain entity representing driver information for admin management
class DriverInfo extends Equatable {
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

  const DriverInfo({
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

  // Business Methods

  /// Check if driver is currently active
  bool isCurrentlyActive() => isActive;

  /// Check if driver is available (active and no active deliveries)
  bool isAvailable() => isActive && activeDeliveries == 0;

  /// Check if driver is on duty (active and has active deliveries)
  bool isOnDuty() => isActive && activeDeliveries > 0;

  /// Check if driver has location data
  bool hasLocation() => latitude != null && longitude != null;

  /// Check if driver has good rating (>= 4.0)
  bool hasGoodRating() => rating != null && rating! >= 4.0;

  /// Check if driver has excellent rating (>= 4.5)
  bool hasExcellentRating() => rating != null && rating! >= 4.5;

  /// Check if driver was recently active (within last hour)
  bool wasRecentlyActive() {
    if (lastActive == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastActive!);
    return difference.inHours < 1;
  }

  /// Check if driver is new (joined within last 30 days)
  bool isNewDriver() {
    final now = DateTime.now();
    final difference = now.difference(joinedDate);
    return difference.inDays <= 30;
  }

  /// Check if driver is experienced (completed >= 50 deliveries)
  bool isExperienced() => completedDeliveries >= 50;

  /// Get status text
  String getStatusText() {
    if (!isActive) return 'Inactive';
    if (activeDeliveries > 0) return 'On Duty';
    return 'Available';
  }

  /// Get status color indicator
  String getStatusColor() {
    if (!isActive) return 'grey';
    if (activeDeliveries > 0) return 'green';
    return 'blue';
  }

  /// Get rating stars text
  String getRatingStars() {
    if (rating == null) return 'N/A';
    return '⭐' * rating!.round();
  }

  /// Get experience level
  String getExperienceLevel() {
    if (completedDeliveries >= 100) return 'Expert';
    if (completedDeliveries >= 50) return 'Experienced';
    if (completedDeliveries >= 10) return 'Intermediate';
    return 'Beginner';
  }

  /// Get last active text
  String getLastActiveText() {
    if (lastActive == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(lastActive!);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    return '${difference.inDays} days ago';
  }

  /// Validate driver data
  bool validate() {
    if (id.isEmpty) return false;
    if (name.isEmpty) return false;
    if (email.isEmpty) return false;
    return true;
  }

  DriverInfo copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? vehicleNumber,
    String? vehicleType,
    bool? isActive,
    int? completedDeliveries,
    int? activeDeliveries,
    double? rating,
    DateTime? lastActive,
    DateTime? joinedDate,
    String? currentLocation,
    double? latitude,
    double? longitude,
  }) {
    return DriverInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      isActive: isActive ?? this.isActive,
      completedDeliveries: completedDeliveries ?? this.completedDeliveries,
      activeDeliveries: activeDeliveries ?? this.activeDeliveries,
      rating: rating ?? this.rating,
      lastActive: lastActive ?? this.lastActive,
      joinedDate: joinedDate ?? this.joinedDate,
      currentLocation: currentLocation ?? this.currentLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    vehicleNumber,
    vehicleType,
    isActive,
    completedDeliveries,
    activeDeliveries,
    rating,
    lastActive,
    joinedDate,
    currentLocation,
    latitude,
    longitude,
  ];
}
