import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/driver_location.dart';

class DriverLocationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> updateLocation(String driverId, double lat, double lng) async {
    await _supabase.from('driver_locations').insert({
      'driver_id': driverId,
      'latitude': lat,
      'longitude': lng,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<DriverLocation>> streamLocation(String driverId) {
    return _supabase
        .from('driver_locations')
        .stream(primaryKey: ['id'])
        .eq('driver_id', driverId)
        .order('timestamp', ascending: false)
        .limit(1)
        .map(
          (data) => data.map((json) => DriverLocation.fromJson(json)).toList(),
        );
  }
}
