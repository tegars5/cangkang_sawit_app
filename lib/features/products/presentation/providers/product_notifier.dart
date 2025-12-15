import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_product_by_id.dart';
import '../../domain/usecases/search_products.dart';
import 'product_state.dart';

/// StateNotifier for managing product state
class ProductNotifier extends StateNotifier<ProductState> {
  final Ref ref;

  ProductNotifier(this.ref) : super(const ProductState.initial());

  /// Load all products
  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final getProducts = ref.read(getProductsUseCaseProvider);
    final result = await getProducts(NoParams());

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (products) {
        state = state.copyWith(
          products: products,
          isLoading: false,
          clearError: true,
        );
      },
    );
  }

  /// Load product by ID
  Future<void> loadProductById(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final getProductById = ref.read(getProductByIdUseCaseProvider);
    final result = await getProductById(GetProductByIdParams(id: id));

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (product) {
        state = state.copyWith(
          selectedProduct: product,
          isLoading: false,
          clearError: true,
        );
      },
    );
  }

  /// Search products by query
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      // If query is empty, load all products
      await loadProducts();
      return;
    }

    state = state.copyWith(
      isLoading: true,
      searchQuery: query,
      clearError: true,
    );

    final searchProducts = ref.read(searchProductsUseCaseProvider);
    final result = await searchProducts(SearchProductsParams(query: query));

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (products) {
        state = state.copyWith(
          products: products,
          isLoading: false,
          clearError: true,
        );
      },
    );
  }

  /// Clear selected product
  void clearSelectedProduct() {
    state = state.copyWith(clearSelectedProduct: true);
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clear search query and reload all products
  Future<void> clearSearch() async {
    state = state.copyWith(clearSearchQuery: true);
    await loadProducts();
  }

  /// Refresh products (pull to refresh)
  Future<void> refresh() async {
    await loadProducts();
  }
}

/// Provider for ProductNotifier
final productNotifierProvider =
    StateNotifierProvider<ProductNotifier, ProductState>((ref) {
      return ProductNotifier(ref);
    });
