/// Feature flags configuration
/// Use this to enable/disable features during development
class FeatureFlags {
  // ==================== ADMIN FEATURES ====================

  /// Enable emergency call feature for drivers
  static const bool enableEmergencyCall = false;

  /// Enable driver messaging feature
  static const bool enableDriverMessaging = false;

  /// Enable shipment editing
  static const bool enableShipmentEdit = false;

  /// Enable shipment creation
  static const bool enableShipmentCreate = false;

  /// Enable user management (add/edit/delete users)
  static const bool enableUserManagement = false;

  // ==================== DRIVER FEATURES ====================

  /// Enable task start feature
  static const bool enableTaskStart = false;

  /// Enable task completion
  static const bool enableTaskComplete = false;

  /// Enable issue reporting
  static const bool enableIssueReport = false;

  /// Enable live tracking
  static const bool enableLiveTracking = false;

  /// Enable vehicle inspection
  static const bool enableVehicleInspection = false;

  // ==================== MITRA FEATURES ====================

  /// Enable product creation
  static const bool enableProductCreate = false;

  /// Enable product editing
  static const bool enableProductEdit = false;

  /// Enable product deletion
  static const bool enableProductDelete = false;

  /// Enable order creation
  static const bool enableOrderCreate = false;

  // ==================== GENERAL FEATURES ====================

  /// Enable notifications
  static const bool enableNotifications = true;

  /// Enable dark mode
  static const bool enableDarkMode = false;

  /// Enable language selection
  static const bool enableLanguageSelection = false;

  /// Enable profile editing
  static const bool enableProfileEdit = true;

  /// Enable password change
  static const bool enablePasswordChange = true;

  // ==================== HELPER METHODS ====================

  /// Check if a feature is enabled by name
  static bool isEnabled(String featureName) {
    switch (featureName.toLowerCase()) {
      // Admin features
      case 'emergency_call':
        return enableEmergencyCall;
      case 'driver_messaging':
        return enableDriverMessaging;
      case 'shipment_edit':
        return enableShipmentEdit;
      case 'shipment_create':
        return enableShipmentCreate;
      case 'user_management':
        return enableUserManagement;

      // Driver features
      case 'task_start':
        return enableTaskStart;
      case 'task_complete':
        return enableTaskComplete;
      case 'issue_report':
        return enableIssueReport;
      case 'live_tracking':
        return enableLiveTracking;
      case 'vehicle_inspection':
        return enableVehicleInspection;

      // Mitra features
      case 'product_create':
        return enableProductCreate;
      case 'product_edit':
        return enableProductEdit;
      case 'product_delete':
        return enableProductDelete;
      case 'order_create':
        return enableOrderCreate;

      // General features
      case 'notifications':
        return enableNotifications;
      case 'dark_mode':
        return enableDarkMode;
      case 'language_selection':
        return enableLanguageSelection;
      case 'profile_edit':
        return enableProfileEdit;
      case 'password_change':
        return enablePasswordChange;

      default:
        return false;
    }
  }

  /// Get list of all enabled features
  static List<String> getEnabledFeatures() {
    final enabled = <String>[];

    if (enableEmergencyCall) enabled.add('emergency_call');
    if (enableDriverMessaging) enabled.add('driver_messaging');
    if (enableShipmentEdit) enabled.add('shipment_edit');
    if (enableShipmentCreate) enabled.add('shipment_create');
    if (enableUserManagement) enabled.add('user_management');
    if (enableTaskStart) enabled.add('task_start');
    if (enableTaskComplete) enabled.add('task_complete');
    if (enableIssueReport) enabled.add('issue_report');
    if (enableLiveTracking) enabled.add('live_tracking');
    if (enableVehicleInspection) enabled.add('vehicle_inspection');
    if (enableProductCreate) enabled.add('product_create');
    if (enableProductEdit) enabled.add('product_edit');
    if (enableProductDelete) enabled.add('product_delete');
    if (enableOrderCreate) enabled.add('order_create');
    if (enableNotifications) enabled.add('notifications');
    if (enableDarkMode) enabled.add('dark_mode');
    if (enableLanguageSelection) enabled.add('language_selection');
    if (enableProfileEdit) enabled.add('profile_edit');
    if (enablePasswordChange) enabled.add('password_change');

    return enabled;
  }

  /// Get "Coming Soon" message for disabled features
  static String getComingSoonMessage(String featureName) {
    return 'Fitur "$featureName" akan segera hadir. Terima kasih atas kesabaran Anda!';
  }
}
