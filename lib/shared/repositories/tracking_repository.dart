import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/shipment_timeline.dart';
import '../../data/models/driver_location.dart';
import '../models/models.dart' hide DriverLocation;

/// Repository for tracking shipment progress in real-time
/// Handles Supabase Realtime subscriptions for live updates
class TrackingRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Watch shipment timeline updates in real-time
  /// Returns a stream that emits new timeline events as they occur
  Stream<List<ShipmentTimeline>> watchTimelineUpdates(String shipmentId) {
    return _client
        .from('shipment_timeline')
        .stream(primaryKey: ['id'])
        .eq('shipment_id', shipmentId)
        .order('created_at', ascending: false)
        .map(
          (data) =>
              data.map((json) => ShipmentTimeline.fromJson(json)).toList(),
        );
  }

  /// Watch driver location in real-time
  /// Returns a stream that emits the latest driver location
  Stream<DriverLocation?> watchDriverLocation(String shipmentId) {
    return _client
        .from('driver_locations')
        .stream(primaryKey: ['id'])
        .eq('shipment_id', shipmentId)
        .order('timestamp', ascending: false)
        .limit(1)
        .map((data) {
          if (data.isEmpty) return null;
          return DriverLocation.fromJson(data.first);
        });
  }

  /// Get shipment timeline history
  Future<List<ShipmentTimeline>> getTimelineHistory(String shipmentId) async {
    try {
      final response = await _client
          .from('shipment_timeline')
          .select()
          .eq('shipment_id', shipmentId)
          .order('created_at', ascending: false)
          .limit(50);

      return (response as List)
          .map((json) => ShipmentTimeline.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch timeline history: $e');
    }
  }

  /// Get latest driver location
  Future<DriverLocation?> getLatestDriverLocation(String shipmentId) async {
    try {
      final response = await _client
          .from('driver_locations')
          .select()
          .eq('shipment_id', shipmentId)
          .order('timestamp', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return DriverLocation.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch driver location: $e');
    }
  }

  /// Get shipment details with driver and order info
  Future<Shipment?> getShipmentDetails(String shipmentId) async {
    try {
      final response = await _client
          .from('shipments')
          .select('''
            *,
            profiles:driver_id(*),
            orders:order_id(*)
          ''')
          .eq('id', shipmentId)
          .maybeSingle();

      if (response == null) return null;
      return Shipment.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch shipment details: $e');
    }
  }

  /// Add timeline update (for driver)
  Future<void> addTimelineUpdate({
    required String shipmentId,
    required String status,
    required String message,
    double? locationLat,
    double? locationLng,
  }) async {
    try {
      await _client.from('shipment_timeline').insert({
        'shipment_id': shipmentId,
        'status': status,
        'message': message,
        'location_lat': locationLat,
        'location_lng': locationLng,
      });
    } catch (e) {
      throw Exception('Failed to add timeline update: $e');
    }
  }

  /// Update driver location (for driver)
  Future<void> updateDriverLocation({
    required String driverId,
    required String shipmentId,
    required double latitude,
    required double longitude,
    double? accuracy,
    double? speed,
    double? heading,
  }) async {
    try {
      await _client.from('driver_locations').insert({
        'driver_id': driverId,
        'shipment_id': shipmentId,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'speed': speed,
        'heading': heading,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update driver location: $e');
    }
  }

  /// Update shipment status
  Future<void> updateShipmentStatus({
    required String shipmentId,
    required String status,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add specific timestamps based on status
      if (status == 'in_transit') {
        updates['started_at'] = DateTime.now().toIso8601String();
      } else if (status == 'completed') {
        updates['completed_at'] = DateTime.now().toIso8601String();
        updates['actual_delivery'] = DateTime.now().toIso8601String();
      }

      await _client.from('shipments').update(updates).eq('id', shipmentId);
    } catch (e) {
      throw Exception('Failed to update shipment status: $e');
    }
  }

  /// Get shipment by order ID
  Future<Shipment?> getShipmentByOrderId(String orderId) async {
    try {
      final response = await _client
          .from('shipments')
          .select('''
            *,
            profiles:driver_id(*),
            orders:order_id(*)
          ''')
          .eq('order_id', orderId)
          .maybeSingle();

      if (response == null) return null;
      return Shipment.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch shipment: $e');
    }
  }

  /// Get active shipment for driver
  Future<Shipment?> getActiveShipmentForDriver(String driverId) async {
    try {
      final response = await _client
          .from('shipments')
          .select('''
            *,
            profiles:driver_id(*),
            orders:order_id(*)
          ''')
          .eq('driver_id', driverId)
          .neq('status', 'completed')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return Shipment.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch active shipment: $e');
    }
  }

  /// Get current user ID
  Future<String?> getCurrentUserId() async {
    return _client.auth.currentUser?.id;
  }
}
