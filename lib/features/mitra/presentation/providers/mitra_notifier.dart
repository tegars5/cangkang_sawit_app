import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_order_history.dart';
import '../../domain/usecases/get_active_orders.dart';
import '../../domain/usecases/track_active_order.dart';
import '../../domain/usecases/get_mitra_dashboard_stats.dart';
import 'mitra_state.dart';

/// Mitra Notifier
/// State management for mitra (partner/customer) operations
class MitraNotifier extends Notifier<MitraState> {
  late final GetOrderHistory _getOrderHistory;
  late final GetActiveOrders _getActiveOrders;
  late final TrackActiveOrder _trackActiveOrder;
  late final GetMitraDashboardStats _getMitraDashboardStats;

  @override
  MitraState build() {
    // Initialize use cases from dependency injection
    _getOrderHistory = ref.read(getOrderHistoryUseCaseProvider);
    _getActiveOrders = ref.read(getActiveOrdersUseCaseProvider);
    _trackActiveOrder = ref.read(trackActiveOrderUseCaseProvider);
    _getMitraDashboardStats = ref.read(getMitraDashboardStatsUseCaseProvider);

    return const MitraState();
  }

  /// Load order history with optional filters
  Future<void> loadOrderHistory({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    state = state.copyWith(isLoadingOrders: true, error: null);

    final result = await _getOrderHistory(
      GetOrderHistoryParams(
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

  /// Load active orders only
  Future<void> loadActiveOrders() async {
    state = state.copyWith(isLoadingOrders: true, error: null);

    final result = await _getActiveOrders(NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingOrders: false,
        error: failure.message,
      ),
      (orders) =>
          state = state.copyWith(isLoadingOrders: false, orders: orders),
    );
  }

  /// Load dashboard statistics
  Future<void> loadDashboardStats() async {
    state = state.copyWith(isLoadingStats: true, error: null);

    final result = await _getMitraDashboardStats(NoParams());

    result.fold(
      (failure) =>
          state = state.copyWith(isLoadingStats: false, error: failure.message),
      (stats) =>
          state = state.copyWith(isLoadingStats: false, dashboardStats: stats),
    );
  }

  /// Track active order
  Future<void> trackOrder(String orderId) async {
    state = state.copyWith(isLoadingTracking: true, error: null);

    final result = await _trackActiveOrder(
      TrackActiveOrderParams(orderId: orderId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingTracking: false,
        error: failure.message,
      ),
      (trackingInfo) => state = state.copyWith(
        isLoadingTracking: false,
        trackingInfo: trackingInfo,
      ),
    );
  }

  /// Load orders by status
  Future<void> loadOrdersByStatus(String status) async {
    await loadOrderHistory(status: status);
  }

  /// Load completed orders
  Future<void> loadCompletedOrders() async {
    await loadOrderHistory(status: 'completed');
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    state = state.copyWith(isLoading: true, error: null);

    await Future.wait([loadDashboardStats(), loadActiveOrders()]);

    state = state.copyWith(isLoading: false);
  }

  /// Refresh dashboard only
  Future<void> refreshDashboard() async {
    await loadDashboardStats();
  }

  /// Refresh orders only
  Future<void> refreshOrders() async {
    await loadOrderHistory();
  }

  /// Select an order
  void selectOrder(String orderId) {
    final order = state.orders.firstWhere((o) => o.id == orderId);
    state = state.copyWith(selectedOrder: order);
  }

  /// Clear selected order
  void clearSelectedOrder() {
    state = state.clearSelectedOrder();
  }

  /// Clear tracking info
  void clearTrackingInfo() {
    state = state.clearTrackingInfo();
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
