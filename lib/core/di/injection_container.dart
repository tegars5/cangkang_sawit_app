import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Auth Feature Imports
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/register.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';

// Products Feature Imports
import '../../features/products/data/datasources/product_remote_datasource.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';

// Shipments Feature Imports
import '../../features/shipments/data/datasources/shipment_remote_datasource.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/get_products.dart';
import '../../features/products/domain/usecases/get_product_by_id.dart';
import '../../features/products/domain/usecases/search_products.dart';

// Orders Feature Imports
import '../../features/orders/data/datasources/order_remote_datasource.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/domain/usecases/get_orders.dart';
import '../../features/orders/domain/usecases/get_order_by_id.dart';
import '../../features/orders/domain/usecases/create_order.dart';
import '../../features/orders/domain/usecases/confirm_order.dart';
import '../../features/orders/domain/usecases/cancel_order.dart';
import '../../features/orders/domain/usecases/update_order_status.dart';

// Tracking Feature Imports
import '../../features/tracking/data/datasources/tracking_remote_datasource.dart';
import '../../features/tracking/data/repositories/tracking_repository_impl.dart';
import '../../features/tracking/domain/repositories/tracking_repository.dart';
import '../../features/tracking/domain/usecases/subscribe_driver_location.dart';
import '../../features/tracking/domain/usecases/update_driver_location.dart';
import '../../features/tracking/domain/usecases/get_location_history.dart';
import '../../features/tracking/domain/usecases/get_current_location.dart';

// Shipments Feature Imports - COMMENTED OUT (files don't exist yet)
// TODO: Uncomment when shipment feature files are created
// import '../../features/shipments/data/datasources/shipment_remote_datasource_v2.dart';
// import '../../features/shipments/data/repositories/shipment_repository_impl_new.dart';
// import '../../features/shipments/domain/repositories/shipment_repository.dart';
// import '../../features/shipments/domain/usecases/get_shipments.dart';
// import '../../features/shipments/domain/usecases/get_shipment_by_id.dart';
// import '../../features/shipments/domain/usecases/create_shipment.dart';
// import '../../features/shipments/domain/usecases/assign_driver.dart';
// import '../../features/shipments/domain/usecases/update_shipment_status.dart';
// import '../../features/shipments/domain/usecases/mark_shipment_as_picked_up.dart';
// import '../../features/shipments/domain/usecases/mark_shipment_as_delivered.dart';
// import '../../features/shipments/domain/usecases/cancel_shipment.dart';
// import '../../features/shipments/presentation/providers/shipment_notifier.dart';
// import '../../features/shipments/presentation/providers/shipment_state.dart';

// Driver Feature Imports
import '../../features/driver/data/datasources/driver_remote_datasource.dart';
import '../../features/driver/data/repositories/driver_repository_impl.dart';
import '../../features/driver/domain/repositories/driver_repository.dart';
import '../../features/driver/domain/usecases/get_assigned_deliveries.dart';
import '../../features/driver/domain/usecases/get_today_deliveries.dart';
import '../../features/driver/domain/usecases/update_delivery_status.dart';
import '../../features/driver/domain/usecases/mark_delivery_as_picked_up.dart';
import '../../features/driver/domain/usecases/mark_delivery_as_delivered.dart';
import '../../features/driver/domain/usecases/upload_proof_of_delivery.dart';
import '../../features/driver/presentation/providers/driver_notifier.dart';
import '../../features/driver/presentation/providers/driver_state.dart';

// Admin Feature Imports (Phase 8)
import '../../features/admin/data/datasources/admin_remote_datasource.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/domain/usecases/get_dashboard_stats.dart';
import '../../features/admin/domain/usecases/get_all_drivers.dart';
import '../../features/admin/domain/usecases/get_active_drivers.dart';
import '../../features/admin/domain/usecases/update_driver_status.dart';
import '../../features/admin/domain/usecases/get_all_orders.dart';
import '../../features/admin/domain/usecases/get_recent_orders.dart';
import '../../features/admin/presentation/providers/admin_notifier.dart';
import '../../features/admin/presentation/providers/admin_state.dart';

// Mitra Feature Imports (Phase 9)
import '../../features/mitra/data/datasources/mitra_remote_datasource.dart';
import '../../features/mitra/data/repositories/mitra_repository_impl.dart';
import '../../features/mitra/domain/repositories/mitra_repository.dart';
import '../../features/mitra/domain/usecases/get_order_history.dart';
import '../../features/mitra/domain/usecases/get_active_orders.dart';
import '../../features/mitra/domain/usecases/track_active_order.dart';
import '../../features/mitra/domain/usecases/get_mitra_dashboard_stats.dart';
import '../../features/mitra/presentation/providers/mitra_notifier.dart';
import '../../features/mitra/presentation/providers/mitra_state.dart';

