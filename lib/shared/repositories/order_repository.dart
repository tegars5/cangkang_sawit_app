import '../models/models.dart';
import '../../core/services/supabase_service.dart';

/// Repository untuk mengelola operasi Order dan OrderDetail
class OrderRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;

  /// Get semua pesanan (Admin) atau pesanan milik user (Mitra Bisnis)
  Future<List<Order>> getOrders({String? status}) async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) throw Exception('User tidak login');

      // Get user profile untuk cek role
      final userProfile = await _supabaseService.client
          .from('profiles')
          .select('role_id')
          .eq('user_id', userId)
          .single();

      final roleId = userProfile['role_id'] as int;

      var query = _supabaseService.client.from('orders').select('''
            *,
            profiles:customer_id(full_name, phone),
            order_details(
              *,
              products(name, unit)
            )
          ''');

      // Filter berdasarkan role
      if (roleId == 2) {
        // Mitra Bisnis - hanya lihat pesanan sendiri
        query = query.eq('customer_id', userId);
      }
      // Admin (role_id = 1) bisa lihat semua pesanan

      // Filter berdasarkan status jika ada
      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('order_date', ascending: false);

      return (response as List).map((order) => Order.fromJson(order)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data pesanan: $e');
    }
  }

  /// Get pesanan berdasarkan ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final response = await _supabaseService.client
          .from('orders')
          .select('''
            *,
            profiles:customer_id(full_name, phone),
            order_details(
              *,
              products(name, unit, price_per_kg)
            )
          ''')
          .eq('id', orderId)
          .single();

      return Order.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil pesanan: $e');
    }
  }

  /// Create pesanan baru (Mitra Bisnis only)
  Future<Order> createOrder({
    required List<Map<String, dynamic>> orderItems, // [{product_id, jumlah}]
    String? catatan,
  }) async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) throw Exception('User tidak login');

      // Generate nomor pesanan
      final nomorPesanan = _supabaseService.generateOrderNumber();

      // 1. Create order
      final orderResponse = await _supabaseService.client
          .from('orders')
          .insert({
            'customer_id': userId,
            'order_number': nomorPesanan,
            'status': 'pending',
            'customer_notes': catatan,
          })
          .select()
          .single();

      final orderId = orderResponse['id'] as String;

      // 2. Create order details
      double totalAmount = 0;
      for (final item in orderItems) {
        // Get price produk
        final product = await _supabaseService.client
            .from('products')
            .select('price')
            .eq('id', item['product_id'])
            .single();

        final unitPrice = (product['price'] as num).toDouble();
        final quantity = (item['quantity'] as num).toDouble();

        totalAmount += unitPrice * quantity;

        await _supabaseService.client.from('order_details').insert({
          'order_id': orderId,
          'product_id': item['product_id'],
          'total_quantity': quantity,
          'confirmed_quantity': 0, // Default 0, akan diupdate saat konfirmasi
          'unit_price': unitPrice,
        });
      }

      // 3. Update total amount di order
      await _supabaseService.client
          .from('orders')
          .update({'total_amount': totalAmount})
          .eq('id', orderId);

      // 4. Return order lengkap
      return await getOrderById(orderId) ?? Order.fromJson(orderResponse);
    } catch (e) {
      throw Exception('Gagal membuat pesanan: $e');
    }
  }

  /// Update status pesanan (Admin only)
  Future<Order> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final response = await _supabaseService.client
          .from('orders')
          .update({'status': status})
          .eq('id', orderId)
          .select()
          .single();

      return Order.fromJson(response);
    } catch (e) {
      throw Exception('Gagal update status order: $e');
    }
  }

  /// Konfirmasi pesanan dengan partial acceptance (Admin only)
  Future<Order> confirmOrder({
    required String orderId,
    required List<Map<String, dynamic>>
    confirmedItems, // [{detail_id, confirmed_quantity}]
  }) async {
    try {
      // 1. Update order details dengan confirmed_quantity
      for (final item in confirmedItems) {
        await _supabaseService.client
            .from('order_details')
            .update({'confirmed_quantity': item['confirmed_quantity']})
            .eq('id', item['detail_id']);
      }

      // 2. Hitung ulang total harga berdasarkan confirmed_quantity
      final orderDetails = await _supabaseService.client
          .from('order_details')
          .select('confirmed_quantity, unit_price')
          .eq('order_id', orderId);

      double totalAmount = 0;
      for (final detail in orderDetails) {
        final confirmedQuantity = (detail['confirmed_quantity'] as num)
            .toDouble();
        final unitPrice = (detail['unit_price'] as num).toDouble();
        totalAmount += confirmedQuantity * unitPrice;
      }

      // 3. Update order status dan total amount
      final response = await _supabaseService.client
          .from('orders')
          .update({'status': 'confirmed', 'total_amount': totalAmount})
          .eq('id', orderId)
          .select()
          .single();

      return Order.fromJson(response);
    } catch (e) {
      throw Exception('Gagal konfirmasi pesanan: $e');
    }
  }

  /// Get pesanan yang ready untuk shipping (status = confirmed)
  Future<List<Order>> getOrdersReadyForShipping() async {
    try {
      final response = await _supabaseService.client
          .from('orders')
          .select('''
            *,
            profiles:customer_id(full_name, phone),
            order_details(
              *,
              products(name, unit)
            )
          ''')
          .eq('status', 'confirmed')
          .order('created_at');

      return (response as List).map((order) => Order.fromJson(order)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil pesanan ready untuk shipping: $e');
    }
  }

  /// Search pesanan berdasarkan nomor pesanan
  Future<List<Order>> searchOrders(String query) async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) throw Exception('User tidak login');

      // Get user profile untuk cek role
      final userProfile = await _supabaseService.client
          .from('profiles')
          .select('role_id')
          .eq('user_id', userId)
          .single();

      final roleId = userProfile['role_id'] as int;

      var queryBuilder = _supabaseService.client.from('orders').select('''
            *,
            profiles:customer_id(full_name, phone),
            order_details(
              *,
              products(name, unit)
            )
          ''');

      // Filter berdasarkan role
      if (roleId == 2) {
        // Mitra Bisnis
        queryBuilder = queryBuilder.eq('customer_id', userId);
      }

      final response = await queryBuilder
          .ilike('order_number', '%$query%')
          .order('created_at', ascending: false);

      return (response as List).map((order) => Order.fromJson(order)).toList();
    } catch (e) {
      throw Exception('Gagal search pesanan: $e');
    }
  }

  /// Get statistik pesanan (Admin only)
  Future<Map<String, int>> getOrderStatistics() async {
    try {
      final response = await _supabaseService.client
          .from('orders')
          .select('status');

      final Map<String, int> stats = {
        'pending': 0,
        'confirmed': 0,
        'packed': 0,
        'shipped': 0,
        'delivered': 0,
      };

      for (final order in response) {
        final status = order['status'] as String;
        if (stats.containsKey(status)) {
          stats[status] = (stats[status] ?? 0) + 1;
        }
      }

      return stats;
    } catch (e) {
      throw Exception('Gagal mengambil statistik pesanan: $e');
    }
  }
}
