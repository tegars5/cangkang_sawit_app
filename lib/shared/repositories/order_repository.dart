import '../models/models.dart';
import '../../core/services/supabase_service.dart';

/// Repository untuk mengelola operasi Order dan OrderDetail
class OrderRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;

  /// Get semua pesanan (Admin) atau pesanan milik user (Mitra)
  Future<List<Order>> getOrders({String? status}) async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) throw Exception('User tidak login');

      // Get user profile untuk cek role
      final userProfile = await _supabaseService.client
          .from('profiles')
          .select('role, role_id')
          .eq('id', userId)
          .single();

      final role = userProfile['role'] as String?;

      var query = _supabaseService.client.from('orders').select('''
            id, order_number, customer_id, order_date, status, 
            total_quantity, confirmed_quantity, total_amount, 
            admin_notes, customer_notes, confirmed_at, completed_at,
            created_at, updated_at, pickup_address, delivery_address,
            pickup_date, delivery_date, notes,
            profiles:customer_id(id, email, full_name, phone, role),
            order_details(
              id, order_id, product_id, requested_quantity, confirmed_quantity,
              unit_price, subtotal, notes, created_at, updated_at,
              products(id, name, description, price_per_kg, unit, category)
            )
          ''');

      // Filter berdasarkan role
      if (role == 'mitra') {
        // Mitra - hanya lihat pesanan sendiri
        query = query.eq('customer_id', userId);
      }
      // Admin dan driver bisa lihat semua pesanan

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
            id, order_number, customer_id, order_date, status, 
            total_quantity, confirmed_quantity, total_amount, 
            admin_notes, customer_notes, confirmed_at, completed_at,
            created_at, updated_at, pickup_address, delivery_address,
            pickup_date, delivery_date, notes,
            profiles:customer_id(id, email, full_name, phone, role),
            order_details(
              id, order_id, product_id, requested_quantity, confirmed_quantity,
              unit_price, subtotal, notes, created_at, updated_at,
              products(id, name, description, price_per_kg, unit, category)
            )
          ''')
          .eq('id', orderId)
          .single();

      return Order.fromJson(response);
    } catch (e) {
      if (e.toString().contains('No rows found')) {
        return null;
      }
      throw Exception('Gagal mengambil pesanan: $e');
    }
  }

  /// Create pesanan baru dengan transaction logic yang robust
  ///
  /// Parameters:
  /// - [order]: Order object yang akan dibuat
  /// - [items]: List OrderDetail yang akan dimasukkan
  ///
  /// Returns: String order ID jika berhasil
  ///
  /// Throws: Exception jika gagal dengan pesan error yang jelas
  Future<String> createOrder({
    required Order order,
    required List<OrderDetail> items,
  }) async {
    if (items.isEmpty) {
      throw Exception('Order items tidak boleh kosong');
    }

    try {
      // Step 0: Stock validation (Optional but recommended)
      await _validateProductStock(items);

      // Step A: Insert order data into public.orders table
      final orderData = order.toJson();
      // Remove fields that should be auto-generated or not included in insert
      orderData.remove('id'); // Will be auto-generated as UUID
      orderData.remove('created_at'); // Will be auto-generated
      orderData.remove('updated_at'); // Will be auto-generated

      final orderResponse = await _supabaseService.client
          .from('orders')
          .insert(orderData)
          .select(
            'id, order_number, customer_id, order_date, status, total_quantity, total_amount, created_at',
          )
          .single();

      // Step B: Retrieve the new UUID from response
      final newOrderId = orderResponse['id'] as String;

      // Step C: Prepare order details with the new order_id
      final orderDetailsData = <Map<String, dynamic>>[];
      for (final item in items) {
        final itemData = item.toJson();
        itemData.remove('id'); // Will be auto-generated as UUID
        itemData.remove('created_at'); // Will be auto-generated
        itemData.remove('updated_at'); // Will be auto-generated
        itemData['order_id'] = newOrderId; // Assign the new order_id
        orderDetailsData.add(itemData);
      }

      // Step D: Batch insert all items into public.order_details
      final orderDetailsResponse = await _supabaseService.client
          .from('order_details')
          .insert(orderDetailsData)
          .select(
            'id, order_id, product_id, requested_quantity, unit_price, subtotal',
          );

      if (orderDetailsResponse.isEmpty) {
        // If Step D fails, we should rollback Step A
        await _rollbackOrder(newOrderId);
        throw Exception(
          'Gagal menyimpan detail pesanan. Order telah dibatalkan.',
        );
      }

      return newOrderId;
    } catch (e) {
      // Re-throw with clear error message
      if (e.toString().contains('Insufficient stock')) {
        rethrow; // Stock validation error
      } else if (e.toString().contains('Gagal menyimpan detail pesanan')) {
        rethrow; // Order details error with rollback
      } else {
        throw Exception('Gagal membuat pesanan: ${e.toString()}');
      }
    }
  }

  /// Validate product stock before creating order
  Future<void> _validateProductStock(List<OrderDetail> items) async {
    for (final item in items) {
      try {
        final product = await _supabaseService.client
            .from('products')
            .select('id, name, stock_quantity')
            .eq('id', item.productId)
            .single();

        final availableStock =
            (product['stock_quantity'] as num?)?.toDouble() ?? 0;

        if (availableStock < item.requestedQuantity) {
          final productName = product['name'] as String? ?? 'Unknown Product';
          throw Exception(
            'Insufficient stock for $productName. Available: $availableStock, Requested: ${item.requestedQuantity}',
          );
        }
      } catch (e) {
        if (e.toString().contains('Insufficient stock')) {
          rethrow;
        }
        throw Exception('Gagal validasi stok produk: ${e.toString()}');
      }
    }
  }

  /// Rollback order if order details insert fails
  Future<void> _rollbackOrder(String orderId) async {
    try {
      await _supabaseService.client.from('orders').delete().eq('id', orderId);
    } catch (e) {
      // Log rollback failure but don't throw to avoid masking original error
      print('Warning: Failed to rollback order $orderId: $e');
    }
  }

  /// Update status pesanan (Admin only)
  Future<Order> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      // Update order status with timestamp for certain statuses
      final updateData = <String, dynamic>{'status': status};

      if (status == 'confirmed') {
        updateData['confirmed_at'] = DateTime.now().toIso8601String();
      } else if (status == 'completed') {
        updateData['completed_at'] = DateTime.now().toIso8601String();
      }

      await _supabaseService.client
          .from('orders')
          .update(updateData)
          .eq('id', orderId);

      // Return updated order
      final updatedOrder = await getOrderById(orderId);
      if (updatedOrder == null) {
        throw Exception('Order tidak ditemukan setelah update');
      }

      return updatedOrder;
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
            .update({
              'confirmed_quantity': item['confirmed_quantity'],
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', item['detail_id']);
      }

      // 2. Hitung ulang total quantity dan amount berdasarkan confirmed_quantity
      final orderDetails = await _supabaseService.client
          .from('order_details')
          .select('confirmed_quantity, unit_price')
          .eq('order_id', orderId);

      double totalConfirmedQuantity = 0;
      double totalAmount = 0;

      for (final detail in orderDetails) {
        final confirmedQuantity = (detail['confirmed_quantity'] as num)
            .toDouble();
        final unitPrice = (detail['unit_price'] as num).toDouble();
        totalConfirmedQuantity += confirmedQuantity;
        totalAmount += confirmedQuantity * unitPrice;
      }

      // 3. Update order dengan confirmed status, quantities, dan timestamps
      await _supabaseService.client
          .from('orders')
          .update({
            'status': 'confirmed',
            'confirmed_quantity': totalConfirmedQuantity,
            'total_amount': totalAmount,
            'confirmed_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);

      // Return updated order
      final updatedOrder = await getOrderById(orderId);
      if (updatedOrder == null) {
        throw Exception('Order tidak ditemukan setelah konfirmasi');
      }

      return updatedOrder;
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
            id, order_number, customer_id, order_date, status, 
            total_quantity, confirmed_quantity, total_amount, 
            admin_notes, customer_notes, confirmed_at, completed_at,
            created_at, updated_at, pickup_address, delivery_address,
            pickup_date, delivery_date, notes,
            profiles:customer_id(id, email, full_name, phone, role),
            order_details(
              id, order_id, product_id, requested_quantity, confirmed_quantity,
              unit_price, subtotal, notes, created_at, updated_at,
              products(id, name, description, price_per_kg, unit, category)
            )
          ''')
          .eq('status', 'confirmed')
          .order('confirmed_at');

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
          .select('role, role_id')
          .eq('id', userId)
          .single();

      final role = userProfile['role'] as String?;

      var queryBuilder = _supabaseService.client.from('orders').select('''
            id, order_number, customer_id, order_date, status, 
            total_quantity, confirmed_quantity, total_amount, 
            admin_notes, customer_notes, confirmed_at, completed_at,
            created_at, updated_at, pickup_address, delivery_address,
            pickup_date, delivery_date, notes,
            profiles:customer_id(id, email, full_name, phone, role),
            order_details(
              id, order_id, product_id, requested_quantity, confirmed_quantity,
              unit_price, subtotal, notes, created_at, updated_at,
              products(id, name, description, price_per_kg, unit, category)
            )
          ''');

      // Filter berdasarkan role
      if (role == 'mitra') {
        // Mitra - hanya lihat pesanan sendiri
        queryBuilder = queryBuilder.eq('customer_id', userId);
      }

      final response = await queryBuilder
          .ilike('order_number', '%$query%')
          .order('order_date', ascending: false);

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
        'shipped': 0,
        'completed': 0,
        'cancelled': 0,
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

  /// Cancel order (Admin/Mitra yang membuat order)
  Future<Order> cancelOrder(String orderId, {String? reason}) async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) throw Exception('User tidak login');

      // Update order status to cancelled
      await _supabaseService.client
          .from('orders')
          .update({
            'status': 'cancelled',
            'admin_notes': reason,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);

      // Return updated order
      final updatedOrder = await getOrderById(orderId);
      if (updatedOrder == null) {
        throw Exception('Order tidak ditemukan setelah cancel');
      }

      return updatedOrder;
    } catch (e) {
      throw Exception('Gagal cancel pesanan: $e');
    }
  }

  /// Generate unique order number
  String generateOrderNumber() {
    return _supabaseService.generateOrderNumber();
  }

  /// Get orders by status for specific user
  Future<List<Order>> getOrdersByStatus(String status) async {
    return getOrders(status: status);
  }

  /// Get orders for current user (Mitra only)
  Future<List<Order>> getMyOrders({String? status}) async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) throw Exception('User tidak login');

      var query = _supabaseService.client
          .from('orders')
          .select('''
            id, order_number, customer_id, order_date, status, 
            total_quantity, confirmed_quantity, total_amount, 
            admin_notes, customer_notes, confirmed_at, completed_at,
            created_at, updated_at, pickup_address, delivery_address,
            pickup_date, delivery_date, notes,
            profiles:customer_id(id, email, full_name, phone, role),
            order_details(
              id, order_id, product_id, requested_quantity, confirmed_quantity,
              unit_price, subtotal, notes, created_at, updated_at,
              products(id, name, description, price_per_kg, unit, category)
            )
          ''')
          .eq('customer_id', userId);

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('order_date', ascending: false);

      return (response as List).map((order) => Order.fromJson(order)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil pesanan saya: $e');
    }
  }
}
