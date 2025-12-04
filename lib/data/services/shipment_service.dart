import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/shipment.dart';

class ShipmentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Shipment>> getShipments() async {
    final response = await _supabase
        .from('shipments')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((json) => Shipment.fromJson(json)).toList();
  }

  Future<void> startShipment(String orderId, String driverId) async {
    await _supabase.from('shipments').insert({
      'order_id': orderId,
      'driver_id': driverId,
      'delivery_note_number': 'DN-${DateTime.now().millisecondsSinceEpoch}',
      'status': 'pending',
    });
  }

  Future<void> updateShipmentStatus(String shipmentId, String status) async {
    await _supabase
        .from('shipments')
        .update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', shipmentId);
  }
}
