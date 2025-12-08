import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../../../core/services/gps_service.dart';
import '../../../shared/repositories/location_repository.dart';

/// Background Tracking Service untuk tracking lokasi driver di background
/// HIGH PRIORITY - User request
class DriverBackgroundTrackingService {
  static final DriverBackgroundTrackingService _instance =
      DriverBackgroundTrackingService._internal();
  factory DriverBackgroundTrackingService() => _instance;
  DriverBackgroundTrackingService._internal();

  final FlutterBackgroundService _backgroundService =
      FlutterBackgroundService();

  bool _isInitialized = false;
  bool _isRunning = false;

  /// Initialize background service
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _backgroundService.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'driver_tracking_channel',
        initialNotificationTitle: 'Driver Tracking',
        initialNotificationContent: 'Tracking lokasi aktif',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    _isInitialized = true;
  }

  /// Start background tracking
  Future<void> startBackgroundTracking({
    required String driverId,
    required String shipmentId,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Start the background service
    await _backgroundService.startService();

    // Send initial data to background service
    _backgroundService.invoke('setDriverData', {
      'driverId': driverId,
      'shipmentId': shipmentId,
    });

    _isRunning = true;
  }

  /// Stop background tracking
  Future<void> stopBackgroundTracking() async {
    if (_isRunning) {
      _backgroundService.invoke('stopService');
      _isRunning = false;
    }
  }

  /// Check if background tracking is running
  bool get isRunning => _isRunning;

  /// Background service entry point
  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    String? driverId;
    String? shipmentId;
    Timer? locationTimer;
    final gpsService = GpsService();
    final locationRepository = LocationRepository();

    // Listen for driver data
    service.on('setDriverData').listen((event) {
      driverId = event?['driverId'] as String?;
      shipmentId = event?['shipmentId'] as String?;

      // Start periodic location updates
      locationTimer?.cancel();
      locationTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
        if (driverId != null) {
          try {
            final position = await gpsService.getCurrentPosition();

            // Save to database
            await locationRepository.saveLocation(
              shipmentId: shipmentId ?? 'no-shipment',
              driverId: driverId!,
              latitude: position.latitude,
              longitude: position.longitude,
              bearing: position.heading,
              speed: position.speed,
              isActive: true,
            );

            // Update notification
            service.invoke('update', {
              'latitude': position.latitude,
              'longitude': position.longitude,
              'speed': position.speed,
            });
          } catch (e) {
            print('Background tracking error: $e');
          }
        }
      });
    });

    // Listen for stop command
    service.on('stopService').listen((event) {
      locationTimer?.cancel();
      service.stopSelf();
    });
  }

  /// iOS background handler
  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }
}
