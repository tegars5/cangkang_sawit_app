/// User role enumeration
/// Maps to role_id in database
enum UserRole {
  /// Admin role (role_id = 1)
  admin(1, 'Admin'),

  /// Mitra Bisnis role (role_id = 2)
  mitra(2, 'Mitra Bisnis'),

  /// Driver/Logistik role (role_id = 3)
  driver(12, 'Driver');

  const UserRole(this.id, this.displayName);

  /// Database role ID
  final int id;

  /// Display name for UI
  final String displayName;

  /// Get role from ID
  static UserRole fromId(int id) {
    switch (id) {
      case 1:
        return UserRole.admin;
      case 2:
        return UserRole.mitra;
      case 12:
        return UserRole.driver;
      default:
        throw ArgumentError('Invalid role ID: $id');
    }
  }

  /// Get role from name
  static UserRole? fromName(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('admin')) return UserRole.admin;
    if (lowerName.contains('mitra')) return UserRole.mitra;
    if (lowerName.contains('driver') || lowerName.contains('logistik')) {
      return UserRole.driver;
    }
    return null;
  }

  /// Check if role is admin
  bool get isAdmin => this == UserRole.admin;

  /// Check if role is mitra
  bool get isMitra => this == UserRole.mitra;

  /// Check if role is driver
  bool get isDriver => this == UserRole.driver;
}

/// Order status enumeration
enum OrderStatus {
  /// Order is pending confirmation
  pending('pending', 'Pending', 'Menunggu Konfirmasi'),

  /// Order is confirmed
  confirmed('confirmed', 'Confirmed', 'Dikonfirmasi'),

  /// Order is being processed
  processing('processing', 'Processing', 'Diproses'),

  /// Order is shipped
  shipped('shipped', 'Shipped', 'Dikirim'),

  /// Order is delivered
  delivered('delivered', 'Delivered', 'Terkirim'),

  /// Order is completed
  completed('completed', 'Completed', 'Selesai'),

  /// Order is cancelled
  cancelled('cancelled', 'Cancelled', 'Dibatalkan');

  const OrderStatus(this.value, this.displayName, this.displayNameId);

  /// Database value
  final String value;

  /// Display name (English)
  final String displayName;

  /// Display name (Indonesian)
  final String displayNameId;

  /// Get status from value
  static OrderStatus fromValue(String value) {
    final lowerValue = value.toLowerCase();
    for (final status in OrderStatus.values) {
      if (status.value == lowerValue) return status;
    }
    return OrderStatus.pending;
  }

  /// Check if order is active (not completed or cancelled)
  bool get isActive =>
      this != OrderStatus.completed && this != OrderStatus.cancelled;

  /// Check if order can be cancelled
  bool get canBeCancelled =>
      this == OrderStatus.pending || this == OrderStatus.confirmed;
}

/// Shipment status enumeration
enum ShipmentStatus {
  /// Shipment is pending
  pending('pending', 'Ready to Ship', 'Siap Dikirim'),

  /// Shipment is in transit
  inTransit('in_transit', 'In Transit', 'Dalam Perjalanan'),

  /// Shipment is delivered
  delivered('delivered', 'Delivered', 'Terkirim'),

  /// Shipment is completed
  completed('completed', 'Completed', 'Selesai'),

  /// Shipment is cancelled
  cancelled('cancelled', 'Cancelled', 'Dibatalkan');

  const ShipmentStatus(this.value, this.displayName, this.displayNameId);

  /// Database value
  final String value;

  /// Display name (English)
  final String displayName;

  /// Display name (Indonesian)
  final String displayNameId;

  /// Get status from value
  static ShipmentStatus fromValue(String value) {
    final lowerValue = value.toLowerCase().replaceAll(' ', '_');
    for (final status in ShipmentStatus.values) {
      if (status.value == lowerValue) return status;
    }
    return ShipmentStatus.pending;
  }

  /// Get progress value (0.0 to 1.0)
  double get progress {
    switch (this) {
      case ShipmentStatus.pending:
        return 0.0;
      case ShipmentStatus.inTransit:
        return 0.5;
      case ShipmentStatus.delivered:
      case ShipmentStatus.completed:
        return 1.0;
      case ShipmentStatus.cancelled:
        return 0.0;
    }
  }

  /// Check if shipment is active
  bool get isActive =>
      this != ShipmentStatus.completed && this != ShipmentStatus.cancelled;
}

/// Task/Driver status enumeration
enum TaskStatus {
  /// Task is scheduled
  scheduled('scheduled', 'Scheduled', 'Terjadwal'),

  /// Task is ready to start
  ready('ready', 'Ready', 'Siap'),

  /// Task is in progress
  inProgress('in_progress', 'In Progress', 'Sedang Berjalan'),

  /// Task is completed
  completed('completed', 'Completed', 'Selesai'),

  /// Task is cancelled
  cancelled('cancelled', 'Cancelled', 'Dibatalkan');

  const TaskStatus(this.value, this.displayName, this.displayNameId);

  /// Database value
  final String value;

  /// Display name (English)
  final String displayName;

  /// Display name (Indonesian)
  final String displayNameId;

  /// Get status from value
  static TaskStatus fromValue(String value) {
    final lowerValue = value.toLowerCase().replaceAll(' ', '_');
    for (final status in TaskStatus.values) {
      if (status.value == lowerValue) return status;
    }
    return TaskStatus.scheduled;
  }

  /// Get progress value (0.0 to 1.0)
  double get progress {
    switch (this) {
      case TaskStatus.scheduled:
        return 0.0;
      case TaskStatus.ready:
        return 0.25;
      case TaskStatus.inProgress:
        return 0.65;
      case TaskStatus.completed:
        return 1.0;
      case TaskStatus.cancelled:
        return 0.0;
    }
  }

  /// Check if task is active
  bool get isActive =>
      this != TaskStatus.completed && this != TaskStatus.cancelled;
}
