import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/dashboard_stats_model.dart';
import '../../orders/data/models/order_model.dart';

// Tab index provider for admin navigation (using StateProvider for backward compatibility)
final adminTabIndexProvider = StateProvider<int>((ref) => 0);

// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Dashboard stats provider
final dashboardStatsProvider = FutureProvider<DashboardStatsModel?>((
  ref,
) async {
  final supabase = ref.read(supabaseClientProvider);

  try {
    // Fetch total orders count
    final ordersCount = await supabase.rpc('count_orders');
    final totalOrders = (ordersCount as num?)?.toInt() ?? 0;

    // Fetch orders by status
    final pendingCount = await supabase.rpc(
      'count_orders_by_status',
      params: {'status_param': 'pending'},
    );
    final confirmedCount = await supabase.rpc(
      'count_orders_by_status',
      params: {'status_param': 'confirmed'},
    );
    final shippedCount = await supabase.rpc(
      'count_orders_by_status',
      params: {'status_param': 'shipped'},
    );
    final completedCount = await supabase.rpc(
      'count_orders_by_status',
      params: {'status_param': 'completed'},
    );
    final cancelledCount = await supabase.rpc(
      'count_orders_by_status',
      params: {'status_param': 'cancelled'},
    );

    // Fetch shipments and drivers
    final shipmentsResponse = await supabase
        .from('shipments')
        .select('id')
        .not('status', 'in', '(delivered,cancelled)');
    final activeShipments = (shipmentsResponse as List).length;

    final driversResponse = await supabase
        .from('profiles')
        .select('id')
        .eq('role', 'driver')
        .eq('is_active', true);
    final activeDrivers = (driversResponse as List).length;

    final allDriversResponse = await supabase
        .from('profiles')
        .select('id')
        .eq('role', 'driver');
    final totalDrivers = (allDriversResponse as List).length;

    final partnersResponse = await supabase
        .from('profiles')
        .select('id')
        .eq('role', 'mitra')
        .eq('is_active', true);
    final activePartners = (partnersResponse as List).length;

    final allPartnersResponse = await supabase
        .from('profiles')
        .select('id')
        .eq('role', 'mitra');
    final totalPartners = (allPartnersResponse as List).length;

    // Fetch revenue
    final revenueResponse = await supabase
        .from('orders')
        .select('total_price')
        .eq('status', 'completed');

    double totalRevenue = 0;
    double monthlyRevenue = 0;
    double weeklyRevenue = 0;
    double dailyRevenue = 0;

    for (var order in revenueResponse) {
      totalRevenue += (order['total_price'] as num?)?.toDouble() ?? 0;
    }

    // Get monthly revenue (last 30 days)
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    final monthlyResponse = await supabase
        .from('orders')
        .select('total_price')
        .eq('status', 'completed')
        .gte('created_at', monthAgo.toIso8601String());

    for (var order in monthlyResponse) {
      monthlyRevenue += (order['total_price'] as num?)?.toDouble() ?? 0;
    }

    // Get weekly revenue (last 7 days)
    final weekAgo = now.subtract(const Duration(days: 7));
    final weeklyResponse = await supabase
        .from('orders')
        .select('total_price')
        .eq('status', 'completed')
        .gte('created_at', weekAgo.toIso8601String());

    for (var order in weeklyResponse) {
      weeklyRevenue += (order['total_price'] as num?)?.toDouble() ?? 0;
    }

    // Get daily revenue (today)
    final today = DateTime(now.year, now.month, now.day);
    final dailyResponse = await supabase
        .from('orders')
        .select('total_price')
        .eq('status', 'completed')
        .gte('created_at', today.toIso8601String());

    for (var order in dailyResponse) {
      dailyRevenue += (order['total_price'] as num?)?.toDouble() ?? 0;
    }

    return DashboardStatsModel(
      totalOrders: totalOrders,
      pendingOrders: (pendingCount as num?)?.toInt() ?? 0,
      confirmedOrders: (confirmedCount as num?)?.toInt() ?? 0,
      shippedOrders: (shippedCount as num?)?.toInt() ?? 0,
      completedOrders: (completedCount as num?)?.toInt() ?? 0,
      cancelledOrders: (cancelledCount as num?)?.toInt() ?? 0,
      activeShipments: activeShipments,
      activeDrivers: activeDrivers,
      totalDrivers: totalDrivers,
      activePartners: activePartners,
      totalPartners: totalPartners,
      totalRevenue: totalRevenue,
      monthlyRevenue: monthlyRevenue,
      weeklyRevenue: weeklyRevenue,
      dailyRevenue: dailyRevenue,
      ordersTrend: 0.0,
      revenueTrend: 0.0,
      shipmentsTrend: 0.0,
      partnersTrend: 0.0,
      lastUpdated: DateTime.now(),
    );
  } catch (e) {
    // Return zero stats on error
    return DashboardStatsModel(
      totalOrders: 0,
      pendingOrders: 0,
      confirmedOrders: 0,
      shippedOrders: 0,
      completedOrders: 0,
      cancelledOrders: 0,
      activeShipments: 0,
      activeDrivers: 0,
      totalDrivers: 0,
      activePartners: 0,
      totalPartners: 0,
      totalRevenue: 0,
      monthlyRevenue: 0,
      weeklyRevenue: 0,
      dailyRevenue: 0,
      ordersTrend: 0.0,
      revenueTrend: 0.0,
      shipmentsTrend: 0.0,
      partnersTrend: 0.0,
      lastUpdated: DateTime.now(),
    );
  }
});

