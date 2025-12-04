import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

/// Service untuk Admin Dashboard dengan REAL-TIME data dari Supabase
class AdminDashboardService {
  static final _supabase = Supabase.instance.client;

  /// Get dashboard statistics (DATA ASLI)
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // 1. Ambil Data Orders (Status dan Total Price untuk Revenue)
      final ordersRes = await _supabase
          .from('orders')
          .select('status, total_price');
      final ordersList = ordersRes as List;

      // Hitung manual di sisi aplikasi (Dart)
      int totalOrders = ordersList.length;
      int pendingOrders = ordersList
          .where((o) => o['status'] == 'pending')
          .length;
      // Processing mencakup: confirmed, shipped, in_transit
      int processingOrders = ordersList
          .where(
            (o) => [
              'confirmed',
              'shipped',
              'in_transit',
              'processing',
            ].contains(o['status']),
          )
          .length;
      int completedOrders = ordersList
          .where((o) => o['status'] == 'completed')
          .length;

      // Hitung Total Revenue (Sum total_price dari completed orders)
      double totalRevenue = ordersList
          .where((o) => o['status'] == 'completed')
          .fold(0.0, (sum, item) => sum + (item['total_price'] ?? 0));

      // 2. Hitung Products (Jumlah total produk)
      final productsRes = await _supabase.from('products').count();
      int totalProducts = productsRes;

      // 3. Hitung Users & Drivers
      final usersRes = await _supabase.from('profiles').select('role');
      final usersList = usersRes as List;

      int totalUsers = usersList.length;
      int totalMitra = usersList
          .where(
            (u) => (u['role'] ?? '').toString().toLowerCase().contains('mitra'),
          )
          .length;
      int totalDrivers = usersList
          .where(
            (u) =>
                (u['role'] ?? '').toString().toLowerCase().contains('driver'),
          )
          .length;

      // Count active shipments (orders that are shipped or in_transit)
      int activeShipments = ordersList
          .where((o) => ['shipped', 'in_transit'].contains(o['status']))
          .length;

      return {
        'success': true,
        'data': {
          'total_orders': totalOrders,
          'pending_orders': pendingOrders,
          'processing_orders': processingOrders,
          'completed_orders': completedOrders,
          'active_shipments': activeShipments,
          'total_products': totalProducts,
          'total_users': totalUsers,
          'total_mitra': totalMitra,
          'total_drivers': totalDrivers,
          'total_revenue': totalRevenue,
        },
      };
    } catch (e) {
      developer.log('Error getting dashboard stats: $e');
      // Return 0 semua jika error, supaya aplikasi tidak crash
      return {
        'success': false,
        'error': e.toString(),
        'data': {
          'total_orders': 0,
          'pending_orders': 0,
          'processing_orders': 0,
          'completed_orders': 0,
          'active_shipments': 0,
          'total_products': 0,
          'total_users': 0,
          'total_mitra': 0,
          'total_drivers': 0,
          'total_revenue': 0.0,
        },
      };
    }
  }

  /// Get recent orders (DATA ASLI)
  /// Mengambil 10 order terbaru beserta nama customer
  static Future<Map<String, dynamic>> getRecentOrders({int limit = 10}) async {
    try {
      // Join tabel orders dengan profiles (customer)
      // Pastikan Foreign Key di Supabase sudah benar
      final response = await _supabase
          .from('orders')
          .select('*, profiles:customer_id(full_name, role)')
          .order('created_at', ascending: false)
          .limit(limit);

      return {'success': true, 'data': response};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get real-time updates subscription (Opsional)
  static Stream<List<Map<String, dynamic>>> streamOrders() {
    return _supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .order('created_at');
  }
}
