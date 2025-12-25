import 'package:equatable/equatable.dart';
import '../../domain/entities/order_summary.dart';

/// Mitra State
/// Immutable state class for mitra feature
class MitraState extends Equatable {
  final List<OrderSummary> orders;
  final OrderSummary? selectedOrder;
  final Map<String, dynamic>? dashboardStats;
  final Map<String, dynamic>? trackingInfo;
  final bool isLoading;
  final bool isLoadingOrders;
  final bool isLoadingStats;
  final bool isLoadingTracking;
  final String? error;
  final String? successMessage;

  const MitraState({
    this.orders = const [],
    this.selectedOrder,
    this.dashboardStats,
    this.trackingInfo,
    this.isLoading = false,
    this.isLoadingOrders = false,
    this.isLoadingStats = false,
    this.isLoadingTracking = false,
    this.error,
    this.successMessage,
  });

  // Computed Properties

  /// Get active orders (not completed or cancelled)
  List<OrderSummary> get activeOrders =>
      orders.where((o) => o.isActive()).toList();

  /// Get pending orders
  List<OrderSummary> get pendingOrders =>
      orders.where((o) => o.isPending()).toList();

  /// Get confirmed orders
  List<OrderSummary> get confirmedOrders =>
      orders.where((o) => o.isConfirmed()).toList();

  /// Get shipped orders
  List<OrderSummary> get shippedOrders =>
      orders.where((o) => o.isShipped()).toList();

  /// Get delivered orders
  List<OrderSummary> get deliveredOrders =>
      orders.where((o) => o.isDelivered()).toList();

  /// Get cancelled orders
  List<OrderSummary> get cancelledOrders =>
      orders.where((o) => o.isCancelled()).toList();

  /// Get trackable orders (has tracking number)
  List<OrderSummary> get trackableOrders =>
      orders.where((o) => o.canBeTracked()).toList();

  /// Get new orders (less than 7 days old)
  List<OrderSummary> get newOrders => orders.where((o) => o.isNew()).toList();

  /// Check if there are any errors
  bool get hasError => error != null;

  /// Check if there are any success messages
  bool get hasSuccessMessage => successMessage != null;

  /// Check if any loading operation is in progress
  bool get isAnyLoading =>
      isLoading || isLoadingOrders || isLoadingStats || isLoadingTracking;

  /// Check if tracking info is available
  bool get hasTrackingInfo =>
      trackingInfo != null && trackingInfo!['has_tracking'] == true;

  MitraState copyWith({
    List<OrderSummary>? orders,
    OrderSummary? selectedOrder,
    Map<String, dynamic>? dashboardStats,
    Map<String, dynamic>? trackingInfo,
    bool? isLoading,
    bool? isLoadingOrders,
    bool? isLoadingStats,
    bool? isLoadingTracking,
    String? error,
    String? successMessage,
  }) {
    return MitraState(
      orders: orders ?? this.orders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      dashboardStats: dashboardStats ?? this.dashboardStats,
      trackingInfo: trackingInfo ?? this.trackingInfo,
      isLoading: isLoading ?? this.isLoading,
      isLoadingOrders: isLoadingOrders ?? this.isLoadingOrders,
      isLoadingStats: isLoadingStats ?? this.isLoadingStats,
      isLoadingTracking: isLoadingTracking ?? this.isLoadingTracking,
      error: error,
      successMessage: successMessage,
    );
  }

  MitraState clearError() {
    return copyWith(error: '');
  }

  MitraState clearSuccessMessage() {
    return copyWith(successMessage: '');
  }

  MitraState clearSelectedOrder() {
    return copyWith(selectedOrder: null);
  }

  MitraState clearTrackingInfo() {
    return copyWith(trackingInfo: {});
  }

  @override
  List<Object?> get props => [
    orders,
    selectedOrder,
    dashboardStats,
    trackingInfo,
    isLoading,
    isLoadingOrders,
    isLoadingStats,
    isLoadingTracking,
    error,
    successMessage,
  ];
}
