import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../../shipments/domain/entities/shipment.dart';

/// Remote data source for Driver operations
class DriverRemoteDataSource {
  final SupabaseClient _client;

  DriverRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Get driver tasks
  Future<List<Shipment>> getDriverTasks({
    required String driverId,
    String? status,
  }) async {
    try {
      var query = _client
          .from('shipments')
          .select('''
            *,
            orders!inner(
              *,
              profiles:customer_id(*)
            )
          ''')
          .eq('driver_id', driverId);

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => Shipment.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Failed to get tasks: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get tasks: $e');
    }
  }

  /// Accept task
  Future<Shipment> acceptTask({required String shipmentId}) async {
    try {
      await _client
          .from('shipments')
          .update({
            'status': 'accepted',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', shipmentId);

      return await _getShipmentById(shipmentId);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to accept task: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to accept task: $e');
    }
  }

  /// Start delivery
  Future<Shipment> startDelivery({required String shipmentId}) async {
    try {
      await _client
          .from('shipments')
          .update({
            'status': 'in_transit',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', shipmentId);

      return await _getShipmentById(shipmentId);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to start delivery: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to start delivery: $e');
    }
  }

  /// Update shipment status
  Future<Shipment> updateShipmentStatus({
    required String shipmentId,
    required String status,
  }) async {
    try {
      final response = await _client
          .from('shipments')
          .update({'status': status})
          .eq('id', shipmentId)
          .select()
          .single();

      return Shipment.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Complete delivery
  Future<Shipment> completeDelivery({
    required String shipmentId,
    String? notes,
  }) async {
    try {
      final updates = {
        'status': 'completed',
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (notes != null) {
        updates['notes'] = notes;
      }

      await _client.from('shipments').update(updates).eq('id', shipmentId);

      return await _getShipmentById(shipmentId);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to complete delivery: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to complete delivery: $e');
    }
  }

  /// Update location
  Future<void> updateLocation({
    required String driverId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _client.from('driver_locations').upsert({
        'driver_id': driverId,
        'latitude': latitude,
        'longitude': longitude,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      throw ServerException('Failed to update location: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to update location: $e');
    }
  }

  Future<Shipment> _getShipmentById(String shipmentId) async {
    final response = await _client
        .from('shipments')
        .select('''
          *,
          orders!inner(
            *,
            profiles:customer_id(*)
          )
        ''')
        .eq('id', shipmentId)
        .single();

    return Shipment.fromJson(response);
  }
}
