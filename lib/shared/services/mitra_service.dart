import 'package:supabase_flutter/supabase_flutter.dart';

/// Temporary service for Mitra dashboard
/// TODO: Refactor to use MitraController + OrderRepository
class MitraService {
  static final _supabase = Supabase.instance.client;

  /// Get dashboard statistics for Mitra
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Get user ID
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return {'success': false, 'error': 'User not logged in'};
      }

      // Get orders for this mitra
      final ordersRes = await _supabase
          .from('orders')
          .select('status')
          .eq('customer_id', userId);

      final ordersList = ordersRes as List;

      // Calculate stats
      int totalOrders = ordersList.length;
      int pendingOrders = ordersList
          .where((o) => o['status'] == 'pending')
          .length;
      int activeOrders = ordersList
          .where((o) => o['status'] == 'confirmed' || o['status'] == 'shipped')
          .length;

      // Get this month's orders
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);

      final thisMonthRes = await _supabase
          .from('orders')
          .select('id')
          .eq('customer_id', userId)
          .gte('created_at', firstDayOfMonth.toIso8601String());

      int thisMonthOrders = (thisMonthRes as List).length;

      return {
        'success': true,
        'data': {
          'total_orders': totalOrders,
          'pending_orders': pendingOrders,
          'active_orders': activeOrders,
          'this_month_orders': thisMonthOrders,
        },
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get all active products
  static Future<Map<String, dynamic>> getProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('is_active', true)
          .order('name');

      return {'success': true, 'data': response};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
