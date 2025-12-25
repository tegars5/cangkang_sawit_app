import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_dashboard_stats.dart';
import '../../domain/usecases/get_all_drivers.dart';
import '../../domain/usecases/get_active_drivers.dart';
import '../../domain/usecases/update_driver_status.dart';
import '../../domain/usecases/get_all_orders.dart';
import '../../domain/usecases/get_recent_orders.dart';
import 'admin_state.dart';

/// Admin Notifier
/// State management for admin operations
class AdminNotifier extends Notifier<AdminState> {
  late final GetDashboardStats _getDashboardStats;
  late final GetAllDrivers _getAllDrivers;
  late final GetActiveDrivers _getActiveDrivers;
  late final UpdateDriverStatus _updateDriverStatus;
  late final GetAllOrders _getAllOrders;
  late final GetRecentOrders _getRecentOrders;

  @override
  AdminState build() {
    // Initialize use cases from dependency injection
    _getDashboardStats = ref.read(getDashboardStatsUseCaseProvider);
    _getAllDrivers = ref.read(getAllDriversUseCaseProvider);
    _getActiveDrivers = ref.read(getActiveDriversUseCaseProvider);
    _updateDriverStatus = ref.read(updateDriverStatusUseCaseProvider);
    _getAllOrders = ref.read(getAllOrdersUseCaseProvider);
    _getRecentOrders = ref.read(getRecentOrdersUseCaseProvider);

    return const AdminState();
  }

  /// Load dashboard statistics
  Future<void> loadDashboardStats() async {
    state = state.copyWith(isLoadingStats: true, error: null);

    final result = await _getDashboardStats(NoParams());

    result.fold(
      (failure) =>
          state = state.copyWith(isLoadingStats: false, error: failure.message),
      (stats) =>
          state = state.copyWith(isLoadingStats: false, dashboardStats: stats),
    );
  }

  /// Load all drivers
  Future<void> loadAllDrivers() async {
    state = state.copyWith(isLoadingDrivers: true, error: null);

    final result = await _getAllDrivers(NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingDrivers: false,
        error: failure.message,
      ),
      (drivers) =>
          state = state.copyWith(isLoadingDrivers: false, drivers: drivers),
    );
  }

  /// Load active drivers only
  Future<void> loadActiveDrivers() async {
    state = state.copyWith(isLoadingDrivers: true, error: null);

    final result = await _getActiveDrivers(NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingDrivers: false,
        error: failure.message,
      ),
      (drivers) =>
          state = state.copyWith(isLoadingDrivers: false, drivers: drivers),
    );
  }

  /// Update driver status (activate/deactivate)
  Future<bool> toggleDriverStatus(String driverId, bool isActive) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _updateDriverStatus(
      UpdateDriverStatusParams(driverId: driverId, isActive: isActive),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (updatedDriver) {
        // Update driver in the list
        final updatedDrivers = state.drivers.map((d) {
          return d.id == updatedDriver.id ? updatedDriver : d;
        }).toList();

        state = state.copyWith(
          isLoading: false,
          drivers: updatedDrivers,
          successMessage: isActive
              ? 'Driver berhasil diaktifkan'
              : 'Driver berhasil dinonaktifkan',
        );

        // Refresh stats
        loadDashboardStats();

        return true;
      },
    );
  }

  /// Load all orders
  Future<void> loadAllOrders({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    state = state.copyWith(isLoadingOrders: true, error: null);

    final result = await _getAllOrders(
      GetAllOrdersParams(
        status: status,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingOrders: false,
        error: failure.message,
      ),
      (orders) =>
          state = state.copyWith(isLoadingOrders: false, orders: orders),
    );
  }

  /// Load recent orders
  Future<void> loadRecentOrders({int limit = 10}) async {
    state = state.copyWith(isLoadingOrders: true, error: null);

    final result = await _getRecentOrders(GetRecentOrdersParams(limit: limit));

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingOrders: false,
        error: failure.message,
      ),
      (orders) =>
          state = state.copyWith(isLoadingOrders: false, orders: orders),
    );
  }

  /// Load orders by status
  Future<void> loadOrdersByStatus(String status) async {
    await loadAllOrders(status: status);
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    state = state.copyWith(isLoading: true, error: null);

    await Future.wait([
      loadDashboardStats(),
      loadAllDrivers(),
      loadRecentOrders(),
    ]);

    state = state.copyWith(isLoading: false);
  }

  /// Refresh dashboard only
  Future<void> refreshDashboard() async {
    await loadDashboardStats();
  }

  /// Refresh drivers only
  Future<void> refreshDrivers() async {
    await loadAllDrivers();
  }

  /// Refresh orders only
  Future<void> refreshOrders() async {
    await loadRecentOrders();
  }

  /// Select a driver
  void selectDriver(String driverId) {
    final driver = state.drivers.firstWhere((d) => d.id == driverId);
    state = state.copyWith(selectedDriver: driver);
  }

  /// Clear selected driver
  void clearSelectedDriver() {
    state = state.copyWith(selectedDriver: null);
  }

  /// Select an order
  void selectOrder(String orderId) {
    final order = state.orders.firstWhere((o) => o.id == orderId);
    state = state.copyWith(selectedOrder: order);
  }

  /// Clear selected order
  void clearSelectedOrder() {
    state = state.copyWith(selectedOrder: null);
  }

  /// Clear error message
  void clearError() {
    state = state.clearError();
  }

  /// Clear success message
  void clearSuccessMessage() {
    state = state.clearSuccessMessage();
  }
}
