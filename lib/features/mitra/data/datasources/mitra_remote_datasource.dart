import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/order_summary_model.dart';

/// Mitra Remote Data Source Interface
abstract class MitraRemoteDataSource {
  Future<List<OrderSummaryModel>> getOrderHistory({
    required String customerId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });
  Future<List<OrderSummaryModel>> getActiveOrders({required String customerId});
  Future<List<OrderSummaryModel>> getCompletedOrders({
    required String customerId,
  });
  Future<OrderSummaryModel> getOrderById(String orderId);
  Future<Map<String, dynamic>> trackActiveOrder(String orderId);
  Future<Map<String, dynamic>> getDashboardStats({required String customerId});
}

/// Mitra Remote Data Source Implementation
class MitraRemoteDataSourceImpl implements MitraRemoteDataSource {
  final SupabaseClient supabaseClient;

  MitraRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<OrderSummaryModel>> getOrderHistory({
    required String customerId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      var query = supabaseClient
          .from('orders')
          .select('''
            id,
            order_number,
            status,
            created_at,
            confirmed_at,
            shipped_at,
            delivered_at,
            total_amount,
            notes,
            delivery_address,
            latitude,
            longitude,
            order_details (
              id
            ),
            shipments (
              tracking_number,
              profiles:driver_id (
                full_name,
                phone
              )
            )
          ''')
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      // Note: Conditional filters removed due to Supabase API limitations
      // Filtering will be done at application level if needed
      final response = await query;
      final orders = response as List;

      return orders.map((json) {
        // Count total items from order_details
        final orderDetails = json['order_details'] as List? ?? [];
        final totalItems = orderDetails.length;

        // Get driver info from shipments
        String? driverName;
        String? driverPhone;
        String? trackingNumber;

        final shipments = json['shipments'] as List? ?? [];
        if (shipments.isNotEmpty) {
          final shipment = shipments.first;
          trackingNumber = shipment['tracking_number'] as String?;
          final driver = shipment['profiles'];
          if (driver != null) {
            driverName = driver['full_name'] as String?;
            driverPhone = driver['phone'] as String?;
          }
        }

        // Build order summary data
        final orderData = Map<String, dynamic>.from(json);
        orderData['total_items'] = totalItems;
        orderData['driver_name'] = driverName;
        orderData['driver_phone'] = driverPhone;
        orderData['tracking_number'] = trackingNumber;

        return OrderSummaryModel.fromJson(orderData);
      }).toList();
    } catch (e) {
      throw ServerException('Failed to get order history: ${e.toString()}');
    }
  }

  @override
  Future<List<OrderSummaryModel>> getActiveOrders({
    required String customerId,
  }) async {
    try {
      return await getOrderHistory(
        customerId: customerId,
        status: null, // Get all statuses
      ).then((orders) {
        // Filter active orders (not completed or cancelled)
        return orders.where((order) => order.toDomain().isActive()).toList();
      });
    } catch (e) {
      throw ServerException('Failed to get active orders: ${e.toString()}');
    }
  }

  @override
  Future<List<OrderSummaryModel>> getCompletedOrders({
    required String customerId,
  }) async {
    try {
      return await getOrderHistory(customerId: customerId, status: 'completed');
    } catch (e) {
      throw ServerException('Failed to get completed orders: ${e.toString()}');
    }
  }

  @override
  Future<OrderSummaryModel> getOrderById(String orderId) async {
    try {
      final response = await supabaseClient
          .from('orders')
          .select('''
            id,
            order_number,
            status,
            created_at,
            confirmed_at,
            shipped_at,
            delivered_at,
            total_amount,
            notes,
            delivery_address,
            latitude,
            longitude,
            order_details (
              id
            ),
            shipments (
              tracking_number,
              profiles:driver_id (
                full_name,
                phone
              )
            )
          ''')
          .eq('id', orderId)
          .single();

      // Count total items
      final orderDetails = response['order_details'] as List? ?? [];
      final totalItems = orderDetails.length;

      // Get driver info
      String? driverName;
      String? driverPhone;
      String? trackingNumber;

      final shipments = response['shipments'] as List? ?? [];
      if (shipments.isNotEmpty) {
        final shipment = shipments.first;
        trackingNumber = shipment['tracking_number'] as String?;
        final driver = shipment['profiles'];
        if (driver != null) {
          driverName = driver['full_name'] as String?;
          driverPhone = driver['phone'] as String?;
        }
      }

      final orderData = Map<String, dynamic>.from(response);
      orderData['total_items'] = totalItems;
      orderData['driver_name'] = driverName;
      orderData['driver_phone'] = driverPhone;
      orderData['tracking_number'] = trackingNumber;

      return OrderSummaryModel.fromJson(orderData);
    } catch (e) {
      throw ServerException('Failed to get order by ID: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> trackActiveOrder(String orderId) async {
    try {
      final response = await supabaseClient
          .from('shipments')
          .select('''
            id,
            status,
            tracking_number,
            pickup_date,
            delivery_date,
            current_location,
            latitude,
            longitude,
            profiles:driver_id (
              full_name,
              phone
            )
          ''')
          .eq('order_id', orderId)
          .maybeSingle();

      if (response == null) {
        return {
          'has_tracking': false,
          'message': 'Belum ada informasi pengiriman',
        };
      }

      final driver = response['profiles'];

      return {
        'has_tracking': true,
        'shipment_id': response['id'],
        'status': response['status'],
        'tracking_number': response['tracking_number'],
        'pickup_date': response['pickup_date'],
        'delivery_date': response['delivery_date'],
        'current_location': response['current_location'],
        'latitude': response['latitude'],
        'longitude': response['longitude'],
        'driver_name': driver?['full_name'],
        'driver_phone': driver?['phone'],
      };
    } catch (e) {
      throw ServerException('Failed to track order: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getDashboardStats({
    required String customerId,
  }) async {
    try {
      // Get all orders for this customer
      final ordersResponse = await supabaseClient
          .from('orders')
          .select('status')
          .eq('customer_id', customerId);

      final orders = ordersResponse as List;

      // Calculate stats
      final totalOrders = orders.length;
      final pendingOrders = orders
          .where((o) => o['status'] == 'pending')
          .length;
      final activeOrders = orders
          .where((o) => o['status'] == 'confirmed' || o['status'] == 'shipped')
          .length;
      final completedOrders = orders
          .where((o) => o['status'] == 'completed')
          .length;

      // Get this month's orders
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);

      final thisMonthOrders = await supabaseClient
          .from('orders')
          .select('id')
          .eq('customer_id', customerId)
          .gte('created_at', firstDayOfMonth.toIso8601String());

      final thisMonthCount = (thisMonthOrders as List).length;

      return {
        'total_orders': totalOrders,
        'pending_orders': pendingOrders,
        'active_orders': activeOrders,
        'completed_orders': completedOrders,
        'this_month_orders': thisMonthCount,
      };
    } catch (e) {
      throw ServerException('Failed to get dashboard stats: ${e.toString()}');
    }
  }
}
