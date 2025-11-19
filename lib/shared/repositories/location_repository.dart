import '../models/driver_location.dart';
import '../../core/services/supabase_service.dart';

/// Repository untuk mengelola operasi Driver Location
class LocationRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;

  /// Save location update dari driver
  Future<DriverLocation> saveLocation({
    required String driverId,
    required double latitude,
    required double longitude,
    String? shipmentId,
    double? accuracy,
    double? speed,
    double? bearing,
  }) async {
    try {
      final response = await _supabaseService.client
          .from('driver_locations')
          .insert({
            'driver_id': driverId,
            'shipment_id': shipmentId,
            'latitude': latitude,
            'longitude': longitude,
            'accuracy': accuracy,
            'speed': speed,
            'bearing': bearing,
            'timestamp': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return DriverLocation.fromJson(response);
    } catch (e) {
      throw Exception('Gagal menyimpan lokasi: $e');
    }
  }

  /// Get latest location untuk driver tertentu
  Future<DriverLocation?> getLatestLocation(String driverId) async {
    try {
      final response = await _supabaseService.client
          .from('driver_locations')
          .select()
          .eq('driver_id', driverId)
          .eq('is_active', true)
          .order('timestamp', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return DriverLocation.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil lokasi driver: $e');
    }
  }

  /// Get location history untuk driver tertentu
  Future<List<DriverLocation>> getLocationHistory({
    required String driverId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      var query = _supabaseService.client
          .from('driver_locations')
          .select()
          .eq('driver_id', driverId)
          .eq('is_active', true);

      if (startDate != null) {
        query = query.gte('timestamp', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('timestamp', endDate.toIso8601String());
      }

      final response = await query
          .order('timestamp', ascending: false)
          .limit(limit);

      return (response as List)
          .map((location) => DriverLocation.fromJson(location))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil riwayat lokasi: $e');
    }
  }

  /// Get semua driver locations yang aktif untuk admin tracking
  Future<List<DriverLocation>> getAllActiveLocations() async {
    try {
      final response = await _supabaseService.client
          .from('driver_locations')
          .select('''
            *,
            profiles:driver_id(full_name)
          ''')
          .eq('is_active', true)
          .order('timestamp', ascending: false);

      // Group by driver_id dan ambil yang paling recent
      final Map<String, DriverLocation> latestLocations = {};
      for (final locationData in response) {
        final location = DriverLocation.fromJson(locationData);
        final driverId = location.driverId;

        if (!latestLocations.containsKey(driverId) ||
            location.timestamp.isAfter(latestLocations[driverId]!.timestamp)) {
          latestLocations[driverId] = location;
        }
      }

      return latestLocations.values.toList();
    } catch (e) {
      throw Exception('Gagal mengambil lokasi semua driver: $e');
    }
  }

  /// Get locations untuk shipment tertentu
  Future<List<DriverLocation>> getShipmentLocations(String shipmentId) async {
    try {
      final response = await _supabaseService.client
          .from('driver_locations')
          .select()
          .eq('shipment_id', shipmentId)
          .eq('is_active', true)
          .order('timestamp', ascending: true);

      return (response as List)
          .map((location) => DriverLocation.fromJson(location))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil lokasi shipment: $e');
    }
  }

  /// Update multiple locations sebagai inactive (cleanup old data)
  Future<void> deactivateOldLocations({
    required String driverId,
    required DateTime before,
  }) async {
    try {
      await _supabaseService.client
          .from('driver_locations')
          .update({'is_active': false})
          .eq('driver_id', driverId)
          .lt('timestamp', before.toIso8601String());
    } catch (e) {
      throw Exception('Gagal cleanup lokasi lama: $e');
    }
  }

  /// Start real-time subscription untuk location updates
  Stream<DriverLocation> subscribeToDriverLocation(String driverId) {
    return _supabaseService.client
        .from('driver_locations')
        .stream(primaryKey: ['id'])
        .map((List<Map<String, dynamic>> data) {
          // Filter untuk driver_id dan is_active = true
          final filtered = data
              .where(
                (location) =>
                    location['driver_id'] == driverId &&
                    location['is_active'] == true,
              )
              .toList();

          if (filtered.isEmpty) {
            throw Exception('No location data');
          }

          // Sort by timestamp dan ambil yang terbaru
          filtered.sort((a, b) {
            final aTime = DateTime.parse(a['timestamp'] as String);
            final bTime = DateTime.parse(b['timestamp'] as String);
            return bTime.compareTo(aTime); // Descending
          });

          return DriverLocation.fromJson(filtered.first);
        });
  }

  /// Subscribe ke semua active driver locations untuk admin
  Stream<List<DriverLocation>> subscribeToAllDriverLocations() {
    return _supabaseService.client
        .from('driver_locations')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('timestamp')
        .map((List<Map<String, dynamic>> data) {
          // Group by driver dan ambil yang terbaru
          final Map<String, DriverLocation> latestLocations = {};
          for (final locationData in data) {
            final location = DriverLocation.fromJson(locationData);
            final driverId = location.driverId;

            if (!latestLocations.containsKey(driverId) ||
                location.timestamp.isAfter(
                  latestLocations[driverId]!.timestamp,
                )) {
              latestLocations[driverId] = location;
            }
          }
          return latestLocations.values.toList();
        });
  }

  /// Bulk save locations (untuk offline sync)
  Future<List<DriverLocation>> saveMultipleLocations(
    List<Map<String, dynamic>> locations,
  ) async {
    try {
      final response = await _supabaseService.client
          .from('driver_locations')
          .insert(locations)
          .select();

      return (response as List)
          .map((location) => DriverLocation.fromJson(location))
          .toList();
    } catch (e) {
      throw Exception('Gagal menyimpan multiple lokasi: $e');
    }
  }
}
