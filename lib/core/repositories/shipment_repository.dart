import 'dart:async';
import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../../shared/models/shipment.dart';

class ShipmentRepository {
  static final SupabaseClient _supabase = SupabaseService.instance.client;
  static const String _tableName = 'shipments';

  // Stream controllers for real-time updates
  static final StreamController<List<Shipment>> _shipmentsController =
      StreamController<List<Shipment>>.broadcast();
  static final StreamController<Shipment> _shipmentUpdatesController =
      StreamController<Shipment>.broadcast();

  // Initialize real-time subscriptions
  static void initialize() {
    _setupRealtimeSubscription();
  }

  static void _setupRealtimeSubscription() {
    _supabase.from(_tableName).stream(primaryKey: ['id']).listen((
      List<Map<String, dynamic>> data,
    ) {
      try {
        final shipments = data.map((json) => Shipment.fromJson(json)).toList();
        _shipmentsController.add(shipments);
        log('Real-time shipments update: ${shipments.length} shipments');
      } catch (e, stackTrace) {
        log(
          'Error processing real-time shipment data: $e',
          error: e,
          stackTrace: stackTrace,
        );
      }
    });
  }

  // Stream for all shipments real-time updates
  static Stream<List<Shipment>> get shipmentsStream =>
      _shipmentsController.stream;

  // Stream for individual shipment updates
  static Stream<Shipment> get shipmentUpdatesStream =>
      _shipmentUpdatesController.stream;

  // Get all shipments with optional filtering
  static Future<List<Shipment>> getAllShipments({
    String? driverId,
    String? status,
    int? limit,
    int? offset,
  }) async {
    try {
      // Build query - use dynamic to avoid type issues
      dynamic queryBuilder = _supabase.from(_tableName).select('''
            *,
            driver:driver_id(id, full_name, phone_number, avatar_url),
            order:order_id(id, customer_name, customer_address, total_amount, status)
          ''');

      // Apply filters
      if (driverId != null) {
        queryBuilder = queryBuilder.eq('driver_id', driverId);
      }

      if (status != null) {
        queryBuilder = queryBuilder.eq('status', status);
      }

      if (limit != null) {
        queryBuilder = queryBuilder.limit(limit);
      }

      if (offset != null) {
        queryBuilder = queryBuilder.range(offset, offset + (limit ?? 20) - 1);
      }

      // Execute query with order
      final response = await queryBuilder.order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Shipment.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      log('Error getting shipments: $e', error: e, stackTrace: stackTrace);
      throw Exception('Failed to get shipments: $e');
    }
  }

  // Get shipments for a specific driver
  static Future<List<Shipment>> getDriverShipments(String driverId) async {
    return getAllShipments(driverId: driverId);
  }

  // Get shipments with specific status
  static Future<List<Shipment>> getShipmentsByStatus(String status) async {
    return getAllShipments(status: status);
  }

