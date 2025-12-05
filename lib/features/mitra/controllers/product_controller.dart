import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/mitra_service.dart';

/// Product state
class ProductState {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> products;
  final Map<String, dynamic>? selectedProduct;

  const ProductState({
    this.isLoading = false,
    this.error,
    this.products = const [],
    this.selectedProduct,
  });

  ProductState copyWith({
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? products,
    Map<String, dynamic>? selectedProduct,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      products: products ?? this.products,
      selectedProduct: selectedProduct ?? this.selectedProduct,
    );
  }
}

/// Product controller for managing product operations
class ProductController extends Notifier<ProductState> {
  @override
  ProductState build() => const ProductState();

  /// Get all products
  Future<void> getProducts() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await MitraService.getProducts();

      if (result['success'] == true) {
        final products = (result['data'] as List).cast<Map<String, dynamic>>();
        state = state.copyWith(isLoading: false, products: products);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['error'] ?? 'Gagal memuat produk',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Terjadi kesalahan: $e');
    }
  }

  /// Search products
  List<Map<String, dynamic>> searchProducts(String query) {
    if (query.isEmpty) return state.products;

    return state.products.where((product) {
      final name = product['name']?.toString().toLowerCase() ?? '';
      final category = product['category']?.toString().toLowerCase() ?? '';
      final searchLower = query.toLowerCase();

      return name.contains(searchLower) || category.contains(searchLower);
    }).toList();
  }

  /// Filter products by category
  List<Map<String, dynamic>> filterByCategory(String category) {
    if (category.isEmpty || category == 'all') return state.products;

    return state.products.where((product) {
      final productCategory =
          product['category']?.toString().toLowerCase() ?? '';
      return productCategory == category.toLowerCase();
    }).toList();
  }

  /// Reset state
  void reset() {
    state = const ProductState();
  }
}

/// Product controller provider
final productControllerProvider =
    NotifierProvider<ProductController, ProductState>(() {
      return ProductController();
    });
