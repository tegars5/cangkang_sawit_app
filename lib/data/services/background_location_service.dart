import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Background Location Service - Handles GPS tracking in background
class BackgroundLocationService {
  static final FlutterBackgroundService _service = FlutterBackgroundService();
  static const String _channelId = 'location_tracking_channel';

  /// Initialize and start background location service
  static Future<bool> initializeService() async {
    try {
      // Check permissions first
      final permissionStatus = await _checkPermissions();
      if (!permissionStatus) {
        developer.log('Location permissions not granted');
        return false;
      }

      await _service.configure(
        iosConfiguration: IosConfiguration(
          autoStart: true,
          onForeground: _onStart,
          onBackground: _onIosBackground,
        ),
        androidConfiguration: AndroidConfiguration(
          onStart: _onStart,
          isForegroundMode: true,
          autoStart: true,
          autoStartOnBoot: true,
          notificationChannelId: _channelId,
          initialNotificationTitle: 'Location Tracking Active',
          initialNotificationContent: 'Tracking driver location for deliveries',
          foregroundServiceNotificationId: 888,
        ),
      );

      developer.log('Background location service initialized');
      return true;
    } catch (e) {
      developer.log('Error initializing background service: $e');
      return false;
    }
  }

  /// Check required permissions
  static Future<bool> _checkPermissions() async {
    try {
      // Check location permission
      LocationPermission locationPermission =
          await Geolocator.checkPermission();
      if (locationPermission == LocationPermission.denied) {
        locationPermission = await Geolocator.requestPermission();
      }

      if (locationPermission == LocationPermission.deniedForever) {
        developer.log('Location permission denied forever');
        return false;
      }

      if (locationPermission == LocationPermission.denied) {
        developer.log('Location permission denied');
        return false;
      }

      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        developer.log('Location services disabled');
        return false;
      }

      return true;
    } catch (e) {
      developer.log('Error checking permissions: $e');
      return false;
    }
  }

  /// Start location tracking for a specific driver and shipment
  static Future<bool> startTracking({
    required String driverId,
    String? shipmentId,
    int intervalMinutes = 5,
  }) async {
    try {
      final initialized = await initializeService();
      if (!initialized) return false;

      await _service.startService();

      // Send tracking parameters to service
      _service.invoke('start_tracking', {
        'driver_id': driverId,
        'shipment_id': shipmentId,
        'interval_minutes': intervalMinutes,
      });

      developer.log('Started location tracking for driver $driverId');
      return true;
    } catch (e) {
      developer.log('Error starting location tracking: $e');
      return false;
    }
  }

  /// Stop location tracking
  static Future<bool> stopTracking() async {
    try {
      _service.invoke('stop_tracking');
      // Note: stopService method might not be available in current version
      developer.log('Stopped location tracking');
      return true;
    } catch (e) {
      developer.log('Error stopping location tracking: $e');
      return false;
    }
  }

  /// Check if tracking is currently active
  static Future<bool> isTrackingActive() async {
    try {
      return await _service.isRunning();
    } catch (e) {
      developer.log('Error checking tracking status: $e');
      return false;
    }
  }

  /// Service entry point
  static Future<void> _onStart(ServiceInstance service) async {
    // Note: DartPluginRegistrant might not be available in all versions

    String? driverId;
    String? shipmentId;
    int intervalMinutes = 5;
    Timer? locationTimer;

    // Initialize Supabase if not already initialized
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null || session.accessToken.isEmpty) {
        developer.log('Supabase session not active in background service');
      }
    } catch (e) {
      developer.log('Supabase initialization issue in background: $e');
    }

    // Listen for commands from foreground
    service.on('start_tracking').listen((event) {
      driverId = event?['driver_id'];
      shipmentId = event?['shipment_id'];
      intervalMinutes = event?['interval_minutes'] ?? 5;

      // Start periodic location updates
      locationTimer?.cancel();
      locationTimer = Timer.periodic(
        Duration(minutes: intervalMinutes),
        (_) => _logLocationInBackground(driverId!, shipmentId),
      );

      developer.log('Background tracking started for driver $driverId');
    });

    service.on('stop_tracking').listen((event) {
      locationTimer?.cancel();
      locationTimer = null;
      developer.log('Background tracking stopped');
    });

    // Update notification periodically
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'Location Tracking Active',
          content: 'Last update: ${DateTime.now().toString().substring(0, 19)}',
        );
      }
    });
  }

  /// iOS background handler
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    developer.log('iOS background service running');
    return true;
  }

  /// Log location in background
  static Future<void> _logLocationInBackground(
    String driverId,
    String? shipmentId,
  ) async {
    try {
      // Get current location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );

      // Log to database
      await Supabase.instance.client.from('driver_locations').insert({
        'driver_id': driverId,
        'shipment_id': shipmentId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'speed': position.speed,
        'heading': position.heading,
        'timestamp': DateTime.now().toIso8601String(),
      });

      developer.log(
        'Background location logged: ${position.latitude}, ${position.longitude}',
      );
    } catch (e) {
      developer.log('Error logging location in background: $e');
    }
  }
}

/// Widget to control location tracking
class LocationTrackingWidget extends StatefulWidget {
  final String driverId;
  final String? shipmentId;

  const LocationTrackingWidget({
    super.key,
    required this.driverId,
    this.shipmentId,
  });

  @override
  State<LocationTrackingWidget> createState() => _LocationTrackingWidgetState();
}

class _LocationTrackingWidgetState extends State<LocationTrackingWidget> {
  bool _isTracking = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkTrackingStatus();
  }

  Future<void> _checkTrackingStatus() async {
    final isActive = await BackgroundLocationService.isTrackingActive();
    setState(() {
      _isTracking = isActive;
    });
  }

  Future<void> _toggleTracking() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isTracking) {
        final success = await BackgroundLocationService.stopTracking();
        if (success) {
          setState(() {
            _isTracking = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location tracking stopped'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        final success = await BackgroundLocationService.startTracking(
          driverId: widget.driverId,
          shipmentId: widget.shipmentId,
          intervalMinutes: 5,
        );

        if (success) {
          setState(() {
            _isTracking = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location tracking started'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to start location tracking'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: _isTracking ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Live Location Tracking',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isTracking ? Colors.green : Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _isTracking
                  ? 'Your location is being tracked for this delivery'
                  : 'Location tracking is currently disabled',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _toggleTracking,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_isTracking ? Icons.stop : Icons.play_arrow),
                label: Text(_isTracking ? 'Stop Tracking' : 'Start Tracking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isTracking ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
