import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

/// Service untuk Admin Dashboard dengan real-time data dari Supabase
class AdminDashboardService {
  static final _supabase = Supabase.instance.client;

  /// Get dashboard statistics
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Get total orders dengan column name yang benar
      final orders = await _supabase
          .from('orders')
          .select('order_id, status_pesanan, total_harga');

      // Count orders by status
      int totalOrders = orders.length;
      int pendingOrders = orders
          .where(
            (order) =>
                order['status_pesanan'] == 'Baru' ||
                order['status_pesanan'] == 'Pending',
          )
          .length;
      int confirmedOrders = orders
          .where((order) => order['status_pesanan'] == 'Dikonfirmasi')
          .length;
      int shippedOrders = orders
          .where((order) => order['status_pesanan'] == 'Dikirim')
          .length;
      int completedOrders = orders
          .where((order) => order['status_pesanan'] == 'Selesai')
          .length;

      // Calculate total revenue
      double totalRevenue = 0;
      for (var order in orders) {
        if (order['total_harga'] != null) {
          totalRevenue += (order['total_harga'] as num).toDouble();
        }
      }

      // Get total products
      final products = await _supabase.from('products').select('id');
      int totalProducts = products.length;

      // Get total users by role
      final profiles = await _supabase
          .from('profiles')
          .select('profile_id, role_id, roles!inner(role_id, name)');

      int totalUsers = profiles.length;
      int totalMitra = profiles
          .where(
            (user) =>
                user['roles'] != null &&
                (user['roles']['name']?.toString().toLowerCase() ==
                        'mitra bisnis' ||
                    user['roles']['name']?.toString().toLowerCase() ==
                        'mitra_bisnis'),
          )
          .length;
      int totalDrivers = profiles
          .where(
            (user) =>
                user['roles'] != null &&
                (user['roles']['name']?.toString().toLowerCase() ==
                        'logistik' ||
                    user['roles']['name']?.toString().toLowerCase() ==
                        'driver'),
          )
          .length;

