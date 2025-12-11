import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../shared/models/models.dart';

/// Remote data source for Shipment operations
class ShipmentRemoteDataSource {
  final SupabaseClient _client;

  ShipmentRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Get all shipments with optional filtering
  Future<List<Shipment>> getShipments({
    String? status,
    String? driverId,
  }) async {
    try {
      var query = _client.from('shipments').select('''
            *,
            orders!inner(
              *,
              profiles:customer_id(*)
            )
          ''');

      if (status != null) {
        query = query.eq('status', status);
      }

      if (driverId != null) {
        query = query.eq('driver_id', driverId);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => Shipment.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Failed to get shipments: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get shipments: $e');
    }
  }

  /// Get shipment by ID
  Future<Shipment> getShipmentById(String shipmentId) async {
    try {
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

      return Shipment.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw NotFoundException('Shipment not found');
      }
      throw ServerException('Failed to get shipment: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get shipment: $e');
    }
  }

  /// Assign driver to shipment
  Future<Shipment> assignDriver({
    required String shipmentId,
    required String driverId,
  }) async {
    try {
      await _client
          .from('shipments')
          .update({
            'driver_id': driverId,
            'status': 'assigned',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', shipmentId);

      return await getShipmentById(shipmentId);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to assign driver: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to assign driver: $e');
    }
  }

  /// Update shipment status
  Future<Shipment> updateShipmentStatus({
    required String shipmentId,
    required String newStatus,
  }) async {
    try {
      await _client
          .from('shipments')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', shipmentId);

      return await getShipmentById(shipmentId);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to update status: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to update status: $e');
    }
  }

  /// Add timeline event
  Future<void> addTimelineEvent({
    required String shipmentId,
    required ShipmentTimeline event,
  }) async {
    try {
      final eventData = event.toJson();
      eventData['shipment_id'] = shipmentId;

      await _client.from('shipment_timeline').insert(eventData);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to add timeline event: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to add timeline event: $e');
    }
  }
}