  // Get active shipments (assigned or picked_up)
  static Future<List<Shipment>> getActiveShipments() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
            driver:driver_id(id, full_name, phone_number, avatar_url),
            order:order_id(id, customer_name, customer_address, total_amount, status)
          ''')
          .inFilter('status', ['assigned', 'picked_up'])
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Shipment.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      log(
        'Error getting active shipments: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to get active shipments: $e');
    }
  }

  // Get shipment by ID
  static Future<Shipment?> getShipmentById(String shipmentId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
            driver:driver_id(id, full_name, phone_number, avatar_url),
            order:order_id(id, customer_name, customer_address, total_amount, status)
          ''')
          .eq('id', shipmentId)
          .maybeSingle();

      if (response == null) return null;

      return Shipment.fromJson(response);
    } catch (e, stackTrace) {
      log('Error getting shipment by ID: $e', error: e, stackTrace: stackTrace);
      throw Exception('Failed to get shipment: $e');
    }
  }

  // Create new shipment
  static Future<Shipment> createShipment({
    required String orderId,
    required String driverId,
    required String deliveryNoteNumber,
    required String destinationAddress,
    String? deliveryNoteUrl,
    String? notes,
    DateTime? pickupDate,
  }) async {
    try {
      final shipmentData = {
        'order_id': orderId,
        'driver_id': driverId,
        'delivery_note_number': deliveryNoteNumber,
        'destination_address': destinationAddress,
        'delivery_note_url': deliveryNoteUrl,
        'notes': notes,
        'pickup_date': pickupDate?.toIso8601String(),
        'status': 'assigned',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from(_tableName)
          .insert(shipmentData)
          .select('''
            *,
            driver:driver_id(id, full_name, phone_number, avatar_url),
            order:order_id(id, customer_name, customer_address, total_amount, status)
          ''')
          .single();

      final shipment = Shipment.fromJson(response);
      _shipmentUpdatesController.add(shipment);

      log('Created shipment: ${shipment.id}');
      return shipment;
    } catch (e, stackTrace) {
      log('Error creating shipment: $e', error: e, stackTrace: stackTrace);
      throw Exception('Failed to create shipment: $e');
    }
  }

  // Update shipment status
  static Future<Shipment> updateShipmentStatus(
    String shipmentId,
    String newStatus, {
    DateTime? deliveryDate,
    String? deliveryPhotoUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (deliveryDate != null) {
        updateData['delivery_date'] = deliveryDate.toIso8601String();
      }

      if (deliveryPhotoUrl != null) {
        updateData['delivery_photo_url'] = deliveryPhotoUrl;
      }

      // If status is picked_up and pickup_date is null, set it
      if (newStatus == 'picked_up') {
        updateData['pickup_date'] = DateTime.now().toIso8601String();
      }

      final response = await _supabase
          .from(_tableName)
          .update(updateData)
          .eq('id', shipmentId)
          .select('''
            *,
            driver:driver_id(id, full_name, phone_number, avatar_url),
            order:order_id(id, customer_name, customer_address, total_amount, status)
          ''')
          .single();

      final shipment = Shipment.fromJson(response);
      _shipmentUpdatesController.add(shipment);

      log('Updated shipment status: ${shipment.id} -> $newStatus');
      return shipment;
    } catch (e, stackTrace) {
      log(
        'Error updating shipment status: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to update shipment status: $e');
    }
  }

  // Update shipment details
  static Future<Shipment> updateShipment(
    String shipmentId, {
    String? deliveryNoteNumber,
    String? deliveryNoteUrl,
    String? deliveryPhotoUrl,
    DateTime? pickupDate,
    DateTime? deliveryDate,
    String? status,
    String? destinationAddress,
    String? notes,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (deliveryNoteNumber != null)
        updateData['delivery_note_number'] = deliveryNoteNumber;
      if (deliveryNoteUrl != null)
        updateData['delivery_note_url'] = deliveryNoteUrl;
      if (deliveryPhotoUrl != null)
        updateData['delivery_photo_url'] = deliveryPhotoUrl;
      if (pickupDate != null)
        updateData['pickup_date'] = pickupDate.toIso8601String();
      if (deliveryDate != null)
        updateData['delivery_date'] = deliveryDate.toIso8601String();
      if (status != null) updateData['status'] = status;
      if (destinationAddress != null)
        updateData['destination_address'] = destinationAddress;
      if (notes != null) updateData['notes'] = notes;

      final response = await _supabase
          .from(_tableName)
          .update(updateData)
          .eq('id', shipmentId)
          .select('''
            *,
            driver:driver_id(id, full_name, phone_number, avatar_url),
            order:order_id(id, customer_name, customer_address, total_amount, status)
          ''')
          .single();

      final shipment = Shipment.fromJson(response);
      _shipmentUpdatesController.add(shipment);

      log('Updated shipment: ${shipment.id}');
      return shipment;
    } catch (e, stackTrace) {
      log('Error updating shipment: $e', error: e, stackTrace: stackTrace);
      throw Exception('Failed to update shipment: $e');
    }
  }

  // Delete shipment
  static Future<void> deleteShipment(String shipmentId) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', shipmentId);

      log('Deleted shipment: $shipmentId');
    } catch (e, stackTrace) {
      log('Error deleting shipment: $e', error: e, stackTrace: stackTrace);
      throw Exception('Failed to delete shipment: $e');
    }
  }

  // Get shipment statistics
  static Future<Map<String, int>> getShipmentStatistics({
    String? driverId,
  }) async {
    try {
      var query = _supabase.from(_tableName).select('status');

      if (driverId != null) {
        query = query.eq('driver_id', driverId);
      }

      final response = await query;

      final stats = <String, int>{
        'assigned': 0,
        'picked_up': 0,
        'delivered': 0,
        'cancelled': 0,
        'total': 0,
      };

      for (final row in response) {
        final status = row['status'] as String;
        stats[status] = (stats[status] ?? 0) + 1;
        stats['total'] = stats['total']! + 1;
      }

      return stats;
    } catch (e, stackTrace) {
      log(
        'Error getting shipment statistics: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to get shipment statistics: $e');
    }
  }

  // Get pending shipments count for driver
  static Future<int> getPendingShipmentsCount(String driverId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('id')
          .eq('driver_id', driverId)
          .inFilter('status', ['assigned', 'picked_up']);

      // Count manually from response list
      return (response as List).length;
    } catch (e, stackTrace) {
      log(
        'Error getting pending shipments count: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to get pending shipments count: $e');
    }
  }

  // Start shipment (change status to picked_up)
  static Future<Shipment> startShipment(String shipmentId) async {
    return updateShipmentStatus(shipmentId, 'picked_up');
  }

  // Complete shipment with delivery photo
  static Future<Shipment> completeShipment(
    String shipmentId,
    String deliveryPhotoUrl,
  ) async {
    return updateShipmentStatus(
      shipmentId,
      'delivered',
      deliveryDate: DateTime.now(),
      deliveryPhotoUrl: deliveryPhotoUrl,
    );
  }

  // Cancel shipment
  static Future<Shipment> cancelShipment(
    String shipmentId, {
    String? reason,
  }) async {
    return updateShipment(shipmentId, status: 'cancelled', notes: reason);
  }

  // Dispose resources
  static void dispose() {
    _shipmentsController.close();
    _shipmentUpdatesController.close();
  }
}
