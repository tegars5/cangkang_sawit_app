import 'package:equatable/equatable.dart';

/// Dashboard Statistics Entity
/// Pure domain entity representing admin dashboard statistics
class DashboardStats extends Equatable {
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

  const DashboardStats({
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

  factory DashboardStats.empty() {
    return DashboardStats(
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
      totalRevenue: 0.0,
      monthlyRevenue: 0.0,
      weeklyRevenue: 0.0,
      dailyRevenue: 0.0,
      ordersTrend: 0.0,
      revenueTrend: 0.0,
      shipmentsTrend: 0.0,
      partnersTrend: 0.0,
      lastUpdated: DateTime.now(),
    );
  }

  // Business Methods

  /// Check if there are any pending orders
  bool hasPendingOrders() => pendingOrders > 0;

  /// Check if there are any active shipments
  bool hasActiveShipments() => activeShipments > 0;

  /// Check if orders trend is positive
  bool isOrdersTrendPositive() => ordersTrend > 0;

  /// Check if revenue trend is positive
  bool isRevenueTrendPositive() => revenueTrend > 0;

  /// Check if shipments trend is positive
  bool isShipmentsTrendPositive() => shipmentsTrend > 0;

  /// Check if partners trend is positive
  bool isPartnersTrendPositive() => partnersTrend > 0;

  /// Get completion rate as percentage
  double getCompletionRate() {
    if (totalOrders == 0) return 0.0;
    return (completedOrders / totalOrders) * 100;
  }

  /// Get cancellation rate as percentage
  double getCancellationRate() {
    if (totalOrders == 0) return 0.0;
    return (cancelledOrders / totalOrders) * 100;
  }

  /// Get average revenue per order
  double getAverageRevenuePerOrder() {
    if (totalOrders == 0) return 0.0;
    return totalRevenue / totalOrders;
  }

  /// Get active drivers percentage
  double getActiveDriversPercentage() {
    if (totalDrivers == 0) return 0.0;
    return (activeDrivers / totalDrivers) * 100;
  }

  /// Get active partners percentage
  double getActivePartnersPercentage() {
    if (totalPartners == 0) return 0.0;
    return (activePartners / totalPartners) * 100;
  }

  /// Check if data is stale (older than 5 minutes)
  bool isDataStale() {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    return difference.inMinutes > 5;
  }

  /// Get trend indicator text
  String getTrendText(double trend) {
    if (trend > 0) return '+${trend.toStringAsFixed(1)}%';
    if (trend < 0) return '${trend.toStringAsFixed(1)}%';
    return '0%';
  }

  /// Get trend indicator emoji
  String getTrendEmoji(double trend) {
    if (trend > 0) return '📈';
    if (trend < 0) return '📉';
    return '➡️';
  }

  /// Check if system is healthy
  bool isSystemHealthy() {
    return activeDrivers > 0 &&
        activePartners > 0 &&
        getCancellationRate() < 20.0;
  }

  /// Get system health status
  String getSystemHealthStatus() {
    if (isSystemHealthy()) return 'Healthy';
    if (activeDrivers == 0) return 'No Active Drivers';
    if (activePartners == 0) return 'No Active Partners';
    if (getCancellationRate() >= 20.0) return 'High Cancellation Rate';
    return 'Warning';
  }

  DashboardStats copyWith({
    int? totalOrders,
    int? pendingOrders,
    int? confirmedOrders,
    int? shippedOrders,
    int? completedOrders,
    int? cancelledOrders,
    int? activeShipments,
    int? activeDrivers,
    int? totalDrivers,
    int? activePartners,
    int? totalPartners,
    double? totalRevenue,
    double? monthlyRevenue,
    double? weeklyRevenue,
    double? dailyRevenue,
    double? ordersTrend,
    double? revenueTrend,
    double? shipmentsTrend,
    double? partnersTrend,
    DateTime? lastUpdated,
  }) {
    return DashboardStats(
      totalOrders: totalOrders ?? this.totalOrders,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      confirmedOrders: confirmedOrders ?? this.confirmedOrders,
      shippedOrders: shippedOrders ?? this.shippedOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      cancelledOrders: cancelledOrders ?? this.cancelledOrders,
      activeShipments: activeShipments ?? this.activeShipments,
      activeDrivers: activeDrivers ?? this.activeDrivers,
      totalDrivers: totalDrivers ?? this.totalDrivers,
      activePartners: activePartners ?? this.activePartners,
      totalPartners: totalPartners ?? this.totalPartners,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      weeklyRevenue: weeklyRevenue ?? this.weeklyRevenue,
      dailyRevenue: dailyRevenue ?? this.dailyRevenue,
      ordersTrend: ordersTrend ?? this.ordersTrend,
      revenueTrend: revenueTrend ?? this.revenueTrend,
      shipmentsTrend: shipmentsTrend ?? this.shipmentsTrend,
      partnersTrend: partnersTrend ?? this.partnersTrend,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
    totalOrders,
    pendingOrders,
    confirmedOrders,
    shippedOrders,
    completedOrders,
    cancelledOrders,
    activeShipments,
    activeDrivers,
    totalDrivers,
    activePartners,
    totalPartners,
    totalRevenue,
    monthlyRevenue,
    weeklyRevenue,
    dailyRevenue,
    ordersTrend,
    revenueTrend,
    shipmentsTrend,
    partnersTrend,
    lastUpdated,
  ];
}
