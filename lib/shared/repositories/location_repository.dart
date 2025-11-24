// lib/shared/repositories/location_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class LocationRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// **FOR DRIVER APP:**
  /// Send current GPS location to database
  /// Call this every 10-30 seconds from a background service
  Future<void> updateDriverLocation({
    required String shipmentId,
    required String driverId,
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
  }) async {
    try {
      await _client.from('driver_locations').insert({
        'shipment_id': shipmentId,
        'driver_id': driverId,
        'latitude': latitude,
        'longitude': longitude,
        'heading': heading,
        'speed': speed,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Log error but don't crash app for a single failed ping
      print('Failed to update location: $e');
    }
  }

  /// **FOR MITRA APP:**
  /// Listen to real-time location updates for a specific shipment
  /// This stream will emit a new DriverLocation every time the driver moves
  Stream<List<DriverLocation>> streamDriverLocation(String shipmentId) {
    // Supabase Stream query
    return _client
        .from('driver_locations')
        .stream(primaryKey: ['id']) // Primary key required for streaming
        .eq('shipment_id', shipmentId)
        .order('timestamp', ascending: false) // Get latest first
        .limit(1) // We only need the LATEST position for the marker
        .map(
          (data) => data.map((json) => DriverLocation.fromJson(json)).toList(),
        );
  }

  /// **FOR ADMIN/HISTORY:**
  /// Fetch the full route history to draw a Polyline on the map
  Future<List<DriverLocation>> getDriverRoute(String shipmentId) async {
    try {
      final response = await _client
          .from('driver_locations')
          .select()
          .eq('shipment_id', shipmentId)
          .order(
            'timestamp',
            ascending: true,
          ); // Oldest to newest for drawing line

      return (response as List)
          .map((json) => DriverLocation.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch route history: $e');
    }
  }

  /// Save location with additional parameters for driver dashboard
  Future<void> saveLocation({
    required String shipmentId,
    required String driverId,
    required double latitude,
    required double longitude,
    double? bearing,
    double? speed,
    bool? isActive,
  }) async {
    try {
      await _client.from('driver_locations').insert({
        'shipment_id': shipmentId,
        'driver_id': driverId,
        'latitude': latitude,
        'longitude': longitude,
        'heading': bearing,
        'speed': speed,
        'is_active': isActive ?? true,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to save location: $e');
      rethrow;
    }
  }
}
