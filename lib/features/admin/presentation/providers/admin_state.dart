import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/driver_info.dart';
import '../../../orders/domain/entities/order.dart';

/// Admin State
/// Immutable state class for admin feature
class AdminState extends Equatable {
  final DashboardStats? dashboardStats;
  final List<DriverInfo> drivers;
  final List<Order> orders;
  final DriverInfo? selectedDriver;
  final Order? selectedOrder;
  final bool isLoading;
  final bool isLoadingStats;
  final bool isLoadingDrivers;
  final bool isLoadingOrders;
  final String? error;
  final String? successMessage;

  const AdminState({
    this.dashboardStats,
    this.drivers = const [],
    this.orders = const [],
    this.selectedDriver,
    this.selectedOrder,
    this.isLoading = false,
    this.isLoadingStats = false,
    this.isLoadingDrivers = false,
    this.isLoadingOrders = false,
    this.error,
    this.successMessage,
  });

  // Computed Properties

  /// Get active drivers
  List<DriverInfo> get activeDrivers =>
      drivers.where((d) => d.isCurrentlyActive()).toList();

  /// Get available drivers (active and not on duty)
  List<DriverInfo> get availableDrivers =>
      drivers.where((d) => d.isAvailable()).toList();

  /// Get drivers on duty
  List<DriverInfo> get driversOnDuty =>
      drivers.where((d) => d.isOnDuty()).toList();

  /// Get inactive drivers
  List<DriverInfo> get inactiveDrivers =>
      drivers.where((d) => !d.isCurrentlyActive()).toList();

  /// Get pending orders
  List<Order> get pendingOrders => orders.where((o) => o.isPending()).toList();

  /// Get confirmed orders
  List<Order> get confirmedOrders =>
      orders.where((o) => o.isConfirmed()).toList();

  /// Get shipped orders
  List<Order> get shippedOrders => orders.where((o) => o.isShipped()).toList();

  /// Get completed orders
  List<Order> get completedOrders =>
      orders.where((o) => o.isCompleted()).toList();

  /// Get cancelled orders
  List<Order> get cancelledOrders =>
      orders.where((o) => o.isCancelled()).toList();

  /// Check if there are any errors
  bool get hasError => error != null;

  /// Check if there are any success messages
  bool get hasSuccessMessage => successMessage != null;

  /// Check if any loading operation is in progress
  bool get isAnyLoading =>
      isLoading || isLoadingStats || isLoadingDrivers || isLoadingOrders;

  AdminState copyWith({
    DashboardStats? dashboardStats,
    List<DriverInfo>? drivers,
    List<Order>? orders,
    DriverInfo? selectedDriver,
    Order? selectedOrder,
    bool? isLoading,
    bool? isLoadingStats,
    bool? isLoadingDrivers,
    bool? isLoadingOrders,
    String? error,
    String? successMessage,
  }) {
    return AdminState(
      dashboardStats: dashboardStats ?? this.dashboardStats,
      drivers: drivers ?? this.drivers,
      orders: orders ?? this.orders,
      selectedDriver: selectedDriver ?? this.selectedDriver,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      isLoading: isLoading ?? this.isLoading,
      isLoadingStats: isLoadingStats ?? this.isLoadingStats,
      isLoadingDrivers: isLoadingDrivers ?? this.isLoadingDrivers,
      isLoadingOrders: isLoadingOrders ?? this.isLoadingOrders,
      error: error,
      successMessage: successMessage,
    );
  }

  AdminState clearError() {
    return copyWith(error: '');
  }

  AdminState clearSuccessMessage() {
    return copyWith(successMessage: '');
  }

  @override
  List<Object?> get props => [
    dashboardStats,
    drivers,
    orders,
    selectedDriver,
    selectedOrder,
    isLoading,
    isLoadingStats,
    isLoadingDrivers,
    isLoadingOrders,
    error,
    successMessage,
  ];
}
