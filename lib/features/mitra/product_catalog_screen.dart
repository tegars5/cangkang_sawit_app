import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/mitra_service.dart';
import 'create_order_screen.dart';

class ProductCatalogScreen extends ConsumerStatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  ConsumerState<ProductCatalogScreen> createState() =>
      _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends ConsumerState<ProductCatalogScreen> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await MitraService.getProducts();
      if (result['success']) {
        setState(() {
          products = List<Map<String, dynamic>>.from(result['data']);
          isLoading = false;
        });
      } else {
        setState(() {
          error = result['error'] ?? 'Gagal memuat produk';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Produk'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
            : error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.sp,
                      color: Colors.red[300],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Gagal memuat produk',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      error!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: _loadProducts,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
            : products.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.eco_outlined,
                      size: 64.sp,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Belum ada produk',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Produk akan segera tersedia',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  // Header info
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
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
                  ),

                  SizedBox(height: 24.h),

                  // Products grid
                  ...products
                      .map((product) => _buildProductCard(product))
                      .toList(),
                ],
              ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final specifications = product['specifications'] as Map<String, dynamic>;

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image and basic info
          Container(
            height: 120.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Product icon/image placeholder
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.eco, size: 48.sp, color: Colors.white),
                      SizedBox(height: 8.h),
                      Text(
                        product['name'],
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
                // Stock indicator
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: product['stock'] > 1000
                          ? Colors.green
                          : product['stock'] > 100
                          ? Colors.orange
                          : Colors.red,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${product['stock']} kg',
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

          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  product['description'],
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),

                SizedBox(height: 16.h),

                // Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Harga per kg:',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Rp ${product['price_per_kg']}',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Specifications
                Text(
                  'Spesifikasi Produk:',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      _buildSpecRow(
                        'Kadar Air:',
                        specifications['moisture_content'],
                      ),
                      _buildSpecRow(
                        'Nilai Kalor:',
                        specifications['calorific_value'],
                      ),
                      _buildSpecRow(
                        'Kadar Abu:',
                        specifications['ash_content'],
                      ),
                      _buildSpecRow('Ukuran:', specifications['size']),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Stock info
                Row(
                  children: [
                    Icon(
                      product['stock'] > 1000
                          ? Icons.check_circle
                          : product['stock'] > 100
                          ? Icons.warning
                          : Icons.error,
                      size: 16.sp,
                      color: product['stock'] > 1000
                          ? Colors.green
                          : product['stock'] > 100
                          ? Colors.orange
                          : Colors.red,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        product['stock'] > 1000
                            ? 'Stok melimpah (${product['stock']} kg)'
                            : product['stock'] > 100
                            ? 'Stok terbatas (${product['stock']} kg)'
                            : 'Stok hampir habis (${product['stock']} kg)',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: product['stock'] > 1000
                              ? Colors.green[700]
                              : product['stock'] > 100
                              ? Colors.orange[700]
                              : Colors.red[700],
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
                        onPressed: () {
                          _showProductDetails(product);
                        },
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
                        onPressed: product['stock'] > 0
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

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showProductDetails(Map<String, dynamic> product) {
    final specifications = product['specifications'] as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.eco, color: const Color(0xFF2E7D32), size: 24.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      product['name'],
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, size: 20.sp),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Description
              Text(
                'Deskripsi Produk:',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              Text(
                product['description'],
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),

              SizedBox(height: 16.h),

              // Price and stock
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Harga per kg:',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Rp ${product['price_per_kg']}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Stok tersedia:',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${product['stock']} kg',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Detailed specifications
              Text(
                'Spesifikasi Teknis:',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      'Kadar Air (Moisture Content):',
                      specifications['moisture_content'],
                    ),
                    _buildDetailRow(
                      'Nilai Kalor (Calorific Value):',
                      specifications['calorific_value'],
                    ),
                    _buildDetailRow(
                      'Kadar Abu (Ash Content):',
                      specifications['ash_content'],
                    ),
                    _buildDetailRow(
                      'Ukuran Partikel (Size):',
                      specifications['size'],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: product['stock'] > 0
                      ? () {
                          Navigator.of(context).pop();
                          _orderProduct(product);
                        }
                      : null,
                  icon: Icon(Icons.add_shopping_cart, size: 16.sp),
                  label: Text(
                    product['stock'] > 0 ? 'Pesan Produk Ini' : 'Stok Habis',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _orderProduct(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateOrderScreen()),
    );
  }
}
