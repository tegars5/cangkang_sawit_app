import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

/// Complete AdminService with all required methods for admin operations
class AdminService {
  static final _supabase = Supabase.instance.client;

  /// Get dashboard statistics with real Supabase queries
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // 1. Get orders data
      final ordersResponse = await _supabase
          .from('orders')
          .select('order_id, status_pesanan, total_harga');

      final orders = ordersResponse as List;

      // Count orders by status
      int totalOrders = orders.length;
      int pendingOrders = orders
          .where(
            (order) =>
                order['status_pesanan'] == 'Baru' ||
                order['status_pesanan'] == 'Pending' ||
                order['status_pesanan'] == 'pending',
          )
          .length;
      int activeShipments = orders
          .where(
            (order) =>
                order['status_pesanan'] == 'Dikirim' ||
                order['status_pesanan'] == 'shipped' ||
                order['status_pesanan'] == 'in_transit',
          )
          .length;
      int completedOrders = orders
          .where(
            (order) =>
                order['status_pesanan'] == 'Selesai' ||
                order['status_pesanan'] == 'completed',
          )
          .length;

      // Calculate total revenue
      double totalRevenue = 0;
      for (var order in orders) {
        if (order['total_harga'] != null) {
          totalRevenue += (order['total_harga'] as num).toDouble();
        }
      }

      // 2. Get products count
      final productsResponse = await _supabase.from('products').select('id');
      int totalProducts = (productsResponse as List).length;

      // 3. Get users count by role - using simple role column
      final profilesResponse = await _supabase
          .from('profiles')
          .select('profile_id, role');

      final profiles = profilesResponse as List;
      int totalUsers = profiles.length;
      int totalMitra = profiles
          .where(
            (user) =>
                user['role'] != null &&
                (user['role'].toString().toLowerCase().contains('mitra') ||
                    user['role'].toString().toLowerCase().contains('bisnis')),
          )
          .length;
      int totalDrivers = profiles
          .where(
            (user) =>
                user['role'] != null &&
                (user['role'].toString().toLowerCase().contains('logistik') ||
                    user['role'].toString().toLowerCase().contains('driver')),
          )
          .length;

