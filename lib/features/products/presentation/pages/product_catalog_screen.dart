import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/product_notifier.dart';
import '../../domain/entities/product.dart';
import '../../../../core/utils/number_formatter.dart';

/// Product Catalog Screen using Clean Architecture
class ProductCatalogScreen extends ConsumerStatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  ConsumerState<ProductCatalogScreen> createState() =>
      _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends ConsumerState<ProductCatalogScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load products on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productNotifierProvider.notifier).loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Produk'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: productState.searchQuery != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(productNotifierProvider.notifier)
                              .clearSearch();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (query) {
                if (query.length >= 2) {
                  ref
                      .read(productNotifierProvider.notifier)
                      .searchProducts(query);
                } else if (query.isEmpty) {
                  ref.read(productNotifierProvider.notifier).clearSearch();
                }
              },
            ),
          ),

          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(productNotifierProvider.notifier).refresh(),
              child: _buildContent(productState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ProductState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: Colors.red[300]),
            SizedBox(height: 16.h),
            Text(
              'Gagal memuat produk',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Text(
              state.errorMessage!,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () =>
                  ref.read(productNotifierProvider.notifier).loadProducts(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (state.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco_outlined, size: 64.sp, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              state.searchQuery != null
                  ? 'Produk tidak ditemukan'
                  : 'Belum ada produk',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              state.searchQuery != null
                  ? 'Coba kata kunci lain'
                  : 'Produk akan segera tersedia',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: state.products.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHeader();
        }
        return _buildProductCard(state.products[index - 1]);
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.eco, color: Colors.white, size: 32.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produk Cangkang Sawit',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Kualitas terjamin untuk kebutuhan biomass energy',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product header
          Container(
            height: 120.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.eco, size: 48.sp, color: Colors.white),
                      SizedBox(height: 8.h),
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                // Stock badge
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: product.stockAvailable > 100
                          ? Colors.green
                          : product.stockAvailable > 10
                          ? Colors.amber
                          : Colors.red,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${product.stockAvailable.toStringAsFixed(1)} ${product.unit}',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Product details
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                if (product.description != null) ...[
                  Text(
                    product.description!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 16.h),
                ],

                // Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Harga per ${product.unit}:',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      NumberFormatter.formatCurrency(product.pricePerTon),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Stock status
                Row(
                  children: [
                    Icon(
                      product.stockAvailable > 100
                          ? Icons.check_circle
                          : product.stockAvailable > 10
                          ? Icons.warning
                          : Icons.error,
                      size: 16.sp,
                      color: product.stockAvailable > 100
                          ? Colors.green
                          : product.stockAvailable > 10
                          ? Colors.orange
                          : Colors.red,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        product.stockAvailable > 100
                            ? 'Stok melimpah'
                            : product.stockAvailable > 10
                            ? 'Stok terbatas'
                            : 'Stok hampir habis',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: product.stockAvailable > 100
                              ? Colors.green[600]
                              : product.stockAvailable > 10
                              ? Colors.amber[600]
                              : Colors.red[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showProductDetails(product),
                        icon: Icon(Icons.info_outline, size: 16.sp),
                        label: Text(
                          'Detail',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[400]!),
                          foregroundColor: Colors.grey[700],
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: product.hasStock
                            ? () => _orderProduct(product)
                            : null,
                        icon: Icon(Icons.add_shopping_cart, size: 16.sp),
                        label: Text(
                          'Pesan Sekarang',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProductDetails(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.eco, color: const Color(0xFF2E7D32)),
            SizedBox(width: 8.w),
            Expanded(child: Text(product.name)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (product.description != null) ...[
                Text(
                  'Deskripsi:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),
                Text(product.description!),
                SizedBox(height: 16.h),
              ],
              Text(
                'Harga: ${NumberFormatter.formatCurrency(product.pricePerTon)}/${product.unit}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              SizedBox(height: 8.h),
              Text('Stok: ${product.stockAvailable} ${product.unit}'),
              SizedBox(height: 8.h),
              Text('Minimum order: ${product.minimumOrder} ${product.unit}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          if (product.hasStock)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _orderProduct(product);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
              ),
              child: const Text('Pesan'),
            ),
        ],
      ),
    );
  }

  void _orderProduct(Product product) {
    // TODO: Navigate to create order screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Fitur pemesanan untuk ${product.name} akan segera hadir',
        ),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }
}
