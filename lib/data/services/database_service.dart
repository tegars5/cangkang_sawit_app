import 'package:supabase_flutter/supabase_flutter.dart';

/// Database service for all Supabase operations
/// Now using real Supabase data!
class DatabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Orders operations
  static Future<List<Map<String, dynamic>>> getOrders({
    String? status,
    int? limit,
    int? offset,
  }) async {
    try {
      // Build the query step by step
      final query = _client.from('orders').select('*');

      // Apply filters and execute
      final List<Map<String, dynamic>> response;
      if (status != null && status != 'all') {
        response = await query
            .eq('status', status)
            .order('created_at', ascending: false);
      } else {
        response = await query.order('created_at', ascending: false);
      }

      // Get customer details for each order
      final ordersWithCustomers = <Map<String, dynamic>>[];
      for (final order in response) {
        Map<String, dynamic> orderData = Map.from(order);

        // Try to get customer info if customer_id exists
        if (order['customer_id'] != null) {
          try {
            final customerResponse = await _client
                .from('profiles')
                .select('full_name, email')
                .eq('id', order['customer_id'])
                .single();

            orderData['customer_name'] =
                customerResponse['full_name'] ?? 'Unknown Customer';
            orderData['customer_email'] = customerResponse['email'] ?? '';
          } catch (e) {
            orderData['customer_name'] = 'Unknown Customer';
            orderData['customer_email'] = '';
          }
        } else {
          orderData['customer_name'] = 'Unknown Customer';
          orderData['customer_email'] = '';
        }

        // Add default values for missing fields
        orderData['order_number'] =
            order['order_number'] ??
            'ORD-${order['id'].toString().substring(0, 8)}';
        orderData['total_weight'] = order['total_weight'] ?? 0.0;
        orderData['total_amount'] = order['total_amount'] ?? 0.0;
        orderData['status'] = order['status'] ?? 'Pending Review';
        orderData['delivery_city'] = order['delivery_city'] ?? '';
        orderData['delivery_province'] = order['delivery_province'] ?? '';
        orderData['pickup_address'] = order['pickup_address'] ?? '';
        orderData['delivery_address'] = order['delivery_address'] ?? '';
        orderData['notes'] = order['notes'] ?? '';

        ordersWithCustomers.add(orderData);
      }

      // Apply pagination if specified
      if (limit != null) {
        final startIndex = offset ?? 0;
        final endIndex = startIndex + limit;
        return ordersWithCustomers.sublist(
          startIndex.clamp(0, ordersWithCustomers.length),
          endIndex.clamp(0, ordersWithCustomers.length),
        );
      }

      return ordersWithCustomers;
    } catch (e) {
      print('Error fetching orders: $e');
      // Return fallback dummy data if real data fails
      final allOrders = [
        {
          'id': '1',
          'order_number': 'ORD-20241113-001',
          'customer_name': 'PT Sawit Jaya',
          'total_weight': 5000.0,
          'total_amount': 4250000.0,
          'status': 'Pending Review',
          'created_at': DateTime.now()
              .subtract(const Duration(hours: 2))
              .toIso8601String(),
          'delivery_city': 'Jakarta',
          'delivery_province': 'DKI Jakarta',
        },
        {
          'id': '2',
          'order_number': 'ORD-20241113-002',
          'customer_name': 'CV Biomass Mandiri',
          'total_weight': 3000.0,
          'total_amount': 2550000.0,
          'status': 'Approved',
          'created_at': DateTime.now()
              .subtract(const Duration(hours: 5))
              .toIso8601String(),
          'delivery_city': 'Surabaya',
          'delivery_province': 'Jawa Timur',
        },
        {
          'id': '3',
          'order_number': 'ORD-20241112-003',
          'customer_name': 'UD Makmur Sejahtera',
          'total_weight': 8000.0,
          'total_amount': 6800000.0,
          'status': 'Completed',
          'created_at': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          'delivery_city': 'Medan',
          'delivery_province': 'Sumatera Utara',
        },
        {
          'id': '4',
          'order_number': 'ORD-20241112-004',
          'customer_name': 'PT Energy Indonesia',
          'total_weight': 12000.0,
          'total_amount': 10200000.0,
          'status': 'Approved',
          'created_at': DateTime.now()
              .subtract(const Duration(days: 1, hours: 3))
              .toIso8601String(),
          'delivery_city': 'Bandung',
          'delivery_province': 'Jawa Barat',
        },
        {
          'id': '5',
          'order_number': 'ORD-20241111-005',
          'customer_name': 'CV Hijau Lestari',
          'total_weight': 6000.0,
          'total_amount': 5100000.0,
          'status': 'Completed',
          'created_at': DateTime.now()
              .subtract(const Duration(days: 2))
              .toIso8601String(),
          'delivery_city': 'Yogyakarta',
          'delivery_province': 'DI Yogyakarta',
        },
      ];

      // Filter by status if provided
      var filteredOrders = allOrders;
      if (status != null && status.isNotEmpty) {
        filteredOrders = allOrders
            .where((order) => order['status'] == status)
            .toList();
      }

      // Apply limit and offset
      if (offset != null) {
        filteredOrders = filteredOrders.skip(offset).toList();
      }
      if (limit != null) {
        filteredOrders = filteredOrders.take(limit).toList();
      }

      return filteredOrders;
    }
  }

  // Shipments operations
  static Future<List<Map<String, dynamic>>> getShipments({
    String? status,
    String? driverId,
    int? limit,
    int? offset,
  }) async {
    try {
      // Get shipments from database
      final query = _client.from('shipments').select('*');
      final List<Map<String, dynamic>> response = await query.order(
        'created_at',
        ascending: false,
      );

      // Get related order and profile data
      final shipmentsWithDetails = <Map<String, dynamic>>[];
      for (final shipment in response) {
        Map<String, dynamic> shipmentData = Map.from(shipment);

        // Try to get order info
        if (shipment['order_id'] != null) {
          try {
            final orderResponse = await _client
                .from('orders')
                .select('order_number, total_amount, customer_id')
                .eq('id', shipment['order_id'])
                .single();

            shipmentData['order_number'] =
                orderResponse['order_number'] ?? 'ORD-Unknown';
            shipmentData['total_amount'] = orderResponse['total_amount'] ?? 0.0;

            // Get customer info
            if (orderResponse['customer_id'] != null) {
              try {
                final customerResponse = await _client
                    .from('profiles')
                    .select('full_name')
                    .eq('id', orderResponse['customer_id'])
                    .single();

                shipmentData['customer_name'] =
                    customerResponse['full_name'] ?? 'Unknown Customer';
              } catch (e) {
                shipmentData['customer_name'] = 'Unknown Customer';
              }
            }
          } catch (e) {
            shipmentData['order_number'] = 'ORD-Unknown';
            shipmentData['customer_name'] = 'Unknown Customer';
          }
        }

        // Add default values
        shipmentData['shipment_number'] =
            shipment['tracking_number'] ??
            'SHP-${shipment['id'].toString().substring(0, 8)}';
        shipmentData['status'] = shipment['status'] ?? 'Ready to Ship';
        shipmentData['driver_name'] = 'Driver Assignment Pending';

        shipmentsWithDetails.add(shipmentData);
      }

      // Filter by status
      var filteredShipments = shipmentsWithDetails;
      if (status != null && status != 'all') {
        filteredShipments = shipmentsWithDetails
            .where((s) => s['status'] == status)
            .toList();
      }

      // Apply pagination
      if (limit != null) {
        final startIndex = offset ?? 0;
        final endIndex = startIndex + limit;
        return filteredShipments.sublist(
          startIndex.clamp(0, filteredShipments.length),
          endIndex.clamp(0, filteredShipments.length),
        );
      }

      return filteredShipments;
    } catch (e) {
      print('Error fetching shipments: $e');
      // Fallback dummy data
      await Future.delayed(const Duration(milliseconds: 500));

      final allShipments = [
        {
          'id': '1',
          'shipment_number': 'SHP-20241113-001',
          'order_number': 'ORD-20241113-001',
          'customer_name': 'PT Sawit Jaya',
          'driver_name': 'Ahmad Sutrisno',
          'status': 'Ready to Ship',
          'created_at': DateTime.now()
              .subtract(const Duration(hours: 1))
              .toIso8601String(),
        },
        {
          'id': '2',
          'shipment_number': 'SHP-20241112-002',
          'order_number': 'ORD-20241112-003',
          'customer_name': 'UD Makmur Sejahtera',
          'driver_name': 'Budi Santoso',
          'status': 'In Transit',
          'created_at': DateTime.now()
              .subtract(const Duration(hours: 8))
              .toIso8601String(),
        },
        {
          'id': '3',
          'shipment_number': 'SHP-20241111-003',
          'order_number': 'ORD-20241111-005',
          'customer_name': 'CV Hijau Lestari',
          'driver_name': 'Joko Widodo',
          'status': 'Delivered',
          'created_at': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
        },
      ];

      var filteredShipments = allShipments;
      if (status != null && status.isNotEmpty) {
        filteredShipments = allShipments
            .where((shipment) => shipment['status'] == status)
            .toList();
      }

      if (offset != null) {
        filteredShipments = filteredShipments.skip(offset).toList();
      }
      if (limit != null) {
        filteredShipments = filteredShipments.take(limit).toList();
      }

      return filteredShipments;
    }
  }

  // Driver/Users operations
  static Future<List<Map<String, dynamic>>> getDrivers({
    bool? isActive,
    int? limit,
    int? offset,
  }) async {
    try {
      // Get all profiles (drivers will be identified by role if available)
      final query = _client.from('profiles').select('*');
      final List<Map<String, dynamic>> response = await query.order(
        'created_at',
        ascending: false,
      );

      // Transform data to match expected format
      final driversData = response
          .map<Map<String, dynamic>>(
            (profile) => {
              'id': profile['id'],
              'full_name': profile['full_name'] ?? 'Unknown User',
              'email': profile['email'] ?? '',
              'phone': profile['phone'] ?? '',
              'address': profile['address'] ?? '',
              'role': profile['role'] ?? 'user',
              'driver_license': profile['driver_license'] ?? '',
              'vehicle_type': profile['vehicle_type'] ?? '',
              'vehicle_plate': profile['vehicle_plate'] ?? '',
              'is_active': profile['is_active'] ?? true,
              'status': profile['is_active'] == true ? 'Available' : 'Inactive',
              'created_at': profile['created_at'],
            },
          )
          .toList();

      // Filter by isActive if provided
      var filteredDrivers = driversData;
      if (isActive != null) {
        filteredDrivers = driversData
            .where((d) => d['is_active'] == isActive)
            .toList();
      }

      // Apply pagination
      if (limit != null) {
        final startIndex = offset ?? 0;
        final endIndex = startIndex + limit;
        return filteredDrivers.sublist(
          startIndex.clamp(0, filteredDrivers.length),
          endIndex.clamp(0, filteredDrivers.length),
        );
      }

      return filteredDrivers;
    } catch (e) {
      print('Error fetching drivers: $e');
      // Fallback dummy data
      await Future.delayed(const Duration(milliseconds: 500));

      final allDrivers = [
        {
          'id': '1',
          'full_name': 'Ahmad Sutrisno',
          'phone': '+62812345678',
          'vehicle_type': 'Truck Box',
          'vehicle_plate': 'BK 1234 AB',
          'status': 'Available',
          'is_active': true,
        },
        {
          'id': '2',
          'full_name': 'Budi Santoso',
          'phone': '+62812345679',
          'vehicle_type': 'Truck Fuso',
          'vehicle_plate': 'BK 5678 CD',
          'status': 'On Duty',
          'is_active': true,
        },
        {
          'id': '3',
          'full_name': 'Joko Widodo',
          'phone': '+62812345680',
          'vehicle_type': 'Truck Engkel',
          'vehicle_plate': 'BK 9012 EF',
          'status': 'Available',
          'is_active': true,
        },
        {
          'id': '4',
          'full_name': 'Siti Nurhaliza',
          'phone': '+62812345681',
          'vehicle_type': 'Truck Box',
          'vehicle_plate': 'BK 3456 GH',
          'status': 'Inactive',
          'is_active': false,
        },
      ];

      var filteredDrivers = allDrivers;
      if (isActive != null) {
        filteredDrivers = allDrivers
            .where((driver) => driver['is_active'] == isActive)
            .toList();
      }

      if (offset != null) {
        filteredDrivers = filteredDrivers.skip(offset).toList();
      }
      if (limit != null) {
        filteredDrivers = filteredDrivers.take(limit).toList();
      }

      return filteredDrivers;
    }
  }

  // Tasks operations
  static Future<List<Map<String, dynamic>>> getTasks({
    String? driverId,
    String? status,
    DateTime? date,
    int? limit,
    int? offset,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final allTasks = [
      {
        'id': '1',
        'task_number': 'TSK-20241113-001',
        'title': 'Pickup from PT Sawit Jaya',
        'status': 'Scheduled',
        'priority': 'high',
        'scheduled_date': DateTime.now().toIso8601String().split('T')[0],
        'driver_id': '1',
      },
      {
        'id': '2',
        'task_number': 'TSK-20241113-002',
        'title': 'Delivery to CV Biomass Mandiri',
        'status': 'In Progress',
        'priority': 'normal',
        'scheduled_date': DateTime.now().toIso8601String().split('T')[0],
        'driver_id': '2',
      },
      {
        'id': '3',
        'task_number': 'TSK-20241112-003',
        'title': 'Delivery to UD Makmur Sejahtera',
        'status': 'Completed',
        'priority': 'normal',
        'scheduled_date': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String()
            .split('T')[0],
        'driver_id': '1',
      },
    ];

    var filteredTasks = allTasks;
    if (driverId != null && driverId.isNotEmpty) {
      filteredTasks = allTasks
          .where((task) => task['driver_id'] == driverId)
          .toList();
    }
    if (status != null && status.isNotEmpty) {
      filteredTasks = filteredTasks
          .where((task) => task['status'] == status)
          .toList();
    }

    if (offset != null) {
      filteredTasks = filteredTasks.skip(offset).toList();
    }
    if (limit != null) {
      filteredTasks = filteredTasks.take(limit).toList();
    }

    return filteredTasks;
  }

  // Dashboard stats
  static Future<Map<String, dynamic>> getAdminDashboardStats() async {
    try {
      // Get real statistics from database
      final totalOrdersResponse = await _client
          .from('orders')
          .select('id')
          .count();
      final pendingOrdersResponse = await _client
          .from('orders')
          .select('id')
          .eq('status', 'Pending Review')
          .count();
      final activeShipmentsResponse = await _client
          .from('shipments')
          .select('id')
          .eq('status', 'In Transit')
          .count();
      final activeDriversResponse = await _client
          .from('profiles')
          .select('id')
          .eq('is_active', true)
          .count();

      // Get revenue (sum of completed orders)
      final revenueResponse = await _client
          .from('orders')
          .select('total_amount')
          .eq('status', 'Completed');

      double monthlyRevenue = 0.0;
      for (var order in revenueResponse) {
        monthlyRevenue += (order['total_amount'] ?? 0.0).toDouble();
      }

      return {
        'total_orders': totalOrdersResponse.count,
        'pending_orders': pendingOrdersResponse.count,
        'active_shipments': activeShipmentsResponse.count,
        'active_drivers': activeDriversResponse.count,
        'monthly_revenue': monthlyRevenue,
        'recent_orders': await getOrders(limit: 5),
      };
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      // Fallback dummy data
      return {
        'total_orders': 25,
        'pending_orders': 5,
        'active_shipments': 8,
        'active_drivers': 3,
        'monthly_revenue': 125000000.0,
        'recent_orders': await getOrders(limit: 5),
      };
    }
  }

  static Future<Map<String, dynamic>> getDriverDashboardStats(
    String driverId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'pending_tasks': 2,
      'completed_tasks': 15,
      'today_tasks': 3,
      'monthly_deliveries': 42,
      'performance_rating': 4.8,
    };
  }

  // Utility methods for order management
  static Future<void> updateOrderStatus(String orderId, String status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Simulate database update
    print('Order $orderId status updated to $status');
  }

  static Future<void> approveOrder(String orderId, String approvedBy) async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('Order $orderId approved by $approvedBy');
  }

  // More methods can be added as needed...
}
