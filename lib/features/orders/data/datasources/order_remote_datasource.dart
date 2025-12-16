import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/order_model.dart';

/// Abstract interface for Order remote data source
abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrders({String? customerId, String? status});
  Future<OrderModel> getOrderById(String id);
  Future<OrderModel> createOrder(OrderModel order);
  Future<OrderModel> confirmOrder(String id, double confirmedQuantity);
  Future<OrderModel> cancelOrder(String id, String reason);
  Future<OrderModel> updateOrderStatus(String id, String status);
}

/// Implementation of OrderRemoteDataSource using Supabase
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final SupabaseClient client;

  OrderRemoteDataSourceImpl({required this.client});

  @override
  Future<List<OrderModel>> getOrders({
    String? customerId,
    String? status,
  }) async {
    try {
      var query = client.from('orders').select('''
            *,
            profiles:customer_id(*),
            order_details(*)
          ''');

      if (customerId != null) {
        query = query.eq('customer_id', customerId);
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Failed to get orders: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get orders: $e');
    }
  }

  @override
  Future<OrderModel> getOrderById(String id) async {
    try {
      final response = await client
          .from('orders')
          .select('''
            *,
            profiles:customer_id(*),
            order_details(*)
          ''')
          .eq('id', id)
          .single();

      return OrderModel.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw NotFoundException('Order not found');
      }
      throw ServerException('Failed to get order: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get order: $e');
    }
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final orderResponse = await client
          .from('orders')
          .insert(order.toJson())
          .select()
          .single();

      return OrderModel.fromJson(orderResponse as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to create order: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to create order: $e');
    }
  }

  @override
  Future<OrderModel> confirmOrder(String id, double confirmedQuantity) async {
    try {
      await client
          .from('orders')
          .update({
            'status': 'confirmed',
            'confirmed_quantity': confirmedQuantity,
            'confirmed_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      return await getOrderById(id);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to confirm order: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to confirm order: $e');
    }
  }

  @override
  Future<OrderModel> cancelOrder(String id, String reason) async {
    try {
      await client
          .from('orders')
          .update({
            'status': 'cancelled',
            'admin_notes': reason,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      return await getOrderById(id);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to cancel order: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to cancel order: $e');
    }
  }

  @override
  Future<OrderModel> updateOrderStatus(String id, String status) async {
    try {
      await client
          .from('orders')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      return await getOrderById(id);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to update order status: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to update order status: $e');
    }
  }
}
