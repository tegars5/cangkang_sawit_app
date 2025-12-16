import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/models.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/create_order.dart';
import '../../domain/usecases/get_orders.dart';
import '../../domain/usecases/confirm_order.dart';
import '../../domain/usecases/get_order_by_id.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../../data/repositories/order_repository_impl.dart';

/// Data Source Provider
final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  return OrderRemoteDataSource(client: Supabase.instance.client);
});

/// Repository Provider
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final dataSource = ref.read(orderRemoteDataSourceProvider);
  return OrderRepositoryImpl(remoteDataSource: dataSource);
});

/// Use Cases Providers
final getOrdersUseCaseProvider = Provider<GetOrders>((ref) {
  final repository = ref.read(orderRepositoryProvider);
  return GetOrders(repository);
});

final createOrderUseCaseProvider = Provider<CreateOrder>((ref) {
  final repository = ref.read(orderRepositoryProvider);
  return CreateOrder(repository);
});

final confirmOrderUseCaseProvider = Provider<ConfirmOrder>((ref) {
  final repository = ref.read(orderRepositoryProvider);
  return ConfirmOrder(repository);
});

final getOrderByIdUseCaseProvider = Provider<GetOrderById>((ref) {
  final repository = ref.read(orderRepositoryProvider);
  return GetOrderById(repository);
});

/// State Providers

/// Get orders with filtering
final ordersProvider = FutureProvider.autoDispose
    .family<List<Order>, GetOrdersParams>((ref, params) async {
      final useCase = ref.read(getOrdersUseCaseProvider);
      final result = await useCase.call(params);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (orders) => orders,
      );
    });

/// Get single order by ID
final orderByIdProvider = FutureProvider.autoDispose.family<Order, String>((
  ref,
  orderId,
) async {
  final useCase = ref.read(getOrderByIdUseCaseProvider);
  final result = await useCase.call(orderId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (order) => order,
  );
});

/// State notifier for order operations
class OrderNotifier extends StateNotifier<AsyncValue<Order?>> {
  final CreateOrder _createOrder;
  final ConfirmOrder _confirmOrder;

  OrderNotifier({
    required CreateOrder createOrder,
    required ConfirmOrder confirmOrder,
  }) : _createOrder = createOrder,
       _confirmOrder = confirmOrder,
       super(const AsyncValue.data(null));

  /// Create new order
  Future<void> createOrder({
    required Order order,
    required List<OrderDetail> items,
  }) async {
    state = const AsyncValue.loading();

    final result = await _createOrder.call(
      CreateOrderParams(order: order, items: items),
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (order) => AsyncValue.data(order),
    );
  }

  /// Confirm order
  Future<void> confirmOrder({
    required String orderId,
    required List<Map<String, dynamic>> confirmedItems,
  }) async {
    state = const AsyncValue.loading();

    final result = await _confirmOrder.call(
      ConfirmOrderParams(orderId: orderId, confirmedItems: confirmedItems),
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (order) => AsyncValue.data(order),
    );
  }

  /// Reset state
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Order notifier provider
final orderNotifierProvider =
    StateNotifierProvider<OrderNotifier, AsyncValue<Order?>>((ref) {
      return OrderNotifier(
        createOrder: ref.read(createOrderUseCaseProvider),
        confirmOrder: ref.read(confirmOrderUseCaseProvider),
      );
    });