// Cart Feature Imports (Phase 10)
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/cart/data/datasources/cart_local_datasource.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/usecases/get_cart_items.dart';
import '../../features/cart/domain/usecases/add_to_cart.dart';
import '../../features/cart/domain/usecases/remove_from_cart.dart';
import '../../features/cart/domain/usecases/update_cart_quantity.dart';
import '../../features/cart/domain/usecases/clear_cart.dart';
import '../../features/cart/presentation/providers/cart_notifier.dart';
import '../../features/cart/presentation/providers/cart_state.dart';

// Core Services
import '../services/file_upload_service.dart';

// ============================================================================
// CORE SERVICES
// ============================================================================

/// Provider for Supabase client
/// This is the single source of truth for Supabase access
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for SharedPreferences
/// Used for local storage operations
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences must be initialized in main.dart',
  );
});

/// Provider for File Upload Service
/// Used for uploading files to Supabase Storage
final fileUploadServiceProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return FileUploadService(client);
});

// ============================================================================
// AUTH FEATURE
// ============================================================================

// Data Sources
final authRemoteDataSourceProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRemoteDataSource(client: client);
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource: dataSource);
});

// Use Cases
final loginUseCaseProvider = Provider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return Login(repository);
});

final registerUseCaseProvider = Provider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return Register(repository);
});

final logoutUseCaseProvider = Provider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return Logout(repository);
});

final getCurrentUserUseCaseProvider = Provider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUser(repository);
});

// ============================================================================
// PRODUCTS FEATURE
// ============================================================================

// Data Sources
final productRemoteDataSourceProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ProductRemoteDataSource(client: client);
});

// Repositories
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final dataSource = ref.watch(productRemoteDataSourceProvider);
  return ProductRepositoryImpl(remoteDataSource: dataSource);
});

// Use Cases
final getProductsUseCaseProvider = Provider<GetProducts>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProducts(repository);
});

final getProductByIdUseCaseProvider = Provider<GetProductById>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProductById(repository);
});

final searchProductsUseCaseProvider = Provider<SearchProducts>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return SearchProducts(repository);
});

// ============================================================================
// ORDERS FEATURE
// ============================================================================

// Data Sources
final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return OrderRemoteDataSourceImpl(client: client);
});

// Repositories
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final dataSource = ref.watch(orderRemoteDataSourceProvider);
  return OrderRepositoryImpl(remoteDataSource: dataSource);
});

// Use Cases
final getOrdersUseCaseProvider = Provider<GetOrders>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return GetOrders(repository);
});

final getOrderByIdUseCaseProvider = Provider<GetOrderById>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return GetOrderById(repository);
});

final createOrderUseCaseProvider = Provider<CreateOrder>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return CreateOrder(repository);
});

final confirmOrderUseCaseProvider = Provider<ConfirmOrder>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return ConfirmOrder(repository);
});

final cancelOrderUseCaseProvider = Provider<CancelOrder>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return CancelOrder(repository);
});

final updateOrderStatusUseCaseProvider = Provider<UpdateOrderStatus>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return UpdateOrderStatus(repository);
});

// ============================================================================
// TRACKING FEATURE
// ============================================================================

// Data Sources
final trackingRemoteDataSourceProvider = Provider<TrackingRemoteDataSource>((
  ref,
) {
  final client = ref.watch(supabaseClientProvider);
  return TrackingRemoteDataSourceImpl(client: client);
});

// Repositories
final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  final dataSource = ref.watch(trackingRemoteDataSourceProvider);
  return TrackingRepositoryImpl(remoteDataSource: dataSource);
});

// Use Cases
final subscribeDriverLocationUseCaseProvider =
    Provider<SubscribeDriverLocation>((ref) {
      final repository = ref.watch(trackingRepositoryProvider);
      return SubscribeDriverLocation(repository);
    });

final getLocationHistoryUseCaseProvider = Provider<GetLocationHistory>((ref) {
  final repository = ref.watch(trackingRepositoryProvider);
  return GetLocationHistory(repository);
});

final getCurrentLocationUseCaseProvider = Provider<GetCurrentLocation>((ref) {
  final repository = ref.watch(trackingRepositoryProvider);
  return GetCurrentLocation(repository);
});

final updateDriverLocationUseCaseProvider = Provider<UpdateDriverLocation>((
  ref,
) {
  final repository = ref.watch(trackingRepositoryProvider);
  return UpdateDriverLocation(repository);
});

// ============================================================================
// SHIPMENTS FEATURE (Phase 6)
// ============================================================================

