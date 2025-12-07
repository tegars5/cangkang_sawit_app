import '../models/models.dart';
import '../../core/services/supabase_service.dart';

/// Repository untuk mengelola operasi Product
class ProductRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;

  /// Get semua produk yang aktif
  Future<List<Product>> getAllProducts() async {
    try {
      print('🔍 ProductRepository: Fetching products...');

      // Gunakan wildcard select untuk menghindari column mismatch
      final response = await _supabaseService.client
          .from('products')
          .select('*')
          .eq('is_active', true)
          .order('name');

      print(
        '📦 ProductRepository: Fetched ${(response as List).length} products',
      );

      // Parse dengan error handling per-item
      final List<Product> products = [];
      for (int i = 0; i < (response as List).length; i++) {
        try {
          final productData = response[i];
          final product = Product.fromJson(productData);
          products.add(product);
        } catch (e) {
          print('❌ Error parsing product at index $i: $e');
          print('   Raw data: ${response[i]}');
          // Skip product yang error
          continue;
        }
      }

      return products;
    } catch (e) {
      print('❌ ProductRepository.getAllProducts error: $e');
      throw Exception('Gagal mengambil data produk: $e');
    }
  }

  /// Get produk berdasarkan ID
  Future<Product?> getProductById(String productId) async {
    try {
      final response = await _supabaseService.client
          .from('products')
          .select('*')
          .eq('id', productId)
          .single();

      return Product.fromJson(response);
    } catch (e) {
      print('❌ ProductRepository.getProductById error: $e');
      throw Exception('Gagal mengambil produk: $e');
    }
  }

  /// Create produk baru (Admin only)
  /// Database columns: id, name, description, price_per_ton, stock_available, category, product_code, is_active, created_at
  Future<Product> createProduct({
    required String name,
    required double pricePerTon,
    double? stockAvailable,
  }) async {
    try {
      print('🔍 ProductRepository: Creating product "$name"...');

      final response = await _supabaseService.client
          .from('products')
          .insert({
            'name': name,
            'price_per_ton': pricePerTon,
            'stock_available': stockAvailable ?? 0,
            'category': 'Palm Shell',
            'is_active': true,
          })
          .select()
          .single();

      print('✅ ProductRepository: Product created successfully');
      return Product.fromJson(response);
    } catch (e) {
      print('❌ ProductRepository.createProduct error: $e');
      throw Exception('Gagal membuat produk: $e');
    }
  }

  /// Update produk (Admin only)
  Future<Product> updateProduct({
    required String productId,
    required String name,
    required double pricePerTon,
    double? stockAvailable,
    bool? isActive,
  }) async {
    try {
      print('🔍 ProductRepository: Updating product $productId...');

      final response = await _supabaseService.client
          .from('products')
          .update({
            'name': name,
            'price_per_ton': pricePerTon,
            if (stockAvailable != null) 'stock_available': stockAvailable,
            if (isActive != null) 'is_active': isActive,
          })
          .eq('id', productId)
          .select()
          .single();

      print('✅ ProductRepository: Product updated successfully');
      return Product.fromJson(response);
    } catch (e) {
      print('❌ ProductRepository.updateProduct error: $e');
      throw Exception('Gagal update produk: $e');
    }
  }

  /// Soft delete produk (Admin only)
  Future<void> deleteProduct(String productId) async {
    try {
      print('🔍 ProductRepository: Deleting product $productId...');

      await _supabaseService.client
          .from('products')
          .update({'is_active': false})
          .eq('id', productId);

      print('✅ ProductRepository: Product deleted successfully');
    } catch (e) {
      print('❌ ProductRepository.deleteProduct error: $e');
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
      print('❌ ProductRepository.searchProducts error: $e');
      throw Exception('Gagal search produk: $e');
    }
  }
}
