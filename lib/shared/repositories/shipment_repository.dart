import '../models/models.dart';
import '../../core/services/supabase_service.dart';

/// Repository untuk mengelola operasi Shipment
class ShipmentRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;

  /// Get semua shipment (Admin) atau shipment yang ditugaskan (Driver)
  Future<List<Shipment>> getShipments({String? status}) async {
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

      var query = _supabaseService.client.from('shipments').select('''
            *,
            driver_profile:driver_id(nama_lengkap, telepon),
            orders(
              nomor_pesanan,
              profiles:mitra_bisnis_id(nama_lengkap, telepon)
            )
          ''');

      // Filter berdasarkan role
      if (roleId == 3) {
        // Driver - hanya lihat tugasnya sendiri
        query = query.eq('driver_id', userId);
      }
      // Admin (role_id = 1) bisa lihat semua shipment

      // Filter berdasarkan status jika ada
      if (status != null) {
        query = query.eq('status_pengiriman', status);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((shipment) => Shipment.fromJson(shipment))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data pengiriman: $e');
    }
  }

  /// Get shipment berdasarkan ID
  Future<Shipment?> getShipmentById(int shipmentId) async {
    try {
      final response = await _supabaseService.client
          .from('shipments')
          .select('''
            *,
            driver_profile:driver_id(nama_lengkap, telepon),
            orders(
              nomor_pesanan,
              profiles:mitra_bisnis_id(nama_lengkap, telepon),
              order_details(
                *,
                products(nama_produk, satuan)
              )
            )
          ''')
          .eq('shipment_id', shipmentId)
          .single();

      return Shipment.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil pengiriman: $e');
    }
  }

  /// Get shipment berdasarkan order ID
  Future<Shipment?> getShipmentByOrderId(int orderId) async {
    try {
      final response = await _supabaseService.client
          .from('shipments')
          .select('''
            *,
            driver_profile:driver_id(nama_lengkap, telepon),
            orders(
              nomor_pesanan,
              profiles:mitra_bisnis_id(nama_lengkap, telepon)
            )
          ''')
          .eq('order_id', orderId)
          .single();

      return Shipment.fromJson(response);
    } catch (e) {
      return null; // Shipment belum ada
    }
  }

  /// Create shipment baru (Admin only)
  Future<Shipment> createShipment({
    required int orderId,
    required String driverId,
    required String suratJalanPath, // Path file PDF surat jalan
    String? alamatTujuan,
    String? catatanPengiriman,
  }) async {
    try {
      // 1. Upload surat jalan ke storage
      final fileName =
          'surat_jalan_${orderId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final urlSuratJalan = await _supabaseService.uploadFile(
        bucketName: 'surat-jalan',
        filePath: suratJalanPath,
        fileName: fileName,
      );

      // 2. Generate nomor surat jalan
      final nomorSuratJalan = _supabaseService.generateSuratJalanNumber();

      // 3. Create shipment
      final response = await _supabaseService.client
          .from('shipments')
          .insert({
            'order_id': orderId,
            'driver_id': driverId,
            'nomor_surat_jalan': nomorSuratJalan,
            'url_surat_jalan': urlSuratJalan,
            'status_pengiriman': 'Menunggu',
            'alamat_tujuan': alamatTujuan,
            'catatan_pengiriman': catatanPengiriman,
          })
          .select()
          .single();

      // 4. Update status order menjadi 'Dikirim'
      await _supabaseService.client
          .from('orders')
          .update({'status_pesanan': 'Dikirim'})
          .eq('order_id', orderId);

      return Shipment.fromJson(response);
    } catch (e) {
      throw Exception('Gagal membuat pengiriman: $e');
    }
  }

  /// Start pengiriman (Driver only)
  Future<Shipment> startShipment(int shipmentId) async {
    try {
      final response = await _supabaseService.client
          .from('shipments')
          .update({
            'status_pengiriman': 'Dalam Perjalanan',
            'tanggal_kirim': DateTime.now().toIso8601String(),
          })
          .eq('shipment_id', shipmentId)
          .select()
          .single();

      return Shipment.fromJson(response);
    } catch (e) {
      throw Exception('Gagal memulai pengiriman: $e');
    }
  }

  /// Complete pengiriman dengan upload bukti (Driver only)
  Future<Shipment> completeShipment({
    required int shipmentId,
    required String buktiKirimPath, // Path file foto bukti kirim
  }) async {
    try {
      // 1. Upload bukti kirim ke storage
      final fileName =
          'bukti_kirim_${shipmentId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final urlBuktiKirim = await _supabaseService.uploadFile(
        bucketName: 'bukti-kirim',
        filePath: buktiKirimPath,
        fileName: fileName,
      );

      // 2. Update shipment
      final response = await _supabaseService.client
          .from('shipments')
          .update({
            'status_pengiriman': 'Tiba',
            'url_bukti_kirim': urlBuktiKirim,
            'tanggal_tiba': DateTime.now().toIso8601String(),
          })
          .eq('shipment_id', shipmentId)
          .select()
          .single();

      // 3. Update status order menjadi 'Selesai'
      final shipment = Shipment.fromJson(response);
      await _supabaseService.client
          .from('orders')
          .update({'status_pesanan': 'Selesai'})
          .eq('order_id', shipment.orderId);

      return shipment;
    } catch (e) {
      throw Exception('Gagal menyelesaikan pengiriman: $e');
    }
  }

  /// Get driver locations untuk tracking
  Future<List<DriverLocation>> getDriverLocations(String driverId) async {
    try {
      final response = await _supabaseService.client
          .from('driver_locations')
          .select()
          .eq('driver_id', driverId)
          .order('timestamp', ascending: false)
          .limit(100); // Ambil 100 lokasi terakhir

      return (response as List)
          .map((location) => DriverLocation.fromJson(location))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil lokasi driver: $e');
    }
  }

  /// Get latest driver location
  Future<DriverLocation?> getLatestDriverLocation(String driverId) async {
    try {
      final response = await _supabaseService.client
          .from('driver_locations')
          .select()
          .eq('driver_id', driverId)
          .order('timestamp', ascending: false)
          .limit(1)
          .single();

      return DriverLocation.fromJson(response);
    } catch (e) {
      return null; // Belum ada lokasi
    }
  }

  /// Insert driver location (Driver only - untuk background service)
  Future<void> insertDriverLocation({
    required double latitude,
    required double longitude,
    double? speed,
    double? accuracy,
    int? shipmentId,
  }) async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) throw Exception('User tidak login');

      await _supabaseService.client.from('driver_locations').insert({
        'driver_id': userId,
        'latitude': latitude,
        'longitude': longitude,
        'speed': speed,
        'accuracy': accuracy,
        'shipment_id': shipmentId,
      });
    } catch (e) {
      throw Exception('Gagal menyimpan lokasi: $e');
    }
  }

  /// Get active shipment untuk driver (yang sedang dalam perjalanan)
  Future<Shipment?> getActiveShipmentForDriver() async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) throw Exception('User tidak login');

      final response = await _supabaseService.client
          .from('shipments')
          .select('''
            *,
            orders(
              nomor_pesanan,
              profiles:mitra_bisnis_id(nama_lengkap, telepon)
            )
          ''')
          .eq('driver_id', userId)
          .eq('status_pengiriman', 'Dalam Perjalanan')
          .single();

      return Shipment.fromJson(response);
    } catch (e) {
      return null; // Tidak ada shipment aktif
    }
  }

  /// Get statistik pengiriman (Admin only)
  Future<Map<String, int>> getShipmentStatistics() async {
    try {
      final response = await _supabaseService.client
          .from('shipments')
          .select('status_pengiriman');

      final Map<String, int> stats = {
        'Menunggu': 0,
        'Dalam Perjalanan': 0,
        'Tiba': 0,
      };

      for (final shipment in response) {
        final status = shipment['status_pengiriman'] as String;
        if (stats.containsKey(status)) {
          stats[status] = (stats[status] ?? 0) + 1;
        }
      }

      return stats;
    } catch (e) {
      throw Exception('Gagal mengambil statistik pengiriman: $e');
    }
  }

  /// Subscribe ke perubahan driver location (untuk real-time tracking)
  Stream<List<DriverLocation>> subscribeToDriverLocation(String driverId) {
    return _supabaseService.client
        .from('driver_locations')
        .stream(primaryKey: ['location_id'])
        .eq('driver_id', driverId)
        .order('timestamp', ascending: false)
        .limit(1)
        .map(
          (data) => data
              .map((location) => DriverLocation.fromJson(location))
              .toList(),
        );
  }
}
