import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import screens
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/products/presentation/pages/product_catalog_screen.dart';
import '../../features/orders/presentation/pages/order_list_page.dart';
import '../../features/orders/presentation/pages/order_detail_page.dart';
import '../../features/orders/presentation/pages/create_order_page.dart';

/// App routes configuration using go_router
/// Includes authentication guards and role-based navigation
class AppRouter {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Mitra routes
  static const String mitraHome = '/mitra';
  static const String productCatalog = '/mitra/products';
  static const String mitraOrders = '/mitra/orders';
  static const String orderDetail = '/mitra/orders/:id';

  // Admin routes
  static const String adminHome = '/admin';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminProducts = '/admin/products';
  static const String adminOrders = '/admin/orders';

  // Driver routes
  static const String driverHome = '/driver';
  static const String driverDeliveries = '/driver/deliveries';
  static const String tracking = '/driver/tracking/:id';

  // Shared routes
  static const String profile = '/profile';
  static const String settings = '/settings';
}

/// Provider for GoRouter instance
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRouter.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      final isLoggedIn = session != null;

      final isAuthRoute =
          state.matchedLocation == AppRouter.login ||
          state.matchedLocation == AppRouter.register ||
          state.matchedLocation == AppRouter.forgotPassword;

      // If not logged in and trying to access protected route
      if (!isLoggedIn && !isAuthRoute) {
        return AppRouter.login;
      }

      // If logged in and trying to access auth routes
      if (isLoggedIn && isAuthRoute) {
        // Get user role and redirect to appropriate home
        try {
          final userId = session.user.id;
          final response = await supabase
              .from('profiles')
              .select('role_id')
              .eq('id', userId)
              .single();

          final roleId = response['role_id'] as int?;

          // Role-based redirect
          if (roleId == 1) {
            // Admin
            return AppRouter.adminDashboard;
          } else if (roleId == 2) {
            // Mitra Bisnis
            return AppRouter.productCatalog;
          } else if (roleId == 12) {
            // Driver/Logistik
            return AppRouter.driverDeliveries;
          }

          // Default to product catalog if role unknown
          return AppRouter.productCatalog;
        } catch (e) {
          // If error getting role, default to product catalog
          return AppRouter.productCatalog;
        }
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Splash/Loading route
      GoRoute(
        path: AppRouter.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth routes
      GoRoute(
        path: AppRouter.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRouter.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRouter.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Mitra routes
      GoRoute(
        path: AppRouter.mitraHome,
        redirect: (context, state) => AppRouter.productCatalog,
      ),
      GoRoute(
        path: AppRouter.productCatalog,
        builder: (context, state) => const ProductCatalogScreen(),
      ),
      GoRoute(
        path: AppRouter.mitraOrders,
        builder: (context, state) => const OrderListPage(),
      ),
      GoRoute(
        path: '/orders/create',
        builder: (context, state) => const CreateOrderPage(),
      ),
      GoRoute(
        path: '/orders/detail',
        builder: (context, state) {
          final orderId = state.uri.queryParameters['id'] ?? '';
          return OrderDetailPage(orderId: orderId);
        },
      ),
      GoRoute(
        path: AppRouter.orderDetail,
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderDetailPage(orderId: orderId);
        },
      ),

      // Admin routes
      GoRoute(
        path: AppRouter.adminHome,
        redirect: (context, state) => AppRouter.adminDashboard,
      ),
      GoRoute(
        path: AppRouter.adminDashboard,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Admin Dashboard - Coming Soon')),
        ),
      ),
      GoRoute(
        path: AppRouter.adminProducts,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Admin Products - Coming Soon')),
        ),
      ),
      GoRoute(
        path: AppRouter.adminOrders,
        builder: (context, state) => const OrderListPage(),
      ),

      // Driver routes
      GoRoute(
        path: AppRouter.driverHome,
        redirect: (context, state) => AppRouter.driverDeliveries,
      ),
      GoRoute(
        path: AppRouter.driverDeliveries,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Driver Deliveries - Coming Soon')),
        ),
      ),
      GoRoute(
        path: AppRouter.tracking,
        builder: (context, state) {
          final deliveryId = state.pathParameters['id']!;
          return Scaffold(
            body: Center(child: Text('Tracking: $deliveryId - Coming Soon')),
          );
        },
      ),

      // Shared routes
      GoRoute(
        path: AppRouter.profile,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Profile - Coming Soon'))),
      ),
      GoRoute(
        path: AppRouter.settings,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Settings - Coming Soon'))),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '404 - Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Route: ${state.matchedLocation}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRouter.login),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Temporary splash screen
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
