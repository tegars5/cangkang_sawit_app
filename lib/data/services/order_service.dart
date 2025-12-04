import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';

class OrderService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Order>> getOrders() async {
    final response = await _supabase
        .from('orders')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((json) => Order.fromJson(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getOrderDetails(String orderId) async {
    final response = await _supabase
        .from('order_details')
        .select()
        .eq('order_id', orderId);

    return (response as List).cast<Map<String, dynamic>>();
  }
}
