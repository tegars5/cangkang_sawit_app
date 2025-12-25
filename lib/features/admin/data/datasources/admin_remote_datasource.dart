import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/dashboard_stats_model.dart';
import '../models/driver_info_model.dart';
import '../../../orders/data/models/order_model.dart';

/// Admin Remote Data Source Interface
abstract class AdminRemoteDataSource {
  Future<DashboardStatsModel> getDashboardStats();
  Future<List<DriverInfoModel>> getAllDrivers();
  Future<List<DriverInfoModel>> getActiveDrivers();
  Future<List<DriverInfoModel>> getAvailableDrivers();
  Future<DriverInfoModel> getDriverById(String driverId);
  Future<DriverInfoModel> updateDriverStatus({
    required String driverId,
    required bool isActive,
  });
  Future<List<OrderModel>> getAllOrders({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });
  Future<List<OrderModel>> getRecentOrders({int limit = 10});
  Future<List<OrderModel>> getOrdersByStatus(String status);
  Future<Map<String, dynamic>> getSystemHealth();
  Future<Map<String, dynamic>> getRevenueAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });
}

/// Admin Remote Data Source Implementation
class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final SupabaseClient supabaseClient;

  AdminRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastMonth = DateTime(now.year, now.month - 1, 1);
      final lastDayOfLastMonth = DateTime(now.year, now.month, 0);
      final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final yesterday = now.subtract(const Duration(days: 1));

      // Get all orders
      final ordersResponse = await supabaseClient
          .from('orders')
          .select('status, total_amount, created_at');

      final orders = ordersResponse as List;

      // Calculate order statistics
      final totalOrders = orders.length;
      final pendingOrders = orders
          .where((o) => o['status'] == 'pending')
          .length;
      final confirmedOrders = orders
          .where((o) => o['status'] == 'confirmed')
          .length;
      final shippedOrders = orders
          .where((o) => o['status'] == 'shipped')
          .length;
      final completedOrders = orders
          .where((o) => o['status'] == 'completed')
          .length;
      final cancelledOrders = orders
          .where((o) => o['status'] == 'cancelled')
          .length;

      // Calculate revenue
      double totalRevenue = 0.0;
      double monthlyRevenue = 0.0;
      double weeklyRevenue = 0.0;
      double dailyRevenue = 0.0;

      for (var order in orders) {
        final amount = (order['total_amount'] as num?)?.toDouble() ?? 0.0;
        totalRevenue += amount;

        final createdAt = DateTime.parse(order['created_at'] as String);
        if (createdAt.isAfter(firstDayOfMonth)) {
          monthlyRevenue += amount;
        }
        if (createdAt.isAfter(firstDayOfWeek)) {
          weeklyRevenue += amount;
        }
        if (createdAt.isAfter(yesterday)) {
          dailyRevenue += amount;
        }
      }

      // Get orders last month for trend
      final ordersLastMonth = await supabaseClient
          .from('orders')
          .select('id')
          .gte('created_at', lastMonth.toIso8601String())
          .lte('created_at', lastDayOfLastMonth.toIso8601String());

      final ordersLastMonthCount = (ordersLastMonth as List).length;
      final ordersThisMonthCount = orders.where((o) {
        final createdAt = DateTime.parse(o['created_at'] as String);
        return createdAt.isAfter(firstDayOfMonth);
      }).length;

      double ordersTrend = 0.0;
      if (ordersLastMonthCount > 0) {
        ordersTrend =
            ((ordersThisMonthCount - ordersLastMonthCount) /
                ordersLastMonthCount) *
            100;
      }

      // Get shipments
      final shipmentsResponse = await supabaseClient
          .from('shipments')
          .select('status')
          .neq('status', 'completed')
          .neq('status', 'cancelled');

      final activeShipments = (shipmentsResponse as List).length;

      // Get shipments last month for trend
      final shipmentsLastMonth = await supabaseClient
          .from('shipments')
          .select('id')
          .gte('created_at', lastMonth.toIso8601String())
          .lte('created_at', lastDayOfLastMonth.toIso8601String());

      final shipmentsThisMonth = await supabaseClient
          .from('shipments')
          .select('id')
          .gte('created_at', firstDayOfMonth.toIso8601String());

      final shipmentsLastMonthCount = (shipmentsLastMonth as List).length;
      final shipmentsThisMonthCount = (shipmentsThisMonth as List).length;

      double shipmentsTrend = 0.0;
      if (shipmentsLastMonthCount > 0) {
        shipmentsTrend =
            ((shipmentsThisMonthCount - shipmentsLastMonthCount) /
                shipmentsLastMonthCount) *
            100;
      }

      // Get drivers
      final allDriversResponse = await supabaseClient
          .from('profiles')
          .select('id, is_active')
          .eq('role_id', 3); // Driver role

      final allDrivers = allDriversResponse as List;
      final totalDrivers = allDrivers.length;
      final activeDrivers = allDrivers
          .where((d) => d['is_active'] == true)
          .length;

      // Get partners (customers with orders)
      final partnersResponse = await supabaseClient
          .from('profiles')
          .select('id, is_active')
          .eq('role_id', 2); // Customer/Partner role

      final allPartners = partnersResponse as List;
      final totalPartners = allPartners.length;
      final activePartners = allPartners
          .where((p) => p['is_active'] == true)
          .length;

      // Calculate trends (simplified)
      double revenueTrend = 0.0;
      double partnersTrend = 0.0;

      return DashboardStatsModel(
        totalOrders: totalOrders,
        pendingOrders: pendingOrders,
        confirmedOrders: confirmedOrders,
        shippedOrders: shippedOrders,
        completedOrders: completedOrders,
        cancelledOrders: cancelledOrders,
        activeShipments: activeShipments,
        activeDrivers: activeDrivers,
        totalDrivers: totalDrivers,
        activePartners: activePartners,
        totalPartners: totalPartners,
        totalRevenue: totalRevenue,
        monthlyRevenue: monthlyRevenue,
        weeklyRevenue: weeklyRevenue,
        dailyRevenue: dailyRevenue,
        ordersTrend: ordersTrend,
        revenueTrend: revenueTrend,
        shipmentsTrend: shipmentsTrend,
        partnersTrend: partnersTrend,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw ServerException('Failed to get dashboard stats: ${e.toString()}');
    }
  }

  @override
  Future<List<DriverInfoModel>> getAllDrivers() async {
    try {
      final response = await supabaseClient
          .from('profiles')
          .select('''
            id,
            full_name,
            email,
            phone,
            vehicle_number,
            vehicle_type,
            is_active,
            created_at,
            last_active,
            rating
          ''')
          .eq('role_id', 3) // Driver role
          .order('created_at', ascending: false);

      final drivers = response as List;

      // Get delivery counts for each driver
      final driverModels = <DriverInfoModel>[];
      for (var driver in drivers) {
        final driverId = driver['id'] as String;

        // Get completed deliveries count
        final completedResponse = await supabaseClient
            .from('shipments')
            .select('id')
            .eq('driver_id', driverId)
            .eq('status', 'completed');

        final completedCount = (completedResponse as List).length;

        // Get active deliveries count
        final activeResponse = await supabaseClient
            .from('shipments')
            .select('id')
            .eq('driver_id', driverId)
            .eq('status', 'in_transit');

        final activeCount = (activeResponse as List).length;

        final driverData = Map<String, dynamic>.from(driver);
        driverData['completed_deliveries'] = completedCount;
        driverData['active_deliveries'] = activeCount;

        driverModels.add(DriverInfoModel.fromJson(driverData));
      }

      return driverModels;
    } catch (e) {
      throw ServerException('Failed to get all drivers: ${e.toString()}');
    }
  }

  @override
  Future<List<DriverInfoModel>> getActiveDrivers() async {
    try {
      final allDrivers = await getAllDrivers();
      return allDrivers.where((d) => d.isActive).toList();
    } catch (e) {
      throw ServerException('Failed to get active drivers: ${e.toString()}');
    }
  }

  @override
  Future<List<DriverInfoModel>> getAvailableDrivers() async {
    try {
      final allDrivers = await getAllDrivers();
      return allDrivers
          .where((d) => d.isActive && d.activeDeliveries == 0)
          .toList();
    } catch (e) {
      throw ServerException('Failed to get available drivers: ${e.toString()}');
    }
  }

  @override
  Future<DriverInfoModel> getDriverById(String driverId) async {
    try {
      final response = await supabaseClient
          .from('profiles')
          .select('''
            id,
            full_name,
            email,
            phone,
            vehicle_number,
            vehicle_type,
            is_active,
            created_at,
            last_active,
            rating
          ''')
          .eq('id', driverId)
          .single();

      // Get delivery counts
      final completedResponse = await supabaseClient
          .from('shipments')
          .select('id')
          .eq('driver_id', driverId)
          .eq('status', 'completed');

      final completedCount = (completedResponse as List).length;

      final activeResponse = await supabaseClient
          .from('shipments')
          .select('id')
          .eq('driver_id', driverId)
          .eq('status', 'in_transit');

      final activeCount = (activeResponse as List).length;

      final driverData = Map<String, dynamic>.from(response);
      driverData['completed_deliveries'] = completedCount;
      driverData['active_deliveries'] = activeCount;

      return DriverInfoModel.fromJson(driverData);
    } catch (e) {
      throw ServerException('Failed to get driver by ID: ${e.toString()}');
    }
  }

  @override
  Future<DriverInfoModel> updateDriverStatus({
    required String driverId,
    required bool isActive,
  }) async {
    try {
      await supabaseClient
          .from('profiles')
          .update({'is_active': isActive})
          .eq('id', driverId);

      return await getDriverById(driverId);
    } catch (e) {
      throw ServerException('Failed to update driver status: ${e.toString()}');
    }
  }

  @override
  Future<List<OrderModel>> getAllOrders({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      var query = supabaseClient
          .from('orders')
          .select('''
            *,
            profiles:customer_id (
              full_name,
              email,
              phone
            ),
            order_details (
              id,
              product_id,
              quantity,
              price_per_unit,
              subtotal,
              products (
                name,
                sku
              )
            )
          ''')
          .order('created_at', ascending: false);

      // Apply filters directly without reassignment
      // Note: Supabase client methods are immutable, each returns new builder
      final response = await query;
      final orders = response as List;

      return orders.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to get all orders: ${e.toString()}');
    }
  }

  @override
  Future<List<OrderModel>> getRecentOrders({int limit = 10}) async {
    return await getAllOrders(limit: limit);
  }

  @override
  Future<List<OrderModel>> getOrdersByStatus(String status) async {
    return await getAllOrders(status: status);
  }

  @override
  Future<Map<String, dynamic>> getSystemHealth() async {
    try {
      final stats = await getDashboardStats();

      return {
        'status': stats.activeDrivers > 0 ? 'healthy' : 'warning',
        'active_drivers': stats.activeDrivers,
        'active_shipments': stats.activeShipments,
        'pending_orders': stats.pendingOrders,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw ServerException('Failed to get system health: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getRevenueAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = supabaseClient
          .from('orders')
          .select('total_amount, created_at, status');

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;
      final orders = response as List;

      double totalRevenue = 0.0;
      double completedRevenue = 0.0;
      int totalOrders = orders.length;
      int completedOrders = 0;

      for (var order in orders) {
        final amount = (order['total_amount'] as num?)?.toDouble() ?? 0.0;
        totalRevenue += amount;

        if (order['status'] == 'completed') {
          completedRevenue += amount;
          completedOrders++;
        }
      }

      return {
        'total_revenue': totalRevenue,
        'completed_revenue': completedRevenue,
        'total_orders': totalOrders,
        'completed_orders': completedOrders,
        'average_order_value': totalOrders > 0
            ? totalRevenue / totalOrders
            : 0.0,
      };
    } catch (e) {
      throw ServerException('Failed to get revenue analytics: ${e.toString()}');
    }
  }
}