      return {
        'success': true,
        'data': {
          'totalOrders': totalOrders,
          'pendingOrders': pendingOrders,
          'confirmedOrders': confirmedOrders,
          'shippedOrders': shippedOrders,
          'completedOrders': completedOrders,
          'totalRevenue': totalRevenue,
          'totalProducts': totalProducts,
          'totalUsers': totalUsers,
          'totalMitra': totalMitra,
          'totalDrivers': totalDrivers,
        },
      };
    } catch (e) {
      developer.log('Error getting dashboard stats: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get recent orders with details
  static Future<Map<String, dynamic>> getRecentOrders({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            order_id,
            nomor_pesanan,
            total_harga,
            status_pesanan,
            tanggal_pesan,
            mitra_bisnis_id,
            profiles!mitra_bisnis_id(profile_id, full_name, email)
          ''')
          .order('tanggal_pesan', ascending: false)
          .limit(limit);

      final orders = (response as List<dynamic>? ?? []).map((order) {
        return {
          'id': order['order_id']?.toString() ?? '',
          'order_number': order['nomor_pesanan'] ?? '',
          'total_amount': order['total_harga'] ?? 0,
          'status': order['status_pesanan'] ?? '',
          'created_at': order['tanggal_pesan'] ?? '',
          'customer_name':
              order['profiles']?['full_name'] ?? 'Unknown Customer',
          'customer_email': order['profiles']?['email'] ?? '',
        };
      }).toList();

      return {'success': true, 'data': orders};
    } catch (e) {
      developer.log('Error getting recent orders: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get all users with roles
  static Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('''
            profile_id,
            full_name,
            email,
            phone,
            created_at,
            role_id,
            roles!inner(role_id, name)
          ''')
          .order('created_at', ascending: false);

      final users = (response as List<dynamic>? ?? []).map((user) {
        return {
          'id': user['profile_id']?.toString() ?? '',
          'full_name': user['full_name'] ?? '',
          'email': user['email'] ?? '',
          'phone': user['phone'] ?? '',
          'created_at': user['created_at'] ?? '',
          'role': user['roles']?['name'] ?? 'Unknown',
        };
      }).toList();

      return {'success': true, 'data': users};
    } catch (e) {
      developer.log('Error getting all users: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Update order status
  static Future<Map<String, dynamic>> updateOrderStatus(
    String orderId,
    String newStatus,
  ) async {
    try {
      await _supabase
          .from('orders')
          .update({
            'status_pesanan': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('order_id', orderId);

      developer.log('Order $orderId status updated to $newStatus');
      return {'success': true, 'message': 'Status pesanan berhasil diupdate'};
    } catch (e) {
      developer.log('Error updating order status: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get products with stock info
  static Future<Map<String, dynamic>> getProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select('id, nama_produk, harga, satuan, is_active, created_at')
          .order('nama_produk');

      final products = (response as List<dynamic>? ?? []).map((product) {
        return {
          'id': product['id']?.toString() ?? '',
          'name': product['nama_produk'] ?? '',
          'price_per_kg': product['harga'] ?? 0,
          'unit': product['satuan'] ?? 'ton',
          'is_active': product['is_active'] ?? true,
          'created_at': product['created_at'] ?? '',
        };
      }).toList();

      return {'success': true, 'data': products};
    } catch (e) {
      developer.log('Error getting products: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Add new product
  static Future<Map<String, dynamic>> addProduct({
    required String name,
    required String description,
    required double pricePerKg,
    String unit = 'ton',
  }) async {
    try {
      await _supabase.from('products').insert({
        'nama_produk': name,
        'harga': pricePerKg,
        'satuan': unit,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      });

      developer.log('Product added: $name');
      return {'success': true, 'message': 'Produk berhasil ditambahkan'};
    } catch (e) {
      developer.log('Error adding product: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Update product
  static Future<Map<String, dynamic>> updateProduct({
    required String productId,
    required String name,
    required double pricePerKg,
    String? unit,
  }) async {
    try {
      final updateData = {
        'nama_produk': name,
        'harga': pricePerKg,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (unit != null) {
        updateData['satuan'] = unit;
      }

      await _supabase.from('products').update(updateData).eq('id', productId);

      developer.log('Product updated: $productId');
      return {'success': true, 'message': 'Produk berhasil diupdate'};
    } catch (e) {
      developer.log('Error updating product: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Delete product
  static Future<Map<String, dynamic>> deleteProduct(String productId) async {
    try {
      // Soft delete: set is_active to false
      await _supabase
          .from('products')
          .update({'is_active': false})
          .eq('id', productId);

      developer.log('Product deleted (soft): $productId');
      return {'success': true, 'message': 'Produk berhasil dihapus'};
    } catch (e) {
      developer.log('Error deleting product: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get delivery assignments (shipments)
  static Future<Map<String, dynamic>> getDeliveries() async {
    try {
      final response = await _supabase
          .from('shipments')
          .select('''
            shipment_id,
            nomor_surat_jalan,
            status_pengiriman,
            tanggal_kirim,
            tanggal_tiba,
            alamat_tujuan,
            order_id,
            driver_id,
            profiles!driver_id(profile_id, full_name, phone),
            orders!inner(order_id, nomor_pesanan)
          ''')
          .order('tanggal_kirim', ascending: false);

      final deliveries = (response as List<dynamic>? ?? []).map((shipment) {
        return {
          'id': shipment['shipment_id']?.toString() ?? '',
          'delivery_note_number': shipment['nomor_surat_jalan'] ?? '',
          'status': shipment['status_pengiriman'] ?? '',
          'pickup_date': shipment['tanggal_kirim'] ?? '',
          'delivery_date': shipment['tanggal_tiba'] ?? '',
          'destination': shipment['alamat_tujuan'] ?? '',
          'order_number':
              shipment['orders']?['nomor_pesanan'] ?? 'Unknown Order',
          'driver_name': shipment['profiles']?['full_name'] ?? 'Unassigned',
          'driver_phone': shipment['profiles']?['phone'] ?? '',
        };
      }).toList();

      return {'success': true, 'data': deliveries};
    } catch (e) {
      developer.log('Error getting deliveries: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get order details untuk confirmation
  static Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      final orderResponse = await _supabase
          .from('orders')
          .select('''
            order_id,
            nomor_pesanan,
            mitra_bisnis_id,
            tanggal_pesan,
            status_pesanan,
            total_harga,
            catatan,
            created_at,
            profiles!mitra_bisnis_id(profile_id, full_name, email, phone, address)
          ''')
          .eq('order_id', orderId)
          .maybeSingle();

      if (orderResponse == null) {
        return {'success': false, 'error': 'Order not found'};
      }

      // Get order details (items)
      final detailsResponse = await _supabase
          .from('order_details')
          .select('''
            detail_id,
            product_id,
            jumlah_dipesan,
            jumlah_diterima,
            harga_satuan,
            products(id, nama_produk, harga, satuan)
          ''')
          .eq('order_id', orderId);

      final orderData = {
        'id': orderResponse['order_id']?.toString() ?? '',
        'order_number': orderResponse['nomor_pesanan'] ?? '',
        'status': orderResponse['status_pesanan'] ?? '',
        'total_amount': orderResponse['total_harga'] ?? 0,
        'notes': orderResponse['catatan'] ?? '',
        'order_date': orderResponse['tanggal_pesan'] ?? '',
        'created_at': orderResponse['created_at'] ?? '',
        'customer': {
          'id': orderResponse['profiles']?['profile_id']?.toString() ?? '',
          'name': orderResponse['profiles']?['full_name'] ?? '',
          'email': orderResponse['profiles']?['email'] ?? '',
          'phone': orderResponse['profiles']?['phone'] ?? '',
          'address': orderResponse['profiles']?['address'] ?? '',
        },
        'items': (detailsResponse as List<dynamic>).map((detail) {
          return {
            'id': detail['detail_id']?.toString() ?? '',
            'product_id': detail['product_id']?.toString() ?? '',
            'product_name': detail['products']?['nama_produk'] ?? '',
            'unit_price': detail['harga_satuan'] ?? 0,
            'ordered_quantity': detail['jumlah_dipesan'] ?? 0,
            'confirmed_quantity': detail['jumlah_diterima'] ?? 0,
            'unit': detail['products']?['satuan'] ?? 'ton',
            'subtotal':
                (detail['harga_satuan'] ?? 0) * (detail['jumlah_dipesan'] ?? 0),
          };
        }).toList(),
      };

      return {'success': true, 'data': orderData};
    } catch (e) {
      developer.log('Error getting order details: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Confirm order dengan update quantities
  static Future<Map<String, dynamic>> confirmOrder(
    String orderId,
    List<Map<String, dynamic>> confirmedItems,
  ) async {
    try {
      // Update order status
      await _supabase
          .from('orders')
          .update({
            'status_pesanan': 'Dikonfirmasi',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('order_id', orderId);

      // Update each order detail with confirmed quantity
      for (var item in confirmedItems) {
        await _supabase
            .from('order_details')
            .update({
              'jumlah_diterima': item['confirmed_quantity'],
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('detail_id', item['detail_id']);
      }

      developer.log('Order confirmed: $orderId');
      return {'success': true, 'message': 'Pesanan berhasil dikonfirmasi'};
    } catch (e) {
      developer.log('Error confirming order: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get available drivers untuk assignment
  static Future<Map<String, dynamic>> getAvailableDrivers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('''
            profile_id,
            full_name,
            email,
            phone,
            role_id,
            roles!inner(role_id, name)
          ''')
          .eq('roles.name', 'logistik')
          .order('full_name');

      final drivers = (response as List<dynamic>? ?? []).map((driver) {
        return {
          'id': driver['profile_id']?.toString() ?? '',
          'name': driver['full_name'] ?? '',
          'email': driver['email'] ?? '',
          'phone': driver['phone'] ?? '',
        };
      }).toList();

      return {'success': true, 'data': drivers};
    } catch (e) {
      developer.log('Error getting available drivers: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Assign shipment to driver
  static Future<Map<String, dynamic>> assignShipment({
    required String orderId,
    required String driverId,
    required String deliveryNoteNumber,
    required String destinationAddress,
    String? notes,
  }) async {
    try {
      // Create shipment
      final shipmentResponse = await _supabase
          .from('shipments')
          .insert({
            'order_id': int.parse(orderId),
            'driver_id': int.parse(driverId),
            'nomor_surat_jalan': deliveryNoteNumber,
            'alamat_tujuan': destinationAddress,
            'status_pengiriman': 'assigned',
            'catatan_pengiriman': notes ?? '',
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      // Update order status to shipped
      await _supabase
          .from('orders')
          .update({
            'status_pesanan': 'Dikirim',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('order_id', orderId);

      developer.log('Shipment assigned: ${shipmentResponse['shipment_id']}');
      return {
        'success': true,
        'message': 'Pengiriman berhasil ditugaskan',
        'shipment_id': shipmentResponse['shipment_id']?.toString() ?? '',
      };
    } catch (e) {
      developer.log('Error assigning shipment: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get pending orders (yang belum dikonfirmasi)
  static Future<Map<String, dynamic>> getPendingOrders() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            order_id,
            nomor_pesanan,
            total_harga,
            status_pesanan,
            tanggal_pesan,
            catatan,
            profiles!mitra_bisnis_id(full_name, email)
          ''')
          .eq('status_pesanan', 'Baru')
          .order('tanggal_pesan', ascending: false);

      final orders = (response as List<dynamic>? ?? []).map((order) {
        return {
          'id': order['order_id']?.toString() ?? '',
          'order_number': order['nomor_pesanan'] ?? '',
          'total_amount': order['total_harga'] ?? 0,
          'status': order['status_pesanan'] ?? '',
          'order_date': order['tanggal_pesan'] ?? '',
          'notes': order['catatan'] ?? '',
          'customer_name': order['profiles']?['full_name'] ?? 'Unknown',
          'customer_email': order['profiles']?['email'] ?? '',
        };
      }).toList();

      return {'success': true, 'data': orders};
    } catch (e) {
      developer.log('Error getting pending orders: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get confirmed orders yang siap untuk di-assign
  static Future<Map<String, dynamic>> getConfirmedOrders() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            order_id,
            nomor_pesanan,
            total_harga,
            status_pesanan,
            tanggal_pesan,
            catatan,
            profiles!mitra_bisnis_id(full_name, email, address)
          ''')
          .eq('status_pesanan', 'Dikonfirmasi')
          .order('tanggal_pesan', ascending: false);

      final orders = (response as List<dynamic>? ?? []).map((order) {
        return {
          'id': order['order_id']?.toString() ?? '',
          'order_number': order['nomor_pesanan'] ?? '',
          'total_amount': order['total_harga'] ?? 0,
          'status': order['status_pesanan'] ?? '',
          'order_date': order['tanggal_pesan'] ?? '',
          'notes': order['catatan'] ?? '',
          'customer_name': order['profiles']?['full_name'] ?? 'Unknown',
          'customer_email': order['profiles']?['email'] ?? '',
          'delivery_address': order['profiles']?['address'] ?? '',
        };
      }).toList();

      return {'success': true, 'data': orders};
    } catch (e) {
      developer.log('Error getting confirmed orders: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Real-time subscription untuk dashboard stats
  static Stream<Map<String, dynamic>> subscribeToStats() {
    return Stream.periodic(const Duration(seconds: 30), (count) async {
      return await getDashboardStats();
    }).asyncMap((futureStats) => futureStats);
  }

  /// Real-time subscription untuk orders
  static Stream<List<Map<String, dynamic>>> subscribeToOrders() {
    return _supabase
        .from('orders')
        .stream(primaryKey: ['order_id'])
        .order('tanggal_pesan', ascending: false)
        .limit(20)
        .map((data) {
          return data.map((order) {
            return {
              'id': order['order_id']?.toString() ?? '',
              'order_number': order['nomor_pesanan'] ?? '',
              'total_amount': order['total_harga'] ?? 0,
              'status': order['status_pesanan'] ?? '',
              'order_date': order['tanggal_pesan'] ?? '',
            };
          }).toList();
        });
  }

  /// Real-time subscription untuk pending orders count
  static Stream<int> subscribeToPendingOrdersCount() {
    return _supabase
        .from('orders')
        .stream(primaryKey: ['order_id'])
        .eq('status_pesanan', 'Baru')
        .map((data) => data.length);
  }

  /// Get shipment tracking data
  static Future<Map<String, dynamic>> getShipmentTracking(
    String shipmentId,
  ) async {
    try {
      final shipmentResponse = await _supabase
          .from('shipments')
          .select('''
            shipment_id,
            nomor_surat_jalan,
            status_pengiriman,
            tanggal_kirim,
            tanggal_tiba,
            alamat_tujuan,
            catatan_pengiriman,
            url_bukti_kirim,
            url_surat_jalan,
            order_id,
            driver_id,
            profiles!driver_id(profile_id, full_name, phone),
            orders!inner(order_id, nomor_pesanan)
          ''')
          .eq('shipment_id', shipmentId)
          .maybeSingle();

      if (shipmentResponse == null) {
        return {'success': false, 'error': 'Shipment not found'};
      }

      // Get latest driver location
      final locationResponse = await _supabase
          .from('driver_locations')
          .select('''
            location_id,
            latitude,
            longitude,
            timestamp,
            speed,
            bearing
          ''')
          .eq('driver_id', shipmentResponse['driver_id'])
          .order('timestamp', ascending: false)
          .limit(1)
          .maybeSingle();

      final trackingData = {
        'id': shipmentResponse['shipment_id']?.toString() ?? '',
        'delivery_note_number': shipmentResponse['nomor_surat_jalan'] ?? '',
        'status': shipmentResponse['status_pengiriman'] ?? '',
        'pickup_date': shipmentResponse['tanggal_kirim'] ?? '',
        'delivery_date': shipmentResponse['tanggal_tiba'] ?? '',
        'destination': shipmentResponse['alamat_tujuan'] ?? '',
        'notes': shipmentResponse['catatan_pengiriman'] ?? '',
        'delivery_photo_url': shipmentResponse['url_bukti_kirim'] ?? '',
        'delivery_note_url': shipmentResponse['url_surat_jalan'] ?? '',
        'order_number':
            shipmentResponse['orders']?['nomor_pesanan'] ?? 'Unknown',
        'driver': {
          'id': shipmentResponse['driver_id']?.toString() ?? '',
          'name': shipmentResponse['profiles']?['full_name'] ?? '',
          'phone': shipmentResponse['profiles']?['phone'] ?? '',
        },
        'current_location': locationResponse != null
            ? {
                'latitude': locationResponse['latitude'] ?? 0.0,
                'longitude': locationResponse['longitude'] ?? 0.0,
                'timestamp': locationResponse['timestamp'] ?? '',
                'speed': locationResponse['speed'] ?? 0.0,
                'bearing': locationResponse['bearing'] ?? 0.0,
              }
            : null,
      };

      return {'success': true, 'data': trackingData};
    } catch (e) {
      developer.log('Error getting shipment tracking: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Real-time subscription untuk driver locations
  static Stream<List<Map<String, dynamic>>> subscribeToDriverLocations() {
    return _supabase
        .from('driver_locations')
        .stream(primaryKey: ['location_id'])
        .eq('is_active', true)
        .order('timestamp', ascending: false)
        .map((data) {
          // Group by driver_id and get latest location for each
          final Map<String, Map<String, dynamic>> latestLocations = {};

          for (var location in data) {
            final driverId = location['driver_id']?.toString() ?? '';
            if (driverId.isNotEmpty) {
              if (!latestLocations.containsKey(driverId) ||
                  DateTime.parse(location['timestamp'] ?? '').isAfter(
                    DateTime.parse(
                      latestLocations[driverId]!['timestamp'] ?? '',
                    ),
                  )) {
                latestLocations[driverId] = {
                  'driver_id': driverId,
                  'latitude': location['latitude'] ?? 0.0,
                  'longitude': location['longitude'] ?? 0.0,
                  'timestamp': location['timestamp'] ?? '',
                  'speed': location['speed'] ?? 0.0,
                  'bearing': location['bearing'] ?? 0.0,
                };
              }
            }
          }

          return latestLocations.values.toList();
        });
  }

  /// Cancel order (hanya untuk status Baru)
  static Future<Map<String, dynamic>> cancelOrder(
    String orderId,
    String reason,
  ) async {
    try {
      // Check current status
      final orderResponse = await _supabase
          .from('orders')
          .select('status_pesanan')
          .eq('order_id', orderId)
          .maybeSingle();

      if (orderResponse == null) {
        return {'success': false, 'error': 'Order not found'};
      }

      if (orderResponse['status_pesanan'] != 'Baru') {
        return {
          'success': false,
          'error': 'Hanya pesanan dengan status Baru yang bisa dibatalkan',
        };
      }

      await _supabase
          .from('orders')
          .update({
            'status_pesanan': 'Dibatalkan',
            'catatan':
                '${orderResponse['catatan'] ?? ''}\n[Dibatalkan: $reason]',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('order_id', orderId);

      developer.log('Order cancelled: $orderId');
      return {'success': true, 'message': 'Pesanan berhasil dibatalkan'};
    } catch (e) {
      developer.log('Error cancelling order: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
