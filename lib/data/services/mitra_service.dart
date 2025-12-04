import '../../shared/repositories/order_repository.dart';
import '../../shared/repositories/product_repository.dart';

/// Service untuk Mitra Bisnis Dashboard
/// Berfungsi sebagai "Adapter" antara UI Lama dengan Repository Baru
class MitraService {
  /// Get products catalog untuk mitra
  static Future<Map<String, dynamic>> getProducts() async {
    try {
      final productRepository = ProductRepository();
      final products = await productRepository.getAllProducts();

      // Mapping model Product baru ke format JSON lama agar UI tidak error
      final productsJson = products.map((product) {
        return {
          'id': product.id,
          'name': product.name,
          'price': product.price,
          'price_per_ton': product.price,
          'unit': product.unit,
          'stock': product.stockAvailable,
          'stock_available': product.stockAvailable,
          'description': product.description ?? '',
          'is_active': product.isActive,
          'created_at': product.createdAt?.toIso8601String(),
          'updated_at': product.updatedAt?.toIso8601String(),
          'formatted_price': product.formattedPrice,
          'formatted_stock': product.formattedStock, // Tambahan helper
          'display_name': product.displayName,
          'has_stock': product.hasStock, // Tambahan helper
        };
      }).toList();

      return {'success': true, 'data': productsJson};
    } catch (e) {
      return {'success': false, 'error': 'Gagal memuat data produk: $e'};
    }
  }

  /// Create new order
  /// DEPRECATED: Fitur ini sekarang ditangani langsung oleh OrderRepository di CreateOrderScreen.
  /// Kita matikan fungsinya agar tidak ada penggunaan ganda yang membingungkan.
  static Future<Map<String, dynamic>> createOrder({
    required String productId,
    required double quantity,
    String? notes,
  }) async {
    return {
      'success': false,
      'error': 'Metode ini tidak lagi digunakan. Gunakan OrderRepository.',
    };
  }

  /// Get mitra's orders
  static Future<Map<String, dynamic>> getMyOrders() async {
    try {
      final orderRepository = OrderRepository();
      // Menggunakan fungsi baru dari repository
      final orders = await orderRepository.getMyOrders();

      final ordersJson = orders.map((order) {
        return {
          'id': order.id,
          'order_number': order.orderNumber,
          'customer_id': order.customerId,
          'status': order.status,
          'total_amount': order.totalAmount,
          'customer_notes': order.customerNotes,
          'created_at': order.createdAt.toIso8601String(),
          'updated_at': order.updatedAt?.toIso8601String(),
          'formatted_total_amount': order.formattedTotalAmount,

          // Field pelengkap untuk UI lama
          'customer_name': 'Saya',
          'can_be_confirmed': false,
          'can_be_shipped': false,
          'is_completed': order.status == 'completed',

          // Mapping Order Details
          'order_details': order.orderDetails?.map((detail) {
            return {
              'id': detail.id,
              'product_id': detail.productId,
              // PERBAIKAN UTAMA: Menggunakan requestedQuantity (bukan totalQuantity)
              'total_quantity': detail.requestedQuantity,
              'confirmed_quantity': detail.confirmedQuantity,
              'unit_price': detail.unitPrice,
              'subtotal': detail.subtotal,

              // Field turunan
              'product_name': 'Produk Sawit', // Placeholder
              'formatted_unit_price': 'Rp ${detail.unitPrice}',
              'formatted_subtotal': 'Rp ${detail.subtotal}',
            };
          }).toList(),
        };
      }).toList();

      return {'success': true, 'data': ordersJson};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get order tracking info (MOCK)
  /// Menyediakan data dummy agar halaman tracking lama tidak crash saat dibuka
  static Future<Map<String, dynamic>> trackOrder(String orderId) async {
    try {
      // Mock tracking data
      final tracking = {
        'order_id': orderId,
        'current_status': 'in_transit',
        'tracking_number': 'TRK-${DateTime.now().millisecondsSinceEpoch}',
        'estimated_delivery': DateTime.now()
            .add(const Duration(hours: 12))
            .toIso8601String(),
        'driver': {
          'name': 'Budi Santoso',
          'phone': '+62812-3456-7890',
          'vehicle': 'Truck B 1234 XY',
        },
        'location': {
          'lat': -6.2088,
          'lng': 106.8456,
          'address': 'Jl. Tol Jakarta-Cikampek KM 25',
          'updated_at': DateTime.now()
              .subtract(const Duration(minutes: 15))
              .toIso8601String(),
        },
        'timeline': [
          {
            'status': 'in_transit',
            'timestamp': DateTime.now().toIso8601String(),
            'description': 'Dalam perjalanan',
            'icon': 'local_shipping',
            'current': true,
          },
        ],
      };

      return {'success': true, 'data': tracking};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get mitra dashboard stats (MOCK)
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final stats = {
        'total_orders': 12,
        'pending_orders': 2,
        'active_orders': 1,
        'completed_orders': 9,
        'total_spent': 15000000,
        'this_month_orders': 4,
      };
      return {'success': true, 'data': stats};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Cancel order
  static Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      final orderRepository = OrderRepository();
      await orderRepository.cancelOrder(
        orderId,
        reason: 'Dibatalkan via Dashboard Mitra',
      );
      return {'success': true, 'message': 'Pesanan berhasil dibatalkan'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Calculate shipping cost (MOCK)
  static Future<Map<String, dynamic>> calculateShipping({
    required String destination,
    required int quantity,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'success': true,
        'data': {
          'shipping_cost': 500000,
          'estimated_days': 2,
          'base_rate': 50.0,
          'distance_factor': 1.0,
          'quantity_discount': 0,
        },
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
