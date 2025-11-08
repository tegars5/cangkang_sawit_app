import 'package:supabase_flutter/supabase_flutter.dart';

/// Service untuk Admin Dashboard dengan real-time data dari Supabase
class AdminDashboardService {
  static final _supabase = Supabase.instance.client;

  /// Get dashboard statistics
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Get total orders (mock data untuk sekarang)
      int totalOrders = 25;
      int pendingOrders = 8;
      int processingOrders = 12;
      int completedOrders = 5;

      // Get total products (mock data)
      int totalProducts = 3;

      // Get total users (mock data)
      int totalUsers = 15;
      int totalMitra = 8;
      int totalDrivers = 4;

      return {
        'success': true,
        'data': {
          'totalOrders': totalOrders,
          'pendingOrders': pendingOrders,
          'processingOrders': processingOrders,
          'completedOrders': completedOrders,
          'totalProducts': totalProducts,
          'totalUsers': totalUsers,
          'totalMitra': totalMitra,
          'totalDrivers': totalDrivers,
        },
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get recent orders with details (mock data)
  static Future<Map<String, dynamic>> getRecentOrders({int limit = 10}) async {
    try {
      // Mock data untuk recent orders
      final orders = [
        {
          'id': 'ORD-001',
          'quantity': 500,
          'total_price': 750000,
          'status': 'pending',
          'created_at': DateTime.now()
              .subtract(Duration(hours: 2))
              .toIso8601String(),
          'products': {'name': 'Cangkang Sawit Premium', 'price_per_kg': 1500},
          'profiles': {
            'full_name': 'PT. Mitra Sejahtera',
            'roles': {'name': 'mitra bisnis'},
          },
        },
        {
          'id': 'ORD-002',
          'quantity': 1000,
          'total_price': 1400000,
          'status': 'processing',
          'created_at': DateTime.now()
              .subtract(Duration(hours: 5))
              .toIso8601String(),
          'products': {'name': 'Cangkang Sawit Standard', 'price_per_kg': 1400},
          'profiles': {
            'full_name': 'CV. Berkah Jaya',
            'roles': {'name': 'mitra bisnis'},
          },
        },
        {
          'id': 'ORD-003',
          'quantity': 750,
          'total_price': 1050000,
          'status': 'completed',
          'created_at': DateTime.now()
              .subtract(Duration(days: 1))
              .toIso8601String(),
          'products': {'name': 'Cangkang Sawit Premium', 'price_per_kg': 1400},
          'profiles': {
            'full_name': 'PT. Sumber Rezeki',
            'roles': {'name': 'mitra bisnis'},
          },
        },
      ];

      return {'success': true, 'data': orders.take(limit).toList()};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get all users with roles (mock data)
  static Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final users = [
        {
          'id': 'user-1',
          'full_name': 'Administrator System',
          'email': 'admin@fujiyama.com',
          'created_at': DateTime.now()
              .subtract(Duration(days: 30))
              .toIso8601String(),
          'roles': {'name': 'admin'},
        },
        {
          'id': 'user-2',
          'full_name': 'PT. Mitra Sejahtera',
          'email': 'mitra1@example.com',
          'created_at': DateTime.now()
              .subtract(Duration(days: 15))
              .toIso8601String(),
          'roles': {'name': 'mitra bisnis'},
        },
        {
          'id': 'user-3',
          'full_name': 'Driver Jakarta',
          'email': 'driver1@example.com',
          'created_at': DateTime.now()
              .subtract(Duration(days: 10))
              .toIso8601String(),
          'roles': {'name': 'logistik'},
        },
      ];

      return {'success': true, 'data': users};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Update order status (mock implementation)
  static Future<Map<String, dynamic>> updateOrderStatus(
    String orderId,
    String newStatus,
  ) async {
    try {
      // Simulate API call delay
      await Future.delayed(Duration(milliseconds: 500));

      return {
        'success': true,
        'message': 'Status pesanan $orderId berhasil diupdate ke $newStatus',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get products with stock info (mock data)
  static Future<Map<String, dynamic>> getProducts() async {
    try {
      final products = [
        {
          'id': 'prod-1',
          'name': 'Cangkang Sawit Premium',
          'description': 'Cangkang sawit kualitas premium untuk biomass energy',
          'price_per_kg': 1500,
          'stock': 5000,
          'created_at': DateTime.now()
              .subtract(Duration(days: 60))
              .toIso8601String(),
        },
        {
          'id': 'prod-2',
          'name': 'Cangkang Sawit Standard',
          'description': 'Cangkang sawit kualitas standard untuk industri',
          'price_per_kg': 1400,
          'stock': 8000,
          'created_at': DateTime.now()
              .subtract(Duration(days: 45))
              .toIso8601String(),
        },
        {
          'id': 'prod-3',
          'name': 'Cangkang Sawit Ekonomis',
          'description': 'Cangkang sawit grade ekonomis untuk bahan bakar',
          'price_per_kg': 1200,
          'stock': 12000,
          'created_at': DateTime.now()
              .subtract(Duration(days: 30))
              .toIso8601String(),
        },
      ];

      return {'success': true, 'data': products};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Add new product (mock implementation)
  static Future<Map<String, dynamic>> addProduct({
    required String name,
    required String description,
    required double pricePerKg,
    required int stock,
  }) async {
    try {
      // Simulate API call delay
      await Future.delayed(Duration(milliseconds: 800));

      return {
        'success': true,
        'message': 'Produk "$name" berhasil ditambahkan',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Update product (mock implementation)
  static Future<Map<String, dynamic>> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double pricePerKg,
    required int stock,
  }) async {
    try {
      // Simulate API call delay
      await Future.delayed(Duration(milliseconds: 600));

      return {'success': true, 'message': 'Produk berhasil diupdate'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Delete product (mock implementation)
  static Future<Map<String, dynamic>> deleteProduct(String productId) async {
    try {
      // Simulate API call delay
      await Future.delayed(Duration(milliseconds: 400));

      return {'success': true, 'message': 'Produk berhasil dihapus'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get delivery assignments (mock data)
  static Future<Map<String, dynamic>> getDeliveries() async {
    try {
      final deliveries = [
        {
          'id': 'del-1',
          'status': 'assigned',
          'pickup_date': DateTime.now()
              .add(Duration(days: 1))
              .toIso8601String(),
          'delivery_date': DateTime.now()
              .add(Duration(days: 2))
              .toIso8601String(),
          'orders': {
            'id': 'ORD-001',
            'quantity': 500,
            'total_price': 750000,
            'products': {'name': 'Cangkang Sawit Premium'},
          },
          'profiles': {'full_name': 'Driver Jakarta'},
        },
        {
          'id': 'del-2',
          'status': 'in_transit',
          'pickup_date': DateTime.now()
              .subtract(Duration(hours: 3))
              .toIso8601String(),
          'delivery_date': DateTime.now()
              .add(Duration(hours: 8))
              .toIso8601String(),
          'orders': {
            'id': 'ORD-002',
            'quantity': 1000,
            'total_price': 1400000,
            'products': {'name': 'Cangkang Sawit Standard'},
          },
          'profiles': {'full_name': 'Driver Surabaya'},
        },
      ];

      return {'success': true, 'data': deliveries};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Real-time subscription untuk dashboard stats (mock)
  static Stream<Map<String, dynamic>> subscribeToStats() {
    return Stream.periodic(const Duration(seconds: 30), (count) async {
      return await getDashboardStats();
    }).asyncMap((futureStats) => futureStats);
  }

  /// Get real orders dari Supabase (actual implementation)
  static Future<Map<String, dynamic>> getRealOrders() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*')
          .order('created_at', ascending: false)
          .limit(20);

      return {'success': true, 'data': response};
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Menggunakan mock data karena tabel orders belum ada',
      };
    }
  }

  /// Get real users dari Supabase (actual implementation)
  static Future<Map<String, dynamic>> getRealUsers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('*, roles(*)')
          .order('created_at', ascending: false);

      return {'success': true, 'data': response};
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error mengambil data users dari database',
      };
    }
  }
}