// Data Sources
final shipmentRemoteDataSourceProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ShipmentRemoteDataSource(client: client);
});

// ============================================================================
// SHIPMENT FEATURE - COMMENTED OUT (files don't exist yet)
// TODO: Uncomment when shipment feature files are created
// ============================================================================
/*
// Data Sources
final shipmentRemoteDataSourceProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ShipmentRemoteDataSourceImplV2(client);
});

// Repositories
final shipmentRepositoryProvider = Provider<ShipmentRepository>((ref) {
  final dataSource = ref.watch(shipmentRemoteDataSourceProvider);
  return ShipmentRepositoryImplNew(remoteDataSource: dataSource);
});

// Use Cases
final getShipmentsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(shipmentRepositoryProvider);
  return GetShipments(repository);
});

final getShipmentByIdUseCaseProvider = Provider((ref) {
  final repository = ref.watch(shipmentRepositoryProvider);
  return GetShipmentById(repository);
});

final createShipmentUseCaseProvider = Provider((ref) {
  final repository = ref.watch(shipmentRepositoryProvider);
  return CreateShipment(repository);
});

final assignDriverUseCaseProvider = Provider((ref) {
  final repository = ref.watch(shipmentRepositoryProvider);
  return AssignDriver(repository);
});

final updateShipmentStatusUseCaseProvider = Provider((ref) {
  final repository = ref.watch(shipmentRepositoryProvider);
  return UpdateShipmentStatus(repository);
});

final markShipmentAsPickedUpUseCaseProvider = Provider((ref) {
  final repository = ref.watch(shipmentRepositoryProvider);
  return MarkShipmentAsPickedUp(repository);
});

final markShipmentAsDeliveredUseCaseProvider = Provider((ref) {
  final repository = ref.watch(shipmentRepositoryProvider);
  return MarkShipmentAsDelivered(repository);
});

final cancelShipmentUseCaseProvider = Provider((ref) {
  final repository = ref.watch(shipmentRepositoryProvider);
  return CancelShipment(repository);
});

// Presentation (Notifier)
final shipmentNotifierProvider =
    NotifierProvider<ShipmentNotifier, ShipmentState>(() {
      return ShipmentNotifier();
    });
*/

// ============================================================================
// DRIVER FEATURE (Phase 7)
// ============================================================================

// Data Sources
final driverRemoteDataSourceProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  // TODO: Implement DriverRemoteDataSourceImpl properly
  return DriverRemoteDataSource(client: client);
  // return DriverRemoteDataSourceImpl(client: client);
});

// Repositories
final driverRepositoryProvider = Provider<DriverRepository>((ref) {
  final dataSource = ref.watch(driverRemoteDataSourceProvider);
  return DriverRepositoryImpl(remoteDataSource: dataSource);
});

// Use Cases
final getAssignedDeliveriesUseCaseProvider = Provider((ref) {
  final repository = ref.watch(driverRepositoryProvider);
  return GetAssignedDeliveries(repository);
});

final getTodayDeliveriesUseCaseProvider = Provider((ref) {
  final repository = ref.watch(driverRepositoryProvider);
  return GetTodayDeliveries(repository);
});

final updateDeliveryStatusUseCaseProvider = Provider((ref) {
  final repository = ref.watch(driverRepositoryProvider);
  return UpdateDeliveryStatus(repository);
});

final markDeliveryAsPickedUpUseCaseProvider = Provider((ref) {
  final repository = ref.watch(driverRepositoryProvider);
  return MarkDeliveryAsPickedUp(repository);
});

final markDeliveryAsDeliveredUseCaseProvider = Provider((ref) {
  final repository = ref.watch(driverRepositoryProvider);
  return MarkDeliveryAsDelivered(repository);
});

final uploadProofOfDeliveryUseCaseProvider = Provider((ref) {
  final repository = ref.watch(driverRepositoryProvider);
  return UploadProofOfDelivery(repository);
});

// Presentation (Notifier)
final driverNotifierProvider = NotifierProvider<DriverNotifier, DriverState>(
  () {
    return DriverNotifier();
  },
);

// ============================================================================
// ADMIN FEATURE (Phase 8)
// ============================================================================

// Data Sources
final adminRemoteDataSourceProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AdminRemoteDataSourceImpl(client);
});

// Repositories
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final dataSource = ref.watch(adminRemoteDataSourceProvider);
  return AdminRepositoryImpl(dataSource);
});

// Use Cases
final getDashboardStatsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return GetDashboardStats(repository);
});

final getAllDriversUseCaseProvider = Provider((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return GetAllDrivers(repository);
});

final getActiveDriversUseCaseProvider = Provider((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return GetActiveDrivers(repository);
});

