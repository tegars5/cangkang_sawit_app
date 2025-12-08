import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/models.dart';
import '../../../shared/repositories/order_repository.dart';
import '../../../shared/repositories/product_repository.dart';
import '../../../core/services/supabase_service.dart';

/// Model untuk statistik dashboard
class DashboardStats {
  final int totalOrders;
  final int activeShipments;
  final int activePartners;
  final double monthlyRevenue;
  final double ordersTrend;
  final double shipmentsTrend;
  final double partnersTrend;
  final double revenueTrend;

  DashboardStats({
    required this.totalOrders,
    required this.activeShipments,
    required this.activePartners,
    required this.monthlyRevenue,
    required this.ordersTrend,
    required this.shipmentsTrend,
    required this.partnersTrend,
    required this.revenueTrend,
  });

  factory DashboardStats.empty() {
    return DashboardStats(
      totalOrders: 0,
      activeShipments: 0,
      activePartners: 0,
      monthlyRevenue: 0,
      ordersTrend: 0,
      shipmentsTrend: 0,
      partnersTrend: 0,
      revenueTrend: 0,
    );
  }
}

/// Model untuk data chart pesanan mingguan
class WeeklyOrderData {
  final List<int> values;
  final List<String> labels;

  WeeklyOrderData({required this.values, required this.labels});

  factory WeeklyOrderData.empty() {
    return WeeklyOrderData(
      values: [0, 0, 0, 0, 0, 0, 0],
      labels: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
    );
  }
}

/// Model untuk aktivitas terkini
class DashboardActivity {
  final String title;
  final String subtitle;
  final String time;
  final String iconType;
  final String colorType;

  DashboardActivity({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.iconType,
    required this.colorType,
  });
}

/// Provider untuk current admin tab index
final adminTabIndexProvider = NotifierProvider<AdminTabIndexNotifier, int>(
  AdminTabIndexNotifier.new,
);

class AdminTabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

/// Provider untuk product repository instance
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

/// Provider untuk order repository instance
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

/// Provider untuk fetching all products
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return await repo.getAllProducts();
});

/// AsyncNotifier untuk Product List dengan CRUD operations (Riverpod 3.0)
class ProductListNotifier extends AsyncNotifier<List<Product>> {
  late ProductRepository _repository;

  @override
  Future<List<Product>> build() async {
    _repository = ref.watch(productRepositoryProvider);
    return await _repository.getAllProducts();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAllProducts());
  }

  Future<void> createProduct({
    required String name,
    required double pricePerTon,
    double? stockAvailable,
  }) async {
    await _repository.createProduct(
      name: name,
      pricePerTon: pricePerTon,
      stockAvailable: stockAvailable ?? 0,
    );
    await refresh();
  }

  Future<void> updateProduct({
    required String productId,
    required String name,
    required double pricePerTon,
    double? stockAvailable,
  }) async {
    await _repository.updateProduct(
      productId: productId,
      name: name,
      pricePerTon: pricePerTon,
      stockAvailable: stockAvailable,
    );
    await refresh();
  }

  Future<void> deleteProduct(String productId) async {
    await _repository.deleteProduct(productId);
    await refresh();
  }
}

/// Provider untuk product list dengan AsyncNotifier (Riverpod 3.0)
final productListProvider =
    AsyncNotifierProvider<ProductListNotifier, List<Product>>(
      ProductListNotifier.new,
    );

/// Provider untuk dashboard statistics
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  try {
    final supabase = SupabaseService.instance.client;
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final lastDayOfLastMonth = DateTime(now.year, now.month, 0);

    // Get total orders this month
    final ordersThisMonth = await supabase
        .from('orders')
        .select('id, total_amount, created_at')
        .gte('created_at', firstDayOfMonth.toIso8601String())
        .lte('created_at', now.toIso8601String());

    // Get orders last month for trend calculation
    final ordersLastMonth = await supabase
        .from('orders')
        .select('id')
        .gte('created_at', lastMonth.toIso8601String())
        .lte('created_at', lastDayOfLastMonth.toIso8601String());

    // Get active shipments (status: in_transit)
    final activeShipments = await supabase
        .from('shipments')
        .select('id')
        .eq('status', 'in_transit');

    // Get shipments last month for trend
    final shipmentsLastMonth = await supabase
        .from('shipments')
        .select('id')
        .gte('created_at', lastMonth.toIso8601String())
        .lte('created_at', lastDayOfLastMonth.toIso8601String())
        .eq('status', 'in_transit');

    // Get active partners (role_id = 2)
    final activePartners = await supabase
        .from('profiles')
        .select('id, created_at')
        .eq('role_id', 2);

    // Get partners last month for trend
    final partnersLastMonth = await supabase
        .from('profiles')
        .select('id')
        .eq('role_id', 2)
        .gte('created_at', lastMonth.toIso8601String())
        .lte('created_at', lastDayOfLastMonth.toIso8601String());

    // Calculate monthly revenue
    double monthlyRevenue = 0;
    double lastMonthRevenue = 0;

    for (var order in ordersThisMonth) {
      final amount = order['total_amount'];
      if (amount != null) {
        monthlyRevenue += (amount is int)
            ? amount.toDouble()
            : amount as double;
      }
    }

    // Get last month revenue for trend
    final revenueLastMonth = await supabase
        .from('orders')
        .select('total_amount')
        .gte('created_at', lastMonth.toIso8601String())
        .lte('created_at', lastDayOfLastMonth.toIso8601String());

    for (var order in revenueLastMonth) {
      final amount = order['total_amount'];
      if (amount != null) {
        lastMonthRevenue += (amount is int)
            ? amount.toDouble()
            : amount as double;
      }
    }

    // Calculate trends (percentage change from last month)
    double calculateTrend(int current, int previous) {
      if (previous == 0) return current > 0 ? 100.0 : 0.0;
      return ((current - previous) / previous) * 100;
    }

    double calculateRevenueTrend(double current, double previous) {
      if (previous == 0) return current > 0 ? 100.0 : 0.0;
      return ((current - previous) / previous) * 100;
    }

    return DashboardStats(
      totalOrders: ordersThisMonth.length,
      activeShipments: activeShipments.length,
      activePartners: activePartners.length,
      monthlyRevenue: monthlyRevenue,
      ordersTrend: calculateTrend(
        ordersThisMonth.length,
        ordersLastMonth.length,
      ),
      shipmentsTrend: calculateTrend(
        activeShipments.length,
        shipmentsLastMonth.length,
      ),
      partnersTrend: calculateTrend(
        activePartners.length,
        partnersLastMonth.length,
      ),
      revenueTrend: calculateRevenueTrend(monthlyRevenue, lastMonthRevenue),
    );
  } catch (e) {
    throw Exception('Gagal memuat statistik dashboard: $e');
  }
});

