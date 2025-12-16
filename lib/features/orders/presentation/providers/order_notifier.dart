import 'package:flutter_riverpod/legacy.dart';
import 'package:state_notifier/state_notifier.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/cancel_order.dart';
import '../../domain/usecases/confirm_order.dart';
import '../../domain/usecases/create_order.dart';
import '../../domain/usecases/get_order_by_id.dart';
import '../../domain/usecases/get_orders.dart';
import 'order_state.dart';

/// StateNotifier for managing order state
class OrderNotifier extends StateNotifier<OrderState> {
  final GetOrders getOrdersUseCase;
  final GetOrderById getOrderByIdUseCase;
  final CreateOrder createOrderUseCase;
  final ConfirmOrder confirmOrderUseCase;
  final CancelOrder cancelOrderUseCase;

  OrderNotifier({
    required this.getOrdersUseCase,
    required this.getOrderByIdUseCase,
    required this.createOrderUseCase,
    required this.confirmOrderUseCase,
    required this.cancelOrderUseCase,
  }) : super(const OrderState());

  /// Load orders with optional filters
  Future<void> loadOrders({String? customerId, String? status}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await getOrdersUseCase(
      GetOrdersParams(customerId: customerId, status: status),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (orders) => state = state.copyWith(
        isLoading: false,
        orders: orders,
        clearError: true,
      ),
    );
  }

  /// Load single order by ID
  Future<void> loadOrderById(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await getOrderByIdUseCase(id);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (order) => state = state.copyWith(
        isLoading: false,
        selectedOrder: order,
        clearError: true,
      ),
    );
  }

  /// Create new order
  Future<bool> createOrder(Order order) async {
    state = state.copyWith(isCreating: true, clearError: true);

    final result = await createOrderUseCase(order);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isCreating: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (createdOrder) {
        state = state.copyWith(
          isCreating: false,
          orders: [createdOrder, ...state.orders],
          selectedOrder: createdOrder,
          clearError: true,
        );
        return true;
      },
    );
  }

  /// Confirm order (Admin only)
  Future<bool> confirmOrder(String orderId, double confirmedQuantity) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await confirmOrderUseCase(
      ConfirmOrderParams(
        orderId: orderId,
        confirmedQuantity: confirmedQuantity,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (confirmedOrder) {
        // Update order in list
        final updatedOrders = state.orders.map((order) {
          return order.id == confirmedOrder.id ? confirmedOrder : order;
        }).toList();

        state = state.copyWith(
          isLoading: false,
          orders: updatedOrders,
          selectedOrder: confirmedOrder,
          clearError: true,
        );
        return true;
      },
    );
  }

  /// Cancel order
  Future<bool> cancelOrder(String orderId, String reason) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await cancelOrderUseCase(
      CancelOrderParams(orderId: orderId, reason: reason),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (cancelledOrder) {
        // Update order in list
        final updatedOrders = state.orders.map((order) {
          return order.id == cancelledOrder.id ? cancelledOrder : order;
        }).toList();

        state = state.copyWith(
          isLoading: false,
          orders: updatedOrders,
          selectedOrder: cancelledOrder,
          clearError: true,
        );
        return true;
      },
    );
  }

  /// Clear selected order
  void clearSelectedOrder() {
    state = state.copyWith(clearSelectedOrder: true);
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for OrderNotifier
final orderNotifierProvider = StateNotifierProvider<OrderNotifier, OrderState>((
  ref,
) {
  return OrderNotifier(
    getOrdersUseCase: ref.read(getOrdersUseCaseProvider),
    getOrderByIdUseCase: ref.read(getOrderByIdUseCaseProvider),
    createOrderUseCase: ref.read(createOrderUseCaseProvider),
    confirmOrderUseCase: ref.read(confirmOrderUseCaseProvider),
    cancelOrderUseCase: ref.read(cancelOrderUseCaseProvider),
  );
});
