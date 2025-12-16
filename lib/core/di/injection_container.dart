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

// TODO: Add imports for other features as they are implemented
// import '../features/tracking/...';
// import '../features/shipments/...';
// import '../features/driver/...';
// import '../features/admin/...';
// import '../features/mitra/...';

// ============================================================================
// CORE SERVICES
// ============================================================================

/// Provider for Supabase client
/// This is the single source of truth for Supabase access
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
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

// ============================================================================
// TRACKING FEATURE
// ============================================================================

// Data Sources
final trackingRemoteDataSourceProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return TrackingRemoteDataSource(client: client);
});

// Repositories
final trackingRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(trackingRemoteDataSourceProvider);
  return TrackingRepositoryImpl(remoteDataSource: dataSource);
});

// Use Cases
final subscribeDriverLocationUseCaseProvider = Provider((ref) {
  final repository = ref.watch(trackingRepositoryProvider);
  return SubscribeDriverLocation(repository);
});

final updateDriverLocationUseCaseProvider = Provider((ref) {
  final repository = ref.watch(trackingRepositoryProvider);
  return UpdateDriverLocation(repository);
});

// ============================================================================
// SHIPMENTS FEATURE
// ============================================================================

// Data Sources
final shipmentRemoteDataSourceProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ShipmentRemoteDataSource(client: client);
});

// Repositories
final shipmentRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(shipmentRemoteDataSourceProvider);
  return ShipmentRepositoryImpl(remoteDataSource: dataSource);
});

// Use Cases
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

// ============================================================================
// DRIVER FEATURE
// ============================================================================

// Data Sources
final driverRemoteDataSourceProvider = Provider((ref) {
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
  return MitraRemoteDataSource(client: client);
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

// ============================================================================
// NOTE: Import statements need to be added at the top of this file
// once the actual classes are created. This file serves as a template
// for the dependency injection structure.
// ============================================================================