/// Provider untuk weekly order chart data
final weeklyOrderDataProvider = FutureProvider<WeeklyOrderData>((ref) async {
  try {
    final supabase = SupabaseService.instance.client;
    final now = DateTime.now();
    final List<int> values = [];
    final List<String> labels = [
      'Sen',
      'Sel',
      'Rab',
      'Kam',
      'Jum',
      'Sab',
      'Min',
    ];

    // Get orders for last 7 days
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final ordersCount = await supabase
          .from('orders')
          .select('id')
          .gte('created_at', startOfDay.toIso8601String())
          .lte('created_at', endOfDay.toIso8601String());

      values.add(ordersCount.length);
    }

    return WeeklyOrderData(values: values, labels: labels);
  } catch (e) {
    throw Exception('Gagal memuat data chart: $e');
  }
});

/// Provider untuk recent orders (3 terakhir)
final recentOrdersProvider = FutureProvider<List<Order>>((ref) async {
  try {
    final orderRepo = ref.watch(orderRepositoryProvider);
    final allOrders = await orderRepo.getOrders();

    // Sort by created_at descending and take first 3
    allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allOrders.take(3).toList();
  } catch (e) {
    throw Exception('Gagal memuat pesanan terbaru: $e');
  }
});

/// Provider untuk recent activities
final recentActivitiesProvider = FutureProvider<List<DashboardActivity>>((
  ref,
) async {
  try {
    final supabase = SupabaseService.instance.client;
    final List<DashboardActivity> activities = [];

    // Get recent orders (last 5)
    final recentOrders = await supabase
        .from('orders')
        .select('id, order_number, created_at, profiles:customer_id(full_name)')
        .order('created_at', ascending: false)
        .limit(2);

    for (var order in recentOrders) {
      final customerName = order['profiles']?['full_name'] ?? 'Unknown';
      final orderNumber = order['order_number'] ?? 'N/A';
      final createdAt = DateTime.parse(order['created_at']);
      final timeAgo = _getTimeAgo(createdAt);

      activities.add(
        DashboardActivity(
          title: 'Pesanan baru diterima',
          subtitle: '$customerName - $orderNumber',
          time: timeAgo,
          iconType: 'new_order',
          colorType: 'blue',
        ),
      );
    }

    // Get recent shipments
    final recentShipments = await supabase
        .from('shipments')
        .select('id, tracking_number, created_at, status')
        .eq('status', 'in_transit')
        .order('created_at', ascending: false)
        .limit(1);

    for (var shipment in recentShipments) {
      final trackingNumber = shipment['tracking_number'] ?? 'N/A';
      final createdAt = DateTime.parse(shipment['created_at']);
      final timeAgo = _getTimeAgo(createdAt);

      activities.add(
        DashboardActivity(
          title: 'Pengiriman dimulai',
          subtitle: 'Tracking: $trackingNumber',
          time: timeAgo,
          iconType: 'shipment',
          colorType: 'orange',
        ),
      );
    }

    // Get recent partners
    final recentPartners = await supabase
        .from('profiles')
        .select('id, full_name, created_at')
        .eq('role_id', 2)
        .order('created_at', ascending: false)
        .limit(1);

    for (var partner in recentPartners) {
      final name = partner['full_name'] ?? 'Unknown';
      final createdAt = DateTime.parse(partner['created_at']);
      final timeAgo = _getTimeAgo(createdAt);

      activities.add(
        DashboardActivity(
          title: 'Mitra baru terdaftar',
          subtitle: name,
          time: timeAgo,
          iconType: 'new_partner',
          colorType: 'purple',
        ),
      );
    }

    return activities;
  } catch (e) {
    throw Exception('Gagal memuat aktivitas terkini: $e');
  }
});

/// Helper function to calculate time ago
String _getTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays > 0) {
    return '${difference.inDays} hari lalu';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} jam lalu';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} menit lalu';
  } else {
    return 'Baru saja';
  }
}
