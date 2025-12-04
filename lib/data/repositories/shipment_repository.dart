// lib/shared/repositories/shipment_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class ShipmentRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Create a new shipment (Assign Driver to Order)
  /// Usually called by Admin or Logistics Coordinator
  Future<Shipment> createShipment({
    required String orderId,
    required String driverId,
    required String deliveryNoteNumber,
    String? deliveryNoteUrl,
  }) async {
    try {
      // 1. Create the shipment record
      final shipmentData = await _client
          .from('shipments')
          .insert({
            'order_id': orderId,
            'driver_id': driverId,
            'delivery_note_number': deliveryNoteNumber,
            'delivery_note_url': deliveryNoteUrl,
            'status': 'pending',
            'assigned_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      // 2. Update Order status to 'shipped' (optional, depends on business flow)
      await _client
          .from('orders')
          .update({'status': 'shipped'})
          .eq('id', orderId);

      return Shipment.fromJson(shipmentData);
    } catch (e) {
      throw Exception('Failed to create shipment: $e');
    }
  }

  /// Update shipment status (e.g., pending -> in_transit -> arrived)
  Future<void> updateStatus(String shipmentId, String status) async {
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
      } else if (status == 'arrived') {
         // Maybe mark arrival time if schema supported it, 
         // typically 'actual_delivery' handles the final handover.
      }

      await _client
          .from('shipments')
          .update(updates)
          .eq('id', shipmentId);

      // If completed, also mark the Order as completed
      if (status == 'completed') {
        // Fetch order_id first
        final shipment = await _client
            .from('shipments')
            .select('order_id')
            .eq('id', shipmentId)
            .single();
            
        if (shipment['order_id'] != null) {
           await _client
            .from('orders')
            .update({
              'status': 'completed',
              'completed_at': DateTime.now().toIso8601String(),
            })
            .eq('id', shipment['order_id']);
        }
      }

    } catch (e) {
      throw Exception('Failed to update shipment status: $e');
    }
  }

  /// Get shipment details by Order ID
  /// Used in OrderDetailScreen to show tracking button
  Future<Shipment?> getShipmentByOrderId(String orderId) async {
    try {
      final response = await _client
          .from('shipments')
          .select()
          .eq('order_id', orderId)
          .maybeSingle(); // Returns null if not found

      if (response == null) return null;
      return Shipment.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch shipment: $e');
    }
  }
  
  /// Get active shipment for a specific driver
  /// Used in Driver App Dashboard
  Future<Shipment?> getActiveShipmentForDriver(String driverId) async {
    try {
      final response = await _client
          .from('shipments')
          .select()
          .eq('driver_id', driverId)
          .neq('status', 'completed') // Only active ones
          .neq('status', 'cancelled')
          .maybeSingle();

      if (response == null) return null;
      return Shipment.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch active shipment: $e');
    }
  }
}