class AppConstants {
  static const String appName = 'Cangkang Sawit App';

  static const int locationUpdateInterval = 10;

  static const double defaultLatitude = -6.2088;
  static const double defaultLongitude = 106.8456;

  static const double defaultMapZoom = 14.0;

  static const List<String> orderStatuses = [
    'pending',
    'confirmed',
    'shipped',
    'completed',
    'cancelled',
  ];

  static const List<String> shipmentStatuses = [
    'pending',
    'in_transit',
    'arrived',
    'completed',
  ];

  static const List<String> deliveryStatuses = [
    'pending',
    'in_progress',
    'completed',
  ];
}
