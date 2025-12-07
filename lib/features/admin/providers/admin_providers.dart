import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../shared/models/models.dart';
import '../../../shared/repositories/product_repository.dart';

/// Provider for current admin tab index
final adminTabIndexProvider = StateProvider<int>((ref) => 0);

/// Provider for product repository instance
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

/// Provider for fetching all products
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return await repo.getAllProducts();
});

/// Notifier for managing product list with CRUD operations
class ProductListNotifier extends Notifier<AsyncValue<List<Product>>> {
  @override
  AsyncValue<List<Product>> build() {
    loadProducts();
    return const AsyncValue.loading();
  }

  Future<void> loadProducts() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(productRepositoryProvider);
      final products = await repo.getAllProducts();
      state = AsyncValue.data(products);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await loadProducts();
  }

  Future<void> createProduct({
    required String name,
    required double pricePerTon,
    double? stockAvailable,
  }) async {
    try {
      final repo = ref.read(productRepositoryProvider);
      await repo.createProduct(
        name: name,
        pricePerTon: pricePerTon,
        stockAvailable: stockAvailable,
      );
      await loadProducts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct({
    required String productId,
    required String name,
    required double pricePerTon,
    double? stockAvailable,
    bool? isActive,
  }) async {
    try {
      final repo = ref.read(productRepositoryProvider);
      await repo.updateProduct(
        productId: productId,
        name: name,
        pricePerTon: pricePerTon,
        stockAvailable: stockAvailable,
        isActive: isActive,
      );
      await loadProducts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      final repo = ref.read(productRepositoryProvider);
      await repo.deleteProduct(productId);
      await loadProducts();
    } catch (e) {
      rethrow;
    }
  }
}

/// Provider for product list with CRUD operations
final productListProvider =
    NotifierProvider<ProductListNotifier, AsyncValue<List<Product>>>(() {
      return ProductListNotifier();
    });
