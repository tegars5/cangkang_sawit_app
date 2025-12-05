import 'package:supabase_flutter/supabase_flutter.dart';

/// Temporary service for Shipment operations
/// TODO: Refactor to use ShipmentController + ShipmentRepository
class ShipmentService {
  static final _supabase = Supabase.instance.client;

  /// Get all shipments
  static Future<List<Map<String, dynamic>>> getShipments() async {
    try {
      final response = await _supabase
          .from('shipments')
          .select('''
            *,
            orders!inner(
              order_number,
              customer_id,
              profiles!inner(full_name)
            ),
            driver:profiles!shipments_driver_id_fkey(full_name)
          ''')
          .order('created_at', ascending: false);

      // Transform data to match expected format
      return (response as List).map((shipment) {
        final order = shipment['orders'];
        final customer = order['profiles'];
        final driver = shipment['driver'];

        return {
          'id': shipment['id'],
          'shipmentNumber': shipment['delivery_note_number'] ?? 'N/A',
          'orderNumber': order['order_number'] ?? 'N/A',
          'customerName': customer['full_name'] ?? 'Unknown',
          'driver': driver?['full_name'] ?? 'Unassigned',
          'vehicle': 'N/A', // TODO: Add vehicle info
          'destination': 'N/A', // TODO: Add destination from order
          'quantity': 'N/A', // TODO: Calculate from order details
          'status': _mapStatus(shipment['status']),
          'progress': _calculateProgress(shipment['status']),
          'scheduledDate': shipment['scheduled_delivery'] != null
              ? DateTime.parse(
                  shipment['scheduled_delivery'],
                ).toString().split(' ')[0]
              : 'Not scheduled',
          'rawData': shipment, // Keep raw data for detail page
        };
      }).toList();
    } catch (e) {
      print('Error getting shipments: $e');
      return [];
    }
  }

  /// Get shipment by ID
  static Future<Map<String, dynamic>?> getShipmentById(String id) async {
    try {
      final response = await _supabase
          .from('shipments')
          .select('''
            *,
            orders!inner(*),
            driver:profiles!shipments_driver_id_fkey(*)
          ''')
          .eq('id', id)
          .single();

      return response;
    } catch (e) {
      print('Error getting shipment: $e');
      return null;
    }
  }

  /// Map database status to display status
  static String _mapStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Ready to Ship';
      case 'in_transit':
        return 'In Transit';
      case 'delivered':
      case 'completed':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  /// Calculate progress based on status
  static double _calculateProgress(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 0.0;
      case 'in_transit':
        return 0.5;
      case 'delivered':
      case 'completed':
        return 1.0;
      default:
        return 0.0;
    }
  }
}
