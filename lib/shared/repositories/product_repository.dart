import '../models/models.dart';
import '../../core/services/supabase_service.dart';

/// Repository untuk mengelola operasi Product
class ProductRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;

  /// Get semua produk yang aktif
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _supabaseService.client
          .from('products')
          .select()
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((product) => Product.fromJson(product))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data produk: $e');
    }
  }

  /// Get produk berdasarkan ID
  Future<Product?> getProductById(String productId) async {
    try {
      final response = await _supabaseService.client
          .from('products')
          .select()
          .eq('id', productId)
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil produk: $e');
    }
  }

  /// Create produk baru (Admin only)
  Future<Product> createProduct({
    required String name,
    required double price,
    required String unit,
  }) async {
    try {
      final response = await _supabaseService.client
          .from('products')
          .insert({'name': name, 'price': price, 'unit': unit})
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Gagal membuat produk: $e');
    }
  }

  /// Update produk (Admin only)
  Future<Product> updateProduct({
    required String productId,
    required String name,
    required double price,
    required String unit,
    bool? isActive,
  }) async {
    try {
      final response = await _supabaseService.client
          .from('products')
          .update({
            'name': name,
            'price': price,
            'unit': unit,
            if (isActive != null) 'is_active': isActive,
          })
          .eq('id', productId)
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Gagal update produk: $e');
    }
  }

  /// Soft delete produk (Admin only)
  Future<void> deleteProduct(String productId) async {
    try {
      await _supabaseService.client
          .from('products')
          .update({'is_active': false})
          .eq('id', productId);
    } catch (e) {
      throw Exception('Gagal hapus produk: $e');
    }
  }

  /// Search produk berdasarkan nama
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _supabaseService.client
          .from('products')
          .select()
          .eq('is_active', true)
          .ilike('name', '%$query%')
          .order('name');

      return (response as List)
          .map((product) => Product.fromJson(product))
          .toList();
    } catch (e) {
      throw Exception('Gagal search produk: $e');
    }
  }
}