// Weekly order data model
class WeeklyOrderData {
  final String day;
  final int orders;

  const WeeklyOrderData({required this.day, required this.orders});
}

// Weekly order data provider
final weeklyOrderDataProvider = FutureProvider<List<WeeklyOrderData>>((
  ref,
) async {
  final supabase = ref.read(supabaseClientProvider);

  try {
    // Get orders from last 7 days
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final response = await supabase
        .from('orders')
        .select('created_at')
        .gte('created_at', sevenDaysAgo.toIso8601String());

    // Group by day
    final Map<String, int> dayCount = {
      'Mon': 0,
      'Tue': 0,
      'Wed': 0,
      'Thu': 0,
      'Fri': 0,
      'Sat': 0,
      'Sun': 0,
    };

    for (var order in response) {
      final createdAt = DateTime.parse(order['created_at'] as String);
      final dayName = _getDayName(createdAt.weekday);
      dayCount[dayName] = (dayCount[dayName] ?? 0) + 1;
    }

    return dayCount.entries
        .map((e) => WeeklyOrderData(day: e.key, orders: e.value))
        .toList();
  } catch (e) {
    // Return empty data on error
    return [
      const WeeklyOrderData(day: 'Mon', orders: 0),
      const WeeklyOrderData(day: 'Tue', orders: 0),
      const WeeklyOrderData(day: 'Wed', orders: 0),
      const WeeklyOrderData(day: 'Thu', orders: 0),
      const WeeklyOrderData(day: 'Fri', orders: 0),
      const WeeklyOrderData(day: 'Sat', orders: 0),
      const WeeklyOrderData(day: 'Sun', orders: 0),
    ];
  }
});

String _getDayName(int weekday) {
  switch (weekday) {
    case 1:
      return 'Mon';
    case 2:
      return 'Tue';
    case 3:
      return 'Wed';
    case 4:
      return 'Thu';
    case 5:
      return 'Fri';
    case 6:
      return 'Sat';
    case 7:
      return 'Sun';
    default:
      return 'Mon';
  }
}

// Recent orders provider
final recentOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final supabase = ref.read(supabaseClientProvider);

  try {
    final response = await supabase
        .from('orders')
        .select('''
          *,
          profiles:customer_id(*)
        ''')
        .order('created_at', ascending: false)
        .limit(10);

    return response.map((json) => OrderModel.fromJson(json)).toList();
  } catch (e) {
    return [];
  }
});

// Recent activities model
class RecentActivity {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String type; // 'order', 'delivery', 'user', etc.

  const RecentActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
  });
}

// Recent activities provider
final recentActivitiesProvider = FutureProvider<List<RecentActivity>>((
  ref,
) async {
  final supabase = ref.read(supabaseClientProvider);

  try {
    // Fetch recent order activities
    final ordersResponse = await supabase
        .from('orders')
        .select('id, status, created_at, updated_at')
        .order('updated_at', ascending: false)
        .limit(5);

    // Fetch recent shipment activities
    final shipmentsResponse = await supabase
        .from('shipments')
        .select('id, status, updated_at')
        .order('updated_at', ascending: false)
        .limit(5);

    List<RecentActivity> activities = [];

    // Add order activities
    for (var order in ordersResponse) {
      activities.add(
        RecentActivity(
          id: order['id'] as String,
          title: 'Order ${order['status']}',
          description:
              'Order ${order['id'].toString().substring(0, 8)}... updated',
          timestamp: DateTime.parse(order['updated_at'] as String),
          type: 'order',
        ),
      );
    }

    // Add shipment activities
    for (var shipment in shipmentsResponse) {
      activities.add(
        RecentActivity(
          id: shipment['id'] as String,
          title: 'Shipment ${shipment['status']}',
          description:
              'Shipment ${shipment['id'].toString().substring(0, 8)}... updated',
          timestamp: DateTime.parse(shipment['updated_at'] as String),
          type: 'delivery',
        ),
      );
    }

    // Sort by timestamp
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return activities.take(10).toList();
  } catch (e) {
    return [];
  }
});

// Product list provider
final productListProvider = FutureProvider<List<dynamic>>((ref) async {
  final supabase = ref.read(supabaseClientProvider);

  try {
    final response = await supabase
        .from('products')
        .select('*')
        .order('created_at', ascending: false);

    return response;
  } catch (e) {
    return [];
  }
});
