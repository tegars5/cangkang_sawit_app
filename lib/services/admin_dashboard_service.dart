import 'package:supabase_flutter/supabase_flutter.dart';

/// Service untuk Admin Dashboard dengan real-time data dari Supabase
class AdminDashboardService {
  static final _supabase = Supabase.instance.client;

  /// Get dashboard statistics
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Get total orders
      final orders = await _supabase.from('orders').select('id, status');

      // Count orders by status
      int totalOrders = orders.length;
      int pendingOrders = orders
          .where((order) => order['status'] == 'pending')
          .length;
      int confirmedOrders = orders
          .where((order) => order['status'] == 'confirmed')
          .length;
      int shippedOrders = orders
          .where((order) => order['status'] == 'shipped')
          .length;
      int completedOrders = orders
          .where((order) => order['status'] == 'completed')
          .length;

      // Get total products
      final products = await _supabase.from('products').select('id');
      int totalProducts = products.length;

      // Get total users
      final users = await _supabase.from('profiles').select('id, roles(name)');

      int totalUsers = users.length;
      int totalMitra = users
          .where((user) => user['roles']['name'] == 'mitra bisnis')
          .length;
      int totalDrivers = users
          .where((user) => user['roles']['name'] == 'logistik')
          .length;

      return {
        'success': true,
        'data': {
          'totalOrders': totalOrders,
          'pendingOrders': pendingOrders,
          'confirmedOrders': confirmedOrders,
          'shippedOrders': shippedOrders,
          'completedOrders': completedOrders,
          'totalProducts': totalProducts,
          'totalUsers': totalUsers,
          'totalMitra': totalMitra,
          'totalDrivers': totalDrivers,
        },
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get recent orders with details
  static Future<Map<String, dynamic>> getRecentOrders({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            id,
            order_number,
            total_quantity,
            total_amount,
            status,
            created_at,
            profiles!customer_id(full_name)
          ''')
          .order('created_at', ascending: false)
          .limit(limit);

      final orders = response as List<dynamic>? ?? [];

      return {'success': true, 'data': orders};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get all users with roles
  static Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('''
            id,
            full_name,
            email,
            created_at
          ''')
          .order('created_at', ascending: false);

      final users = response as List<dynamic>? ?? [];

      return {'success': true, 'data': users};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Update order status
  static Future<Map<String, dynamic>> updateOrderStatus(
    String orderId,
    String newStatus,
  ) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': newStatus})
          .eq('id', orderId);

      return {'success': true, 'message': 'Status pesanan berhasil diupdate'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get products with stock info
  static Future<Map<String, dynamic>> getProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select('id, name, description, price_per_kg, unit, created_at')
          .order('name');

      final products = response as List<dynamic>? ?? [];

      return {'success': true, 'data': products};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Add new product
  static Future<Map<String, dynamic>> addProduct({
    required String name,
    required String description,
    required double pricePerKg,
  }) async {
    try {
      await _supabase.from('products').insert({
        'name': name,
        'description': description,
        'price_per_kg': pricePerKg,
        'unit': 'ton',
      });

      return {'success': true, 'message': 'Produk berhasil ditambahkan'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Update product
  static Future<Map<String, dynamic>> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double pricePerKg,
  }) async {
    try {
      await _supabase
          .from('products')
          .update({
            'name': name,
            'description': description,
            'price_per_kg': pricePerKg,
          })
          .eq('id', productId);

      return {'success': true, 'message': 'Produk berhasil diupdate'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Delete product
  static Future<Map<String, dynamic>> deleteProduct(String productId) async {
    try {
      await _supabase.from('products').delete().eq('id', productId);

      return {'success': true, 'message': 'Produk berhasil dihapus'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get delivery assignments (shipments)
  static Future<Map<String, dynamic>> getDeliveries() async {
    try {
      final response = await _supabase
          .from('shipments')
          .select('''
            id,
            delivery_note_number,
            status,
            assigned_at,
            orders!inner(id, order_number, confirmed_quantity),
            profiles!driver_id(full_name)
          ''')
          .order('assigned_at', ascending: false);

      final deliveries = response as List<dynamic>? ?? [];

      return {'success': true, 'data': deliveries};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Real-time subscription untuk dashboard stats
  static Stream<Map<String, dynamic>> subscribeToStats() {
    return Stream.periodic(const Duration(seconds: 30), (count) async {
      return await getDashboardStats();
    }).asyncMap((futureStats) => futureStats);
  }

  /// Real-time subscription untuk orders
  static Stream<List<Map<String, dynamic>>> subscribeToOrders() {
    return _supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(20);
  }
}
