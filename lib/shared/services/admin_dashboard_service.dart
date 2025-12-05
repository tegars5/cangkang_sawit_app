import 'package:supabase_flutter/supabase_flutter.dart';

/// Temporary service for Admin dashboard
/// TODO: Refactor to use AdminController + proper repositories
class AdminDashboardService {
  static final _supabase = Supabase.instance.client;

  /// Get dashboard statistics for Admin
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // 1. Get Orders
      final ordersRes = await _supabase
          .from('orders')
          .select('status, total_amount');
      final ordersList = ordersRes as List;

      // Calculate stats
      int totalOrders = ordersList.length;
      int pendingOrders = ordersList
          .where((o) => o['status'] == 'pending')
          .length;
      int confirmedOrders = ordersList
          .where((o) => o['status'] == 'confirmed')
          .length;
      int shippedOrders = ordersList
          .where((o) => o['status'] == 'shipped')
          .length;
      int completedOrders = ordersList
          .where((o) => o['status'] == 'completed')
          .length;

      // Calculate revenue
      double totalRevenue = 0;
      for (var order in ordersList) {
        if (order['total_amount'] != null) {
          totalRevenue += (order['total_amount'] as num).toDouble();
        }
      }

      // 2. Get Active Drivers
      final driversRes = await _supabase
          .from('profiles')
          .select('id')
          .eq('role_id', 3) // Driver role
          .eq('is_active', true);
      int activeDrivers = (driversRes as List).length;

      // 3. Get Active Shipments
      final shipmentsRes = await _supabase
          .from('shipments')
          .select('id')
          .neq('status', 'completed')
          .neq('status', 'cancelled');
      int activeShipments = (shipmentsRes as List).length;

      return {
        'success': true,
        'data': {
          'total_orders': totalOrders,
          'pending_orders': pendingOrders,
          'confirmed_orders': confirmedOrders,
          'shipped_orders': shippedOrders,
          'completed_orders': completedOrders,
          'total_revenue': totalRevenue,
          'active_drivers': activeDrivers,
          'active_shipments': activeShipments,
        },
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get recent orders
  static Future<Map<String, dynamic>> getRecentOrders({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, profiles:customer_id(full_name)')
          .order('created_at', ascending: false)
          .limit(limit);

      return {'success': true, 'data': response};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get order details by ID
  static Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select(
            '*, profiles:customer_id(full_name, email, phone), order_details(*)',
          )
          .eq('id', orderId)
          .single();

      return {'success': true, 'data': response};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Cancel an order
  static Future<Map<String, dynamic>> cancelOrder(
    String orderId,
    String reason,
  ) async {
    try {
      await _supabase
          .from('orders')
          .update({
            'status': 'cancelled',
            'cancellation_reason': reason,
            'cancelled_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);

      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