final updateDriverStatusUseCaseProvider = Provider((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return UpdateDriverStatus(repository);
});

final getAllOrdersUseCaseProvider = Provider((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return GetAllOrders(repository);
});

final getRecentOrdersUseCaseProvider = Provider((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return GetRecentOrders(repository);
});

// Presentation (Notifier)
final adminNotifierProvider = NotifierProvider<AdminNotifier, AdminState>(() {
  return AdminNotifier();
});

// ============================================================================
// MITRA FEATURE (PHASE 9)
// ============================================================================

// Data Sources
final mitraRemoteDataSourceProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return MitraRemoteDataSourceImpl(client);
});

// Repositories
final mitraRepositoryProvider = Provider<MitraRepository>((ref) {
  final dataSource = ref.watch(mitraRemoteDataSourceProvider);
  final client = ref.watch(supabaseClientProvider);
  return MitraRepositoryImpl(dataSource: dataSource, supabaseClient: client);
});

// Use Cases
final getOrderHistoryUseCaseProvider = Provider((ref) {
  final repository = ref.watch(mitraRepositoryProvider);
  return GetOrderHistory(repository);
});

final getActiveOrdersUseCaseProvider = Provider((ref) {
  final repository = ref.watch(mitraRepositoryProvider);
  return GetActiveOrders(repository);
});

final trackActiveOrderUseCaseProvider = Provider((ref) {
  final repository = ref.watch(mitraRepositoryProvider);
  return TrackActiveOrder(repository);
});

final getMitraDashboardStatsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(mitraRepositoryProvider);
  return GetMitraDashboardStats(repository);
});

// Presentation (Notifier)
final mitraNotifierProvider = NotifierProvider<MitraNotifier, MitraState>(() {
  return MitraNotifier();
});

// ============================================================================
//   CART FEATURE (PHASE 10)
// ============================================================================

// Data Sources
final cartLocalDataSourceProvider = Provider((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return CartLocalDataSourceImpl(sharedPreferences: sharedPreferences);
});

// Repositories
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final dataSource = ref.watch(cartLocalDataSourceProvider);
  return CartRepositoryImpl(localDataSource: dataSource);
});

// Use Cases
final getCartItemsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return GetCartItems(repository);
});

final addToCartUseCaseProvider = Provider((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return AddToCart(repository);
});

final removeFromCartUseCaseProvider = Provider((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return RemoveFromCart(repository);
});

final updateCartQuantityUseCaseProvider = Provider((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return UpdateCartQuantity(repository);
});

final clearCartUseCaseProvider = Provider((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return ClearCart(repository);
});

// Presentation (Notifier)
final cartNotifierProvider = NotifierProvider<CartNotifier, CartState>(() {
  return CartNotifier();
});

// ============================================================================
// PHASE 11+ FEATURES - TO BE IMPLEMENTED
// ============================================================================
// The following providers will be implemented in future phases

/*
  final client = ref.watch(supabaseClientProvider);
  return DriverRemoteDataSource(client: client);
});

// Repositories
final driverRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(driverRemoteDataSourceProvider);
  return DriverRepositoryImpl(remoteDataSource: dataSource);
});

// Use Cases
final getAssignedDeliveriesUseCaseProvider = Provider((ref) {
  final repository = ref.watch(driverRepositoryProvider);
  return GetAssignedDeliveries(repository);
});

final updateDeliveryStatusUseCaseProvider = Provider((ref) {
  final repository = ref.watch(driverRepositoryProvider);
  return UpdateDeliveryStatus(repository);
});

// ============================================================================
// ADMIN FEATURE
// ============================================================================

// Data Sources
final adminRemoteDataSourceProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AdminRemoteDataSource(client: client);
});

// Repositories
final adminRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(adminRemoteDataSourceProvider);
  return AdminRepositoryImpl(remoteDataSource: dataSource);
});

// Use Cases
final getDashboardStatsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return GetDashboardStats(repository);
});

// ============================================================================
// MITRA FEATURE
// ============================================================================

// Data Sources
final mitraRemoteDataSourceProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  // TODO: Implement DriverRemoteDataSourceImpl properly
  return DriverRemoteDataSource(client: client);
  // return DriverRemoteDataSourceImpl(client: client);
});

// Repositories
final mitraRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(mitraRemoteDataSourceProvider);
  return MitraRepositoryImpl(remoteDataSource: dataSource);
});

// Use Cases
final getOrderHistoryUseCaseProvider = Provider((ref) {
  final repository = ref.watch(mitraRepositoryProvider);
  return GetOrderHistory(repository);
});
*/

// ============================================================================
// NOTE: Uncomment the above providers when implementing Phase 5+ features
// ============================================================================
