import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../../../widgets/common/common_widgets.dart';
import '../../../shared/models/models.dart';
import '../providers/admin_providers.dart';

/// Admin Products Page - Full CRUD for Product Management
class AdminProductsPage extends ConsumerWidget {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Products',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement search
            },
            icon: Icon(Icons.search, color: Colors.white, size: 24.sp),
          ),
          IconButton(
            onPressed: () {
              // TODO: Implement filter
            },
            icon: Icon(Icons.filter_list, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.network(
                    'https://lottie.host/4c7b8c8e-8b4a-4b0f-9c5e-2d1f3e4a5b6c/7K8L9M0N1P.json',
                    width: 200.w,
                    height: 200.h,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.inventory_2_outlined,
                        size: 64.sp,
                        color: Colors.grey,
                      );
                    },
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No products found',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Tap + to add your first product',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(productListProvider.notifier).refresh();
            },
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(context, ref, product);
              },
            ),
          );
        },
        loading: () => Center(
          child: Lottie.network(
            'https://lottie.host/embed/a0c3c0d0-9b4a-4b0f-9c5e-2d1f3e4a5b6c/7K8L9M0N1P.json',
            width: 150.w,
            height: 150.h,
            errorBuilder: (context, error, stackTrace) {
              return const CircularProgressIndicator();
            },
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
              SizedBox(height: 16.h),
              Text(
                'Error loading products',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 8.h),
              Text(
                error.toString(),
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  ref.read(productListProvider.notifier).refresh();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "admin_products_fab",
        onPressed: () {
          _showProductDialog(context, ref);
        },
        backgroundColor: const Color(0xFF1B5E20),
        child: Icon(Icons.add, color: Colors.white, size: 24.sp),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        product.formattedPrice,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        _showProductDialog(context, ref, product: product);
                      },
                      icon: Icon(
                        Icons.edit_outlined,
                        color: const Color(0xFF3B82F6),
                        size: 20.sp,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _showDeleteConfirmation(context, ref, product);
                      },
                      icon: Icon(
                        Icons.delete_outline,
                        color: const Color(0xFFEF4444),
                        size: 20.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                _buildInfoChip(
                  Icons.inventory_outlined,
                  'Stock: ${product.formattedStock}',
                ),
                SizedBox(width: 8.w),
                _buildInfoChip(Icons.category_outlined, product.category),
              ],
            ),
            if (product.description != null &&
                product.description!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                product.description!,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (!product.isActive) ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'Inactive',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.red[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: Colors.grey[600]),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  void _showProductDialog(
    BuildContext context,
    WidgetRef ref, {
    Product? product,
  }) {
    final isEdit = product != null;
    final nameController = TextEditingController(text: product?.name ?? '');
    final descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    final priceController = TextEditingController(
      text: product?.pricePerTon.toString() ?? '',
    );
    final stockController = TextEditingController(
      text: product?.stockAvailable.toString() ?? '0',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Product' : 'Add Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price per Ton *',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock Available (Ton)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 1000',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text.trim());
              final stock = double.tryParse(stockController.text.trim());

              if (name.isEmpty || price == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all required fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                if (isEdit) {
                  await ref
                      .read(productListProvider.notifier)
                      .updateProduct(
                        productId: product.id,
                        name: name,
                        pricePerTon: price,
                        stockAvailable: stock,
                      );
                } else {
                  await ref
                      .read(productListProvider.notifier)
                      .createProduct(
                        name: name,
                        pricePerTon: price,
                        stockAvailable: stock,
                      );
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEdit
                            ? 'Product updated successfully'
                            : 'Product created successfully',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(isEdit ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(productListProvider.notifier)
                    .deleteProduct(product.id);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
