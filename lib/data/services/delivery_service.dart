import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/delivery.dart';

class DeliveryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Delivery>> getDeliveries() async {
    final response = await _supabase
        .from('deliveries')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((json) => Delivery.fromJson(json)).toList();
  }

  Future<void> updateDeliveryStatus(String deliveryId, String status) async {
    await _supabase
        .from('deliveries')
        .update({'status': status})
        .eq('id', deliveryId);
  }
}