      return {
        'success': true,
        'data': {
          'total_orders': totalOrders,
          'pending_orders': pendingOrders,
          'active_shipments': activeShipments,
          'completed_orders': completedOrders,
          'total_products': totalProducts,
          'total_users': totalUsers,
          'total_mitra': totalMitra,
          'total_drivers': totalDrivers,
          'total_revenue': totalRevenue,
        },
      };
    } catch (e) {
      developer.log('Error getting dashboard stats: $e');
      return {
        'success': false,
        'error': e.toString(),
        'data': {
          'total_orders': 0,
          'pending_orders': 0,
          'active_shipments': 0,
          'completed_orders': 0,
          'total_products': 0,
          'total_users': 0,
          'total_mitra': 0,
          'total_drivers': 0,
          'total_revenue': 0,
        },
      };
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
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('''
            profile_id,
            full_name,
            email,
            phone,
            created_at,
            role
          ''')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      developer.log('Error getting all users: $e');
      throw Exception('Gagal mengambil data users: $e');
    }
  }

  /// Get drivers only
  static Future<List<Map<String, dynamic>>> getDrivers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('''
            profile_id,
            full_name,
            email,
            phone,
            is_active,
            role
          ''')
          .or('role.ilike.%logistik%,role.ilike.%driver%')
          .eq('is_active', true)
          .order('full_name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      developer.log('Error getting drivers: $e');
      throw Exception('Gagal mengambil data driver: $e');
    }
  }

  /// Get all shipments with related data
  static Future<List<Map<String, dynamic>>> getAllShipments() async {
    try {
      final response = await _supabase
          .from('shipments')
          .select('''
            *,
            orders:order_id(
              order_id,
              nomor_pesanan,
              total_harga,
              status_pesanan,
              tanggal_pesan,
              mitra_bisnis_id,
              profiles:mitra_bisnis_id(full_name, email)
            ),
            profiles:driver_id(
              profile_id,
              full_name,
              email,
              phone
            )
          ''')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      developer.log('Error getting shipments: $e');
      throw Exception('Gagal mengambil data pengiriman: $e');
    }
  }

  /// Update order status
  static Future<void> updateOrderStatus(
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

      developer.log('Successfully updated order $orderId status to $newStatus');
    } catch (e) {
      developer.log('Error updating order status: $e');
      throw Exception('Gagal update status: $e');
    }
  }

  /// Update shipment status
  static Future<void> updateShipmentStatus(
    String shipmentId,
    String newStatus,
  ) async {
    try {
      await _supabase
          .from('shipments')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('shipment_id', shipmentId);

      developer.log(
        'Successfully updated shipment $shipmentId status to $newStatus',
      );
    } catch (e) {
      developer.log('Error updating shipment status: $e');
      throw Exception('Gagal update status shipment: $e');
    }
  }

  /// Get order details by ID
  static Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            *,
            profiles:mitra_bisnis_id(full_name, email, phone),
            order_details(*),
            shipments(
              *,
              profiles:driver_id(full_name, email, phone)
            )
          ''')
          .eq('order_id', orderId)
          .single();

      return response;
    } catch (e) {
      developer.log('Error getting order by ID: $e');
      return null;
    }
  }

  /// 1. ASSIGN DRIVER - Create shipment and assign driver to confirmed order
  static Future<Map<String, dynamic>> assignDriverToOrder({
    required String orderId,
    required String driverId,
    String? notes,
  }) async {
    try {
      // 1. Validate that order exists and is confirmed
      final orderResponse = await _supabase
          .from('orders')
          .select(
            'id, order_number, status, customer_id, pickup_address, delivery_address',
          )
          .eq('id', orderId)
          .single();

      if (orderResponse['status'] != 'confirmed') {
        throw Exception(
          'Order harus berstatus "Confirmed" untuk dapat ditugaskan ke driver',
        );
      }

      // 2. Validate that driver exists and is available
      final driverResponse = await _supabase
          .from('profiles')
          .select('id, full_name, role, is_active')
          .eq('id', driverId)
          .eq('is_active', true)
          .single();

      final driverRole = driverResponse['role']?.toString().toLowerCase();
      if (driverRole == null ||
          (!driverRole.contains('driver') &&
              !driverRole.contains('logistik'))) {
        throw Exception('User yang dipilih bukan driver aktif');
      }

      // 3. Check if driver already has active shipment
      final existingShipment = await _supabase
          .from('shipments')
          .select('id')
          .eq('driver_id', driverId)
          .inFilter('status', ['pending', 'in_transit'])
          .maybeSingle();

      if (existingShipment != null) {
        throw Exception('Driver sudah memiliki pengiriman aktif');
      }

      // 4. Generate delivery note number
      final now = DateTime.now();
      final deliveryNoteNumber =
          'DN-${DateFormat('yyyyMMdd').format(now)}-${now.millisecondsSinceEpoch.toString().substring(8)}';

      // 5. Create shipment record
      final shipmentData = await _supabase
          .from('shipments')
          .insert({
            'order_id': orderId,
            'driver_id': driverId,
            'delivery_note_number': deliveryNoteNumber,
            'status': 'pending',
            'assigned_at': now.toIso8601String(),
            'estimated_delivery': now
                .add(const Duration(days: 3))
                .toIso8601String(),
          })
          .select()
          .single();

      // 6. Update order status to 'shipped'
      await _supabase
          .from('orders')
          .update({'status': 'shipped', 'updated_at': now.toIso8601String()})
          .eq('id', orderId);

      // 7. Create notification for driver
      await _supabase.from('notifications').insert({
        'user_id': driverId,
        'title': 'Tugas Pengiriman Baru',
        'message':
            'Anda telah ditugaskan untuk pengiriman ${orderResponse['order_number']}',
        'type': 'assignment',
        'related_table': 'shipments',
        'related_id': shipmentData['id'],
      });

      developer.log('Successfully assigned driver $driverId to order $orderId');

      return {
        'success': true,
        'message': 'Driver berhasil ditugaskan',
        'data': {
          'shipment_id': shipmentData['id'],
          'delivery_note_number': deliveryNoteNumber,
          'driver_name': driverResponse['full_name'],
        },
      };
    } catch (e) {
      developer.log('Error assigning driver to order: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// 2. GENERATE DELIVERY NOTE PDF - Create PDF document for shipment
  static Future<Map<String, dynamic>> generateDeliveryNotePDF({
    required String shipmentId,
  }) async {
    try {
      // 1. Get shipment details with order and driver info
      final shipmentResponse = await _supabase
          .from('shipments')
          .select('''
            *,
            orders!inner(
              id, order_number, customer_id, pickup_address, delivery_address,
              total_quantity, total_amount, order_date,
              profiles!customer_id(full_name, phone, email, address)
            ),
            profiles!driver_id(full_name, phone, email, driver_license, vehicle_type, vehicle_plate)
          ''')
          .eq('id', shipmentId)
          .single();

      final shipment = shipmentResponse;
      final order = shipment['orders'];
      final customer = order['profiles'];
      final driver = shipment['profiles'];

      // 2. Create PDF document
      final pdf = pw.Document();
      final now = DateTime.now();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green800,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'SURAT JALAN',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'PT. Cangkang Sawit Indonesia',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Document Info
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'No. Surat Jalan: ${shipment['delivery_note_number']}',
                        ),
                        pw.Text('No. Order: ${order['order_number']}'),
                        pw.Text(
                          'Tanggal: ${DateFormat('dd MMMM yyyy').format(now)}',
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Customer Info
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'KEPADA:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text('Nama: ${customer['full_name'] ?? 'N/A'}'),
                      pw.Text('Telepon: ${customer['phone'] ?? 'N/A'}'),
                      pw.Text('Email: ${customer['email'] ?? 'N/A'}'),
                      pw.Text(
                        'Alamat Pengiriman: ${order['delivery_address'] ?? 'N/A'}',
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 15),

                // Driver Info
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'PENGIRIM:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text('Driver: ${driver['full_name'] ?? 'N/A'}'),
                      pw.Text('Telepon: ${driver['phone'] ?? 'N/A'}'),
                      pw.Text('SIM: ${driver['driver_license'] ?? 'N/A'}'),
                      pw.Text('Kendaraan: ${driver['vehicle_type'] ?? 'N/A'}'),
                      pw.Text('Plat: ${driver['vehicle_plate'] ?? 'N/A'}'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Order Details Table
                pw.Text(
                  'DETAIL PENGIRIMAN:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey200,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Deskripsi',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Jumlah',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Total',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Cangkang Sawit Premium'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${order['total_quantity'] ?? 0} Ton'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Rp ${NumberFormat('#,###').format(order['total_amount'] ?? 0)}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),

                // Signature Section
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text('Pengirim'),
                        pw.SizedBox(height: 50),
                        pw.Text('(_________________)'),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text('Penerima'),
                        pw.SizedBox(height: 50),
                        pw.Text('(_________________)'),
                      ],
                    ),
                  ],
                ),

                pw.Spacer(),
                pw.Text(
                  'Dokumen ini dibuat secara otomatis oleh sistem pada ${DateFormat('dd MMMM yyyy HH:mm').format(now)}',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            );
          },
        ),
      );

      // 3. Save PDF to temporary directory
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/delivery_note_${shipment['delivery_note_number']}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // 4. Update shipment with PDF URL (you might want to upload to cloud storage)
      await _supabase
          .from('shipments')
          .update({
            'delivery_note_url':
                filePath, // In production, this should be a cloud URL
            'updated_at': now.toIso8601String(),
          })
          .eq('id', shipmentId);

      developer.log(
        'Successfully generated delivery note PDF for shipment $shipmentId',
      );

      return {
        'success': true,
        'message': 'Surat jalan berhasil dibuat',
        'data': {
          'file_path': filePath,
          'delivery_note_number': shipment['delivery_note_number'],
        },
      };
    } catch (e) {
      developer.log('Error generating delivery note PDF: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// 3. USER VERIFICATION - Activate/Deactivate Mitra/Driver accounts
  static Future<Map<String, dynamic>> toggleUserActivation({
    required String userId,
    required bool isActive,
    String? reason,
  }) async {
    try {
      // 1. Get user details first
      final userResponse = await _supabase
          .from('profiles')
          .select('id, full_name, email, role, is_active')
          .eq('id', userId)
          .single();

      final userRole = userResponse['role']?.toString().toLowerCase();
      if (userRole == null ||
          (!userRole.contains('mitra') &&
              !userRole.contains('driver') &&
              !userRole.contains('logistik'))) {
        throw Exception('Hanya akun Mitra dan Driver yang dapat diverifikasi');
      }

      // 2. Update user activation status
      await _supabase
          .from('profiles')
          .update({
            'is_active': isActive,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      // 3. Create notification for user
      final notificationMessage = isActive
          ? 'Akun Anda telah diaktifkan oleh Admin. Selamat datang!'
          : 'Akun Anda telah dinonaktifkan${reason != null ? ": $reason" : ""}';

      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': isActive ? 'Akun Diaktifkan' : 'Akun Dinonaktifkan',
        'message': notificationMessage,
        'type': 'account_status',
      });

      // 4. If deactivating driver, also cancel any pending shipments
      if (!isActive &&
          (userRole.contains('driver') || userRole.contains('logistik'))) {
        await _supabase
            .from('shipments')
            .update({
              'status': 'cancelled',
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('driver_id', userId)
            .inFilter('status', ['pending']);
      }

      final actionText = isActive ? 'diaktifkan' : 'dinonaktifkan';
      developer.log('Successfully $actionText user $userId');

      return {
        'success': true,
        'message': 'Akun ${userResponse['full_name']} berhasil $actionText',
        'data': {
          'user_id': userId,
          'is_active': isActive,
          'user_name': userResponse['full_name'],
        },
      };
    } catch (e) {
      developer.log('Error toggling user activation: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get all users (Mitra + Driver) for verification management
  static Future<Map<String, dynamic>> getAllUsersForVerification() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select(
            'id, full_name, email, phone, role, is_active, created_at, updated_at',
          )
          .or('role.ilike.%mitra%,role.ilike.%driver%,role.ilike.%logistik%')
          .order('created_at', ascending: false);

      final users = (response as List<dynamic>).map((user) {
        return {
          'id': user['id']?.toString() ?? '',
          'full_name': user['full_name'] ?? 'Unknown',
          'email': user['email'] ?? '',
          'phone': user['phone'] ?? '',
          'role': user['role'] ?? '',
          'is_active': user['is_active'] ?? false,
          'created_at': user['created_at'] ?? '',
          'updated_at': user['updated_at'] ?? '',
        };
      }).toList();

      return {
        'success': true,
        'data': users,
        'total_users': users.length,
        'active_users': users.where((u) => u['is_active'] == true).length,
        'inactive_users': users.where((u) => u['is_active'] == false).length,
      };
    } catch (e) {
      developer.log('Error getting users for verification: $e');
      return {'success': false, 'error': e.toString(), 'data': []};
    }
  }

  /// Get confirmed orders ready for driver assignment
  static Future<Map<String, dynamic>> getConfirmedOrders() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            id, order_number, customer_id, total_quantity, total_amount,
            pickup_address, delivery_address, order_date, status,
            profiles!customer_id(full_name, email, phone)
          ''')
          .eq('status', 'confirmed')
          .order('order_date', ascending: false);

      final orders = (response as List<dynamic>).map((order) {
        return {
          'id': order['id']?.toString() ?? '',
          'order_number': order['order_number'] ?? '',
          'customer_name': order['profiles']?['full_name'] ?? 'Unknown',
          'customer_email': order['profiles']?['email'] ?? '',
          'customer_phone': order['profiles']?['phone'] ?? '',
          'total_quantity': order['total_quantity'] ?? 0,
          'total_amount': order['total_amount'] ?? 0,
          'pickup_address': order['pickup_address'] ?? '',
          'delivery_address': order['delivery_address'] ?? '',
          'order_date': order['order_date'] ?? '',
        };
      }).toList();

      return {'success': true, 'data': orders, 'total_orders': orders.length};
    } catch (e) {
      developer.log('Error getting confirmed orders: $e');
      return {'success': false, 'error': e.toString(), 'data': []};
    }
  }
}
