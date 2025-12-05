import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/admin_dashboard_service.dart';

/// Order state
class OrderState {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> orders;
  final Map<String, dynamic>? selectedOrder;

  const OrderState({
    this.isLoading = false,
    this.error,
    this.orders = const [],
    this.selectedOrder,
  });

  OrderState copyWith({
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? orders,
    Map<String, dynamic>? selectedOrder,
  }) {
    return OrderState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      orders: orders ?? this.orders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
    );
  }
}

/// Order controller for managing order operations
class OrderController extends Notifier<OrderState> {
  @override
  OrderState build() => const OrderState();

  /// Get all orders
  Future<void> getOrders() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await AdminDashboardService.getRecentOrders(limit: 100);

      if (result['success'] == true) {
        final orders = (result['data'] as List).cast<Map<String, dynamic>>();
        state = state.copyWith(isLoading: false, orders: orders);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['error'] ?? 'Gagal memuat orders',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Terjadi kesalahan: $e');
    }
  }

  /// Get order details by ID
  Future<void> getOrderDetails(String orderId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await AdminDashboardService.getOrderDetails(orderId);

      if (result['success'] == true) {
        state = state.copyWith(isLoading: false, selectedOrder: result['data']);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['error'] ?? 'Gagal memuat detail order',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Terjadi kesalahan: $e');
    }
  }

  /// Cancel order
  Future<bool> cancelOrder(String orderId, String reason) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await AdminDashboardService.cancelOrder(orderId, reason);

      if (result['success'] == true) {
        state = state.copyWith(isLoading: false);
        // Refresh orders list
        await getOrders();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['error'] ?? 'Gagal membatalkan order',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Terjadi kesalahan: $e');
      return false;
    }
  }

  /// Reset state
  void reset() {
    state = const OrderState();
  }
}

/// Order controller provider
final orderControllerProvider = NotifierProvider<OrderController, OrderState>(
  () {
    return OrderController();
  },
);
