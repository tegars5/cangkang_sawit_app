import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../shared/models/models.dart';

/// Remote data source for Order operations
/// Handles all Supabase/API calls related to orders
class OrderRemoteDataSource {
  final SupabaseClient _client;

  OrderRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Get all orders with optional filtering
  Future<List<Order>> getOrders({String? status, String? customerId}) async {
    try {
      var query = _client.from('orders').select('''
            *,
            profiles:customer_id(*),
            order_details(*)
          ''');

      if (status != null) {
        query = query.eq('status', status);
      }

      if (customerId != null) {
        query = query.eq('customer_id', customerId);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => Order.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Failed to get orders: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get orders: $e');
    }
  }

  /// Get order by ID with full details
  Future<Order> getOrderById(String orderId) async {
    try {
      final response = await _client
          .from('orders')
          .select('''
            *,
            profiles:customer_id(*),
            order_details(*)
          ''')
          .eq('id', orderId)
          .single();

      return Order.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw NotFoundException('Order not found');
      }
      throw ServerException('Failed to get order: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get order: $e');
    }
  }

  /// Create new order with items
  Future<Order> createOrder({
    required Order order,
    required List<OrderDetail> items,
  }) async {
    try {
      // 1. Insert order
      final orderResponse = await _client
          .from('orders')
          .insert(order.toJson())
          .select()
          .single();

      final createdOrder = Order.fromJson(
        orderResponse as Map<String, dynamic>,
      );

      // 2. Insert order details
      final orderDetailsData = items.map((item) {
        final json = item.toJson();
        json['order_id'] = createdOrder.id;
        return json;
      }).toList();

      await _client.from('order_details').insert(orderDetailsData);

      // 3. Create shipment automatically
      await _createShipment(createdOrder.id);

      // 4. Return order with details
      return await getOrderById(createdOrder.id);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to create order: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to create order: $e');
    }
  }

  /// Confirm order with confirmed quantities
  Future<Order> confirmOrder({
    required String orderId,
    required List<Map<String, dynamic>> confirmedItems,
  }) async {
    try {
      // 1. Update order details with confirmed quantities
      for (final item in confirmedItems) {
        await _client
            .from('order_details')
            .update({
              'confirmed_quantity': item['confirmed_quantity'],
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', item['detail_id']);
      }

      // 2. Calculate totals
      final orderDetails = await _client
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

      // 3. Update order
      await _client
          .from('orders')
          .update({
            'status': 'confirmed',
            'confirmed_quantity': totalConfirmedQuantity,
            'total_amount': totalAmount,
            'confirmed_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);

      return await getOrderById(orderId);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to confirm order: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to confirm order: $e');
    }
  }

  /// Cancel order
  Future<Order> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    try {
      await _client
          .from('orders')
          .update({
            'status': 'cancelled',
            'notes': reason,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);

      return await getOrderById(orderId);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to cancel order: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to cancel order: $e');
    }
  }

  /// Update order status
  Future<Order> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    try {
      await _client
          .from('orders')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);

      return await getOrderById(orderId);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to update order status: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to update order status: $e');
    }
  }

  /// Private: Create shipment for order
  Future<void> _createShipment(String orderId) async {
    try {
      // Generate delivery note number
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final deliveryNote = 'DN-$timestamp';

      await _client.from('shipments').insert({
        'order_id': orderId,
        'delivery_note_number': deliveryNote,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Don't throw, just log (shipment creation is optional)
      print('Warning: Failed to create shipment: $e');
    }
  }
}
