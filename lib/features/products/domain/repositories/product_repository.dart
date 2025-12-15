import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product.dart';

/// Repository interface for Product operations
abstract class ProductRepository {
  /// Get all active products
  Future<Either<Failure, List<Product>>> getProducts();

  /// Get product by ID
  Future<Either<Failure, Product>> getProductById(String id);

  /// Search products by name
  Future<Either<Failure, List<Product>>> searchProducts(String query);

  /// Create new product (Admin only)
  Future<Either<Failure, Product>> createProduct({
    required String name,
    String? description,
    required double pricePerTon,
    double? stockAvailable,
    double? minimumOrder,
    String? category,
    String? specifications,
  });

  /// Update product (Admin only)
  Future<Either<Failure, Product>> updateProduct({
    required String id,
    String? name,
    String? description,
    double? pricePerTon,
    double? stockAvailable,
    double? minimumOrder,
    bool? isActive,
  });

  /// Delete product (soft delete - Admin only)
  Future<Either<Failure, void>> deleteProduct(String id);
}
