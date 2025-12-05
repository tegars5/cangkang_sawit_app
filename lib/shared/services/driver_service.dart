import 'package:supabase_flutter/supabase_flutter.dart';

/// Temporary service for Driver operations
/// TODO: Refactor to use DriverController + proper repositories
class DriverService {
  static final _supabase = Supabase.instance.client;

  /// Get driver dashboard statistics
  static Future<Map<String, dynamic>> getDriverDashboardStats(
    String driverId,
  ) async {
    try {
      // Get active shipments for this driver
      final shipmentsRes = await _supabase
          .from('shipments')
          .select('status')
          .eq('driver_id', driverId)
          .neq('status', 'completed')
          .neq('status', 'cancelled');

      final shipmentsList = shipmentsRes as List;
      int activeShipments = shipmentsList.length;
      int pendingShipments = shipmentsList
          .where((s) => s['status'] == 'pending')
          .length;
      int inTransitShipments = shipmentsList
          .where((s) => s['status'] == 'in_transit')
          .length;

      // Get completed shipments (this month)
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);

      final completedRes = await _supabase
          .from('shipments')
          .select('id')
          .eq('driver_id', driverId)
          .eq('status', 'completed')
          .gte('completed_at', firstDayOfMonth.toIso8601String());

      int completedThisMonth = (completedRes as List).length;

      return {
        'active_shipments': activeShipments,
        'pending_shipments': pendingShipments,
        'in_transit_shipments': inTransitShipments,
        'completed_this_month': completedThisMonth,
        // Additional stats for dashboard
        'assigned_tasks': activeShipments,
        'completed_today': 0, // TODO: Calculate from today's completed
        'total_distance': 0.0, // TODO: Calculate from GPS data
        'active_deliveries': inTransitShipments,
      };
    } catch (e) {
      print('Error getting driver dashboard stats: $e');
      return {
        'active_shipments': 0,
        'pending_shipments': 0,
        'in_transit_shipments': 0,
        'completed_this_month': 0,
        'assigned_tasks': 0,
        'completed_today': 0,
        'total_distance': 0.0,
        'active_deliveries': 0,
      };
    }
  }

  /// Get tasks (shipments) for driver
  static Future<List<Map<String, dynamic>>> getTasks(
    String driverId, {
    String? status,
    DateTime? date,
  }) async {
    try {
      // Build base query
      var queryBuilder = _supabase
          .from('shipments')
          .select('''
            *,
            orders!inner(
              order_number,
              customer_id,
              profiles!inner(full_name, phone, address)
            )
          ''')
          .eq('driver_id', driverId);

      // Apply filters
      if (status != null && status != 'all') {
        queryBuilder = queryBuilder.eq('status', status);
      }

      if (date != null) {
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        queryBuilder = queryBuilder
            .gte('scheduled_delivery', startOfDay.toIso8601String())
            .lt('scheduled_delivery', endOfDay.toIso8601String());
      }

      // Execute query with ordering
      final response = await queryBuilder.order('created_at', ascending: false);

      // Transform data to match expected format
      return (response as List).map((shipment) {
        final order = shipment['orders'];
        final customer = order['profiles'];

        return {
          'id': shipment['id'],
          'task_number': shipment['delivery_note_number'] ?? 'N/A',
          'taskNumber': shipment['delivery_note_number'] ?? 'N/A',
          'orderNumber': order['order_number'] ?? 'N/A',
          'customer_name': customer['full_name'] ?? 'Unknown',
          'customerName': customer['full_name'] ?? 'Unknown',
          'customerPhone': customer['phone'] ?? 'N/A',
          'address': customer['address'] ?? 'N/A',
          'status': shipment['status'] ?? 'pending',
          'scheduled_date': shipment['scheduled_delivery'],
          'scheduledDate': shipment['scheduled_delivery'] != null
              ? DateTime.parse(
                  shipment['scheduled_delivery'],
                ).toString().split(' ')[0]
              : 'Not scheduled',
          'scheduledTime': shipment['scheduled_delivery'] != null
              ? DateTime.parse(
                  shipment['scheduled_delivery'],
                ).toString().split(' ')[1].substring(0, 5)
              : 'N/A',
          'rawData': shipment, // Keep raw data for detail page
        };
      }).toList();
    } catch (e) {
      print('Error getting tasks: $e');
      return [];
    }
  }
}
