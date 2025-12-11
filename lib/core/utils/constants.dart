/// Application-wide constants
class AppConstants {
  // API
  static const String apiTimeout = '30';
  static const int apiTimeoutSeconds = 30;

  // Storage keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';

  // Order statuses
  static const String orderStatusPending = 'pending';
  static const String orderStatusConfirmed = 'confirmed';
  static const String orderStatusShipped = 'shipped';
  static const String orderStatusCompleted = 'completed';
  static const String orderStatusCancelled = 'cancelled';

  // Shipment statuses
  static const String shipmentStatusPending = 'pending';
  static const String shipmentStatusAssigned = 'assigned';
  static const String shipmentStatusInTransit = 'in_transit';
  static const String shipmentStatusArrived = 'arrived';
  static const String shipmentStatusCompleted = 'completed';

  // User roles
  static const String roleAdmin = 'admin';
  static const String roleMitra = 'mitra';
  static const String roleDriver = 'driver';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
