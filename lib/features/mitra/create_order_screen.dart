import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/mitra_service.dart';
import '../../widgets/lottie_animations.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  List<Map<String, dynamic>> products = [];
  Map<String, dynamic>? selectedProduct;
  DateTime selectedDeliveryDate = DateTime.now().add(Duration(days: 3));
  bool isLoading = false;
  bool isSubmitting = false;
  String? error;
  Map<String, dynamic>? shippingInfo;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
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

  Future<void> _calculateShipping() async {
    if (selectedProduct == null ||
        _quantityController.text.isEmpty ||
        _addressController.text.isEmpty) {
      return;
    }

    try {
      final quantity = int.parse(_quantityController.text);
      final result = await MitraService.calculateShipping(
        destination: _addressController.text,
        quantity: quantity,
      );

      if (result['success']) {
        setState(() {
          shippingInfo = result['data'];
        });
      }
    } catch (e) {
      // Silently handle calculation errors
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate() || selectedProduct == null) {
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final result = await MitraService.createOrder(
        productId: selectedProduct!['id'],
        quantity: int.parse(_quantityController.text),
        deliveryAddress: _addressController.text,
        requestedDeliveryDate: selectedDeliveryDate,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (result['success']) {
        // Show success animation
        await LottieSuccessDialog.show(
          context,
          title: 'Pesanan Berhasil!',
          message: result['message'] ?? 'Pesanan Anda telah berhasil dibuat',
        );

        // Navigate back to dashboard
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Gagal membuat pesanan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Pesanan'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: isLoading
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
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
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
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Selection
                    Text(
                      'Pilih Produk',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: DropdownButtonFormField<Map<String, dynamic>>(
                        value: selectedProduct,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          border: InputBorder.none,
                          hintText: 'Pilih produk',
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Mohon pilih produk';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            selectedProduct = value;
                            shippingInfo = null; // Reset shipping calculation
                          });
                          _calculateShipping();
                        },
                        items: products.map((product) {
                          return DropdownMenuItem(
                            value: product,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  product['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                Text(
                                  'Rp ${product['price_per_kg']}/kg - Stok: ${product['stock']} kg',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Product Details (if selected)
                    if (selectedProduct != null) ...[
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedProduct!['name'],
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              selectedProduct!['description'],
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Harga: Rp ${selectedProduct!['price_per_kg']}/kg',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ),
                                Text(
                                  'Stok: ${selectedProduct!['stock']} kg',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 24.h),

                    // Quantity Input
                    Text(
                      'Jumlah (kg)',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Masukkan jumlah dalam kg',
                        suffixText: 'kg',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mohon masukkan jumlah';
                        }
                        final quantity = int.tryParse(value);
                        if (quantity == null || quantity <= 0) {
                          return 'Jumlah harus berupa angka positif';
                        }
                        if (selectedProduct != null &&
                            quantity > selectedProduct!['stock']) {
                          return 'Jumlah melebihi stok tersedia';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _calculateShipping();
                      },
                    ),

                    SizedBox(height: 24.h),

                    // Delivery Address
                    Text(
                      'Alamat Pengiriman',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Masukkan alamat lengkap pengiriman',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mohon masukkan alamat pengiriman';
                        }
                        if (value.length < 10) {
                          return 'Alamat terlalu pendek';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _calculateShipping();
                      },
                    ),

                    SizedBox(height: 24.h),

                    // Delivery Date
                    Text(
                      'Tanggal Pengiriman Diinginkan',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDeliveryDate,
                          firstDate: DateTime.now().add(Duration(days: 1)),
                          lastDate: DateTime.now().add(Duration(days: 30)),
                        );
                        if (date != null) {
                          setState(() {
                            selectedDeliveryDate = date;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${selectedDeliveryDate.day}/${selectedDeliveryDate.month}/${selectedDeliveryDate.year}',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ),
                            Icon(Icons.calendar_today, size: 20.sp),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Shipping Info
                    if (shippingInfo != null) ...[
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informasi Pengiriman',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Biaya Pengiriman:'),
                                Text(
                                  'Rp ${shippingInfo!['shipping_cost']}',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Estimasi Waktu:'),
                                Text(
                                  '${shippingInfo!['estimated_days']} hari',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            if (shippingInfo!['quantity_discount'] > 0)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Diskon Bulk:'),
                                  Text(
                                    '${shippingInfo!['quantity_discount'].toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green[600],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],

                    // Notes
                    Text(
                      'Catatan (Opsional)',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan catatan jika diperlukan',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Order Summary
                    if (selectedProduct != null &&
                        _quantityController.text.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ringkasan Pesanan',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            _buildSummaryRow(
                              'Produk:',
                              selectedProduct!['name'],
                            ),
                            if (int.tryParse(_quantityController.text) !=
                                null) ...[
                              _buildSummaryRow(
                                'Jumlah:',
                                '${_quantityController.text} kg',
                              ),
                              _buildSummaryRow(
                                'Harga per kg:',
                                'Rp ${selectedProduct!['price_per_kg']}',
                              ),
                              _buildSummaryRow(
                                'Total Harga:',
                                'Rp ${int.parse(_quantityController.text) * selectedProduct!['price_per_kg']}',
                                isTotal: true,
                              ),
                              if (shippingInfo != null)
                                _buildSummaryRow(
                                  'Biaya Kirim:',
                                  'Rp ${shippingInfo!['shipping_cost']}',
                                ),
                              if (shippingInfo != null) ...[
                                Divider(),
                                _buildSummaryRow(
                                  'TOTAL KESELURUHAN:',
                                  'Rp ${int.parse(_quantityController.text) * selectedProduct!['price_per_kg'] + shippingInfo!['shipping_cost']}',
                                  isGrandTotal: true,
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: 32.h),
                    ],

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : _submitOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: isSubmitting
                            ? SizedBox(
                                height: 20.h,
                                width: 20.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Buat Pesanan',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isGrandTotal = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isGrandTotal ? 16.sp : 14.sp,
              fontWeight: isTotal || isGrandTotal
                  ? FontWeight.w600
                  : FontWeight.normal,
              color: isGrandTotal ? Color(0xFF2E7D32) : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isGrandTotal ? 16.sp : 14.sp,
              fontWeight: isTotal || isGrandTotal
                  ? FontWeight.w600
                  : FontWeight.normal,
              color: isGrandTotal ? Color(0xFF2E7D32) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
