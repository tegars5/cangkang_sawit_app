import '../../domain/entities/dashboard_stats.dart';

/// Dashboard Statistics Model
/// Data transfer object for dashboard statistics
class DashboardStatsModel {
  final int totalOrders;
  final int pendingOrders;
  final int confirmedOrders;
  final int shippedOrders;
  final int completedOrders;
  final int cancelledOrders;
  final int activeShipments;
  final int activeDrivers;
  final int totalDrivers;
  final int activePartners;
  final int totalPartners;
  final double totalRevenue;
  final double monthlyRevenue;
  final double weeklyRevenue;
  final double dailyRevenue;
  final double ordersTrend;
  final double revenueTrend;
  final double shipmentsTrend;
  final double partnersTrend;
  final DateTime lastUpdated;

  DashboardStatsModel({
    required this.totalOrders,
    required this.pendingOrders,
    required this.confirmedOrders,
    required this.shippedOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.activeShipments,
    required this.activeDrivers,
    required this.totalDrivers,
    required this.activePartners,
    required this.totalPartners,
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.weeklyRevenue,
    required this.dailyRevenue,
    required this.ordersTrend,
    required this.revenueTrend,
    required this.shipmentsTrend,
    required this.partnersTrend,
    required this.lastUpdated,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalOrders: json['total_orders'] as int? ?? 0,
      pendingOrders: json['pending_orders'] as int? ?? 0,
      confirmedOrders: json['confirmed_orders'] as int? ?? 0,
      shippedOrders: json['shipped_orders'] as int? ?? 0,
      completedOrders: json['completed_orders'] as int? ?? 0,
      cancelledOrders: json['cancelled_orders'] as int? ?? 0,
      activeShipments: json['active_shipments'] as int? ?? 0,
      activeDrivers: json['active_drivers'] as int? ?? 0,
      totalDrivers: json['total_drivers'] as int? ?? 0,
      activePartners: json['active_partners'] as int? ?? 0,
      totalPartners: json['total_partners'] as int? ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      monthlyRevenue: (json['monthly_revenue'] as num?)?.toDouble() ?? 0.0,
      weeklyRevenue: (json['weekly_revenue'] as num?)?.toDouble() ?? 0.0,
      dailyRevenue: (json['daily_revenue'] as num?)?.toDouble() ?? 0.0,
      ordersTrend: (json['orders_trend'] as num?)?.toDouble() ?? 0.0,
      revenueTrend: (json['revenue_trend'] as num?)?.toDouble() ?? 0.0,
      shipmentsTrend: (json['shipments_trend'] as num?)?.toDouble() ?? 0.0,
      partnersTrend: (json['partners_trend'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_orders': totalOrders,
      'pending_orders': pendingOrders,
      'confirmed_orders': confirmedOrders,
      'shipped_orders': shippedOrders,
      'completed_orders': completedOrders,
      'cancelled_orders': cancelledOrders,
      'active_shipments': activeShipments,
      'active_drivers': activeDrivers,
      'total_drivers': totalDrivers,
      'active_partners': activePartners,
      'total_partners': totalPartners,
      'total_revenue': totalRevenue,
      'monthly_revenue': monthlyRevenue,
      'weekly_revenue': weeklyRevenue,
      'daily_revenue': dailyRevenue,
      'orders_trend': ordersTrend,
      'revenue_trend': revenueTrend,
      'shipments_trend': shipmentsTrend,
      'partners_trend': partnersTrend,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  DashboardStats toDomain() {
    return DashboardStats(
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
      lastUpdated: lastUpdated,
    );
  }

  factory DashboardStatsModel.fromDomain(DashboardStats entity) {
    return DashboardStatsModel(
      totalOrders: entity.totalOrders,
      pendingOrders: entity.pendingOrders,
      confirmedOrders: entity.confirmedOrders,
      shippedOrders: entity.shippedOrders,
      completedOrders: entity.completedOrders,
      cancelledOrders: entity.cancelledOrders,
      activeShipments: entity.activeShipments,
      activeDrivers: entity.activeDrivers,
      totalDrivers: entity.totalDrivers,
      activePartners: entity.activePartners,
      totalPartners: entity.totalPartners,
      totalRevenue: entity.totalRevenue,
      monthlyRevenue: entity.monthlyRevenue,
      weeklyRevenue: entity.weeklyRevenue,
      dailyRevenue: entity.dailyRevenue,
      ordersTrend: entity.ordersTrend,
      revenueTrend: entity.revenueTrend,
      shipmentsTrend: entity.shipmentsTrend,
      partnersTrend: entity.partnersTrend,
      lastUpdated: entity.lastUpdated,
    );
  }
}
