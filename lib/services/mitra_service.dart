import '../shared/repositories/order_repository.dart';
import '../shared/repositories/product_repository.dart';

/// Service untuk Mitra Bisnis Dashboard
class MitraService {
  /// Get products catalog untuk mitra
  static Future<Map<String, dynamic>> getProducts() async {
    try {
      final productRepository = ProductRepository();
      final products = await productRepository.getAllProducts();

      final productsJson = products
          .map(
            (product) => {
              'id': product.id,
              'name': product.name,
              'price': product.price,
              'unit': product.unit,
              'is_active': product.isActive,
              'created_at': product.createdAt?.toIso8601String(),
              'updated_at': product.updatedAt?.toIso8601String(),
              'formatted_price': product.formattedPrice,
              'display_name': product.displayName,
            },
          )
          .toList();

      return {'success': true, 'data': productsJson};
    } catch (e) {
      return {'success': false, 'error': 'Gagal memuat data produk: $e'};
    }
  }

  /// Create new order
  static Future<Map<String, dynamic>> createOrder({
    required String productId,
    required double quantity,
    String? notes,
  }) async {
    try {
      final orderRepository = OrderRepository();
      final order = await orderRepository.createOrder(
        orderItems: [
          {'product_id': productId, 'quantity': quantity},
        ],
        catatan: notes,
      );

      return {
        'success': true,
        'data': {
          'id': order.id,
          'order_number': order.orderNumber,
          'customer_id': order.customerId,
          'status': order.status,
          'total_amount': order.totalAmount,
          'customer_notes': order.customerNotes,
          'created_at': order.createdAt.toIso8601String(),
          'updated_at': order.updatedAt?.toIso8601String(),
        },
        'message': 'Pesanan berhasil dibuat dengan nomor: ${order.orderNumber}',
      };
    } catch (e) {
      return {'success': false, 'error': 'Gagal membuat pesanan: $e'};
    }
  }

  /// Get mitra's orders
  static Future<Map<String, dynamic>> getMyOrders() async {
    try {
      final orderRepository = OrderRepository();
      final orders = await orderRepository.getOrdersByCurrentUser();

      final ordersJson = orders
          .map(
            (order) => {
              'id': order.id,
              'order_number': order.orderNumber,
              'customer_id': order.customerId,
              'status': order.status,
              'total_amount': order.totalAmount,
              'customer_notes': order.customerNotes,
              'created_at': order.createdAt.toIso8601String(),
              'updated_at': order.updatedAt?.toIso8601String(),
              'formatted_total_amount': order.formattedTotalAmount,
              'customer_name': order.customerName,
              'can_be_confirmed': order.canBeConfirmed,
              'can_be_shipped': order.canBeShipped,
              'is_completed': order.isCompleted,
              'order_details': order.orderDetails
                  ?.map(
                    (detail) => {
                      'id': detail.id,
                      'product_id': detail.productId,
                      'total_quantity': detail.totalQuantity,
                      'confirmed_quantity': detail.confirmedQuantity,
                      'unit_price': detail.unitPrice,
                      'subtotal': detail.subtotal,
                      'product_name': detail.productName,
                      'product_unit': detail.productUnit,
                      'formatted_unit_price': detail.formattedUnitPrice,
                      'formatted_subtotal': detail.formattedSubtotal,
                      'is_partially_accepted': detail.isPartiallyAccepted,
                      'quantity_difference': detail.quantityDifference,
                    },
                  )
                  .toList(),
            },
          )
          .toList();

      return {'success': true, 'data': ordersJson};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get order tracking info
  static Future<Map<String, dynamic>> trackOrder(String orderId) async {
    try {
      // Mock tracking data
      final tracking = {
        'order_id': orderId,
        'current_status': 'in_transit',
        'tracking_number': 'TRK-20241028-001',
        'estimated_delivery': DateTime.now()
            .add(Duration(hours: 12))
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
              .subtract(Duration(minutes: 15))
              .toIso8601String(),
        },
        'timeline': [
          {
            'status': 'order_placed',
            'timestamp': DateTime.now()
                .subtract(Duration(hours: 8))
                .toIso8601String(),
            'description': 'Pesanan berhasil dibuat',
            'icon': 'shopping_cart',
          },
          {
            'status': 'confirmed',
            'timestamp': DateTime.now()
                .subtract(Duration(hours: 7))
                .toIso8601String(),
            'description': 'Pesanan dikonfirmasi admin',
            'icon': 'check_circle',
          },
          {
            'status': 'prepared',
            'timestamp': DateTime.now()
                .subtract(Duration(hours: 4))
                .toIso8601String(),
            'description': 'Barang sedang disiapkan',
            'icon': 'inventory_2',
          },
          {
            'status': 'picked_up',
            'timestamp': DateTime.now()
                .subtract(Duration(hours: 2))
                .toIso8601String(),
            'description': 'Barang diambil driver',
            'icon': 'local_shipping',
          },
          {
            'status': 'in_transit',
            'timestamp': DateTime.now()
                .subtract(Duration(hours: 1))
                .toIso8601String(),
            'description': 'Dalam perjalanan ke alamat tujuan',
            'icon': 'directions_car',
            'current': true,
          },
        ],
      };

      return {'success': true, 'data': tracking};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get mitra dashboard stats
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final stats = {
        'total_orders': 15,
        'pending_orders': 3,
        'active_orders': 5,
        'completed_orders': 7,
        'total_spent': 12500000,
        'this_month_orders': 8,
        'avg_delivery_time': 2.5, // days
      };

      return {'success': true, 'data': stats};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Cancel order (only if status is pending)
  static Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      // Simulate API call delay
      await Future.delayed(Duration(milliseconds: 500));

      return {
        'success': true,
        'message': 'Pesanan $orderId berhasil dibatalkan',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Calculate shipping cost (mock implementation)
  static Future<Map<String, dynamic>> calculateShipping({
    required String destination,
    required int quantity,
  }) async {
    try {
      // Mock shipping calculation
      await Future.delayed(Duration(milliseconds: 300));

      // Base rate per kg
      double baseRate = 50.0;

      // Distance factor (mock based on city names)
      double distanceFactor = 1.0;
      if (destination.toLowerCase().contains('surabaya')) {
        distanceFactor = 1.5;
      } else if (destination.toLowerCase().contains('medan')) {
        distanceFactor = 2.0;
      } else if (destination.toLowerCase().contains('makassar')) {
        distanceFactor = 2.5;
      }

      // Quantity discount
      double quantityFactor = 1.0;
      if (quantity >= 1000) {
        quantityFactor = 0.8; // 20% discount for bulk orders
      } else if (quantity >= 500) {
        quantityFactor = 0.9; // 10% discount
      }

      double shippingCost =
          baseRate * quantity * distanceFactor * quantityFactor;
      int estimatedDays = (1 + (distanceFactor - 1) * 2).round();

      return {
        'success': true,
        'data': {
          'shipping_cost': shippingCost.round(),
          'estimated_days': estimatedDays,
          'base_rate': baseRate,
          'distance_factor': distanceFactor,
          'quantity_discount': (1 - quantityFactor) * 100, // percentage
        },
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
