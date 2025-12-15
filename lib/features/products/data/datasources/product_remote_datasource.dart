import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';

/// Remote data source for Product operations
class ProductRemoteDataSource {
  final SupabaseClient client;

  ProductRemoteDataSource({required this.client});

  /// Get all active products
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await client
          .from('products')
          .select('*')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Failed to get products: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get products: $e');
    }
  }

  /// Get product by ID
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await client
          .from('products')
          .select('*')
          .eq('id', id)
          .single();

      return ProductModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw NotFoundException('Product not found');
      }
      throw ServerException('Failed to get product: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get product: $e');
    }
  }

  /// Search products by name
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await client
          .from('products')
          .select('*')
          .eq('is_active', true)
          .ilike('name', '%$query%')
          .order('name');

      return (response as List)
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Failed to search products: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to search products: $e');
    }
  }

  /// Create new product (Admin only)
  Future<ProductModel> createProduct({
    required String name,
    String? description,
    required double pricePerTon,
    double? stockAvailable,
    double? minimumOrder,
    String? category,
    String? specifications,
  }) async {
    try {
      final response = await client
          .from('products')
          .insert({
            'name': name,
            'description': description,
            'price_per_ton': pricePerTon,
            'stock_available': stockAvailable ?? 0,
            'minimum_order': minimumOrder ?? 1,
            'category': category ?? 'Palm Shell',
            'specifications': specifications,
            'is_active': true,
          })
          .select()
          .single();

      return ProductModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to create product: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to create product: $e');
    }
  }

  /// Update product (Admin only)
  Future<ProductModel> updateProduct({
    required String id,
    String? name,
    String? description,
    double? pricePerTon,
    double? stockAvailable,
    double? minimumOrder,
    bool? isActive,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (pricePerTon != null) updates['price_per_ton'] = pricePerTon;
      if (stockAvailable != null) updates['stock_available'] = stockAvailable;
      if (minimumOrder != null) updates['minimum_order'] = minimumOrder;
      if (isActive != null) updates['is_active'] = isActive;

      final response = await client
          .from('products')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return ProductModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to update product: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to update product: $e');
    }
  }

  /// Delete product (soft delete - Admin only)
  Future<void> deleteProduct(String id) async {
    try {
      await client.from('products').update({'is_active': false}).eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to delete product: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to delete product: $e');
    }
  }
}
