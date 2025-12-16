import '../../domain/entities/order.dart';

/// State for Order feature
class OrderState {
  final List<Order> orders;
  final Order? selectedOrder;
  final bool isLoading;
  final bool isCreating;
  final String? errorMessage;

  const OrderState({
    this.orders = const [],
    this.selectedOrder,
    this.isLoading = false,
    this.isCreating = false,
    this.errorMessage,
  });

  OrderState copyWith({
    List<Order>? orders,
    Order? selectedOrder,
    bool? isLoading,
    bool? isCreating,
    String? errorMessage,
    bool clearSelectedOrder = false,
    bool clearError = false,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      selectedOrder: clearSelectedOrder
          ? null
          : (selectedOrder ?? this.selectedOrder),
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OrderState &&
        other.orders == orders &&
        other.selectedOrder == selectedOrder &&
        other.isLoading == isLoading &&
        other.isCreating == isCreating &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return orders.hashCode ^
        selectedOrder.hashCode ^
        isLoading.hashCode ^
        isCreating.hashCode ^
        errorMessage.hashCode;
  }
}
