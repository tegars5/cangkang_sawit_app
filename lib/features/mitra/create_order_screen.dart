import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../shared/models/models.dart';
import '../../shared/repositories/order_repository.dart';
import '../../shared/repositories/product_repository.dart';
import '../../shared/repositories/user_repository.dart';
import '../../core/services/supabase_service.dart';

import '../cart/providers/cart_provider.dart';
import 'order_history_screen.dart';

// CartItem sekarang menggunakan model terpisah di ../cart/models/cart_item.dart

class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  // Safety casting helper methods
  static double _safeDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  // Repositories
  final _productRepository = ProductRepository();
  final _orderRepository = OrderRepository();
  final _userRepository = UserRepository();
  final _supabaseService = SupabaseService.instance;

  // Controllers
  final _quantityController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  // State Data
  List<Product> _availableProducts = [];
  Product? _selectedProduct;
  DateTime _selectedDeliveryDate = DateTime.now().add(const Duration(days: 3));
  bool _isLoadingAddress = false;

  // UI State
  bool _isLoadingProducts = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _loadUserProfile();
  }

  /// Load user profile and auto-fill address
  Future<void> _loadUserProfile() async {
    try {
      final currentUser = _supabaseService.currentUser;
      if (currentUser == null) return;

      final profile = await _userRepository.getUserProfile(currentUser.id);
      if (profile != null && mounted) {
        // Auto-fill address from profile if available
        if (profile.address != null && profile.address!.isNotEmpty) {
          setState(() {
            _addressController.text = profile.address!;
          });
        }
        // Note: Location coordinates are saved in profile but not used in this screen
      }
    } catch (e) {
      // Silent fail - tidak critical
      debugPrint('Failed to load user profile: $e');
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // --- LOGIC 1: Ambil Data Produk ---
  Future<void> _fetchProducts() async {
    try {
      final products = await _productRepository.getAllProducts();
      if (mounted) {
        setState(() {
          _availableProducts = products;
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat produk: $e';
          _isLoadingProducts = false;
        });
      }
    }
  }

  // --- LOGIC 2: Manajemen Keranjang (Cart) ---
  void _addToCart() {
    if (_selectedProduct == null || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk dan isi jumlah dulu ya')),
      );
      return;
    }

    // Safe parsing dengan fallback ke 0.0
    final quantity = _safeDouble(_quantityController.text);
    if (quantity <= 0.0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Jumlah harus angka > 0')));
      return;
    }

    // Cek apakah produk sudah ada di keranjang
    final cartItems = ref.read(cartProvider);
    final existingIndex = cartItems.indexWhere(
      (item) => item.product.id == _selectedProduct!.id,
    );

    if (existingIndex >= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Produk ini sudah ada di keranjang. Hapus dulu jika ingin ubah.',
          ),
        ),
      );
      return;
    }

    // Masukkan ke keranjang
    // Tambahkan ke cart provider
    ref
        .read(cartProvider.notifier)
        .addItem(product: _selectedProduct!, quantity: quantity);

    setState(() {
      // Reset input form setelah tambah
      _selectedProduct = null;
      _quantityController.clear();
    });

    // Tutup keyboard
    FocusScope.of(context).unfocus();
  }

  void _removeFromCart(String itemId) {
    ref.read(cartProvider.notifier).removeItem(itemId);
  }

  // Total methods sekarang menggunakan cart provider
  // Tidak perlu getter karena bisa langsung dari provider

  // --- LOGIC 3: Kirim Pesanan ke Database ---
  Future<void> _submitOrder() async {
    final cartItems = ref.read(cartProvider);
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keranjang masih kosong! Tambah produk dulu.'),
        ),
      );
      return;
    }

    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat pengiriman wajib diisi')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final currentUser = _supabaseService.currentUser;
      if (currentUser == null) {
        throw Exception('Sesi habis, silakan login ulang');
      }

      // 1. Generate Nomor Order Unik
      final orderNumber = _orderRepository.generateOrderNumber();

      // 2. Siapkan Object Order Utama dengan safety casting
      final newOrder = Order(
        id: '', // Auto-generated di DB
        orderNumber: orderNumber,
        customerId: currentUser.id,
        orderDate: DateTime.now(),
        status: 'pending',
        totalQuantity: ref.read(cartProvider.notifier).totalQuantity,
        confirmedQuantity: 0.0,
        totalAmount: ref.read(cartProvider.notifier).totalAmount,
        deliveryAddress: _addressController.text,
        deliveryDate: _selectedDeliveryDate,
        customerNotes: _notesController.text,
        // Field wajib lain (kasih nilai default/kosong)
        confirmedAt: null,
        completedAt: null,
        createdAt: DateTime.now(),
        pickupAddress: '',
        pickupDate: null,
        adminNotes: '',
        notes: '',
      );

      // 3. Siapkan List Detail Item
      // Kita convert CartItem jadi OrderDetail (model DB)
      final List<OrderDetail> orderDetails = cartItems.map((cartItem) {
        return OrderDetail(
          id: const Uuid().v4(), // ID sementara
          orderId: '', // Nanti diisi otomatis oleh repository
          productId: cartItem.product.id,
          requestedQuantity: _safeDouble(cartItem.quantity),
          confirmedQuantity: 0.0,
          unitPrice: _safeDouble(cartItem.product.pricePerTon),
          subtotal: _safeDouble(cartItem.subtotal),
          // Field lain
          notes: '',
          createdAt: DateTime.now(),
        );
      }).toList();

      // 4. Panggil Repository (Transaksi Database)
      // UPDATED: Use createOrderWithShipment to auto-create shipment
      final result = await _orderRepository.createOrderWithShipment(
        order: newOrder,
        items: orderDetails,
      );

      final orderId = result['orderId']!;
      final shipmentId = result['shipmentId']!;

      // 5. Clear cart after successful order
      ref.read(cartProvider.notifier).clearCart();

      setState(() {
        _isSubmitting = false;
      });

      // 6. Show success message
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Pesanan berhasil dibuat!\nNomor: $orderNumber'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate to order history
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = e.toString();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat pesanan: $_errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- TAMPILAN UI ---
  @override
  Widget build(BuildContext context) {
    // Format Rupiah sederhana
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Pesanan Baru'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: _isLoadingProducts
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- BAGIAN 1: FORM TAMBAH PRODUK ---
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '1. Pilih Produk & Jumlah',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // Dropdown Produk
                          DropdownButtonFormField<Product>(
                            initialValue: _selectedProduct,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Pilih Produk Sawit',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            items: _availableProducts.map((product) {
                              return DropdownMenuItem(
                                value: product,
                                child: Text(
                                  product.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedProduct = value;
                              });
                            },
                          ),

                          // Info Harga (jika produk dipilih)
                          if (_selectedProduct != null)
                            Padding(
                              padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
                              child: Text(
                                'Harga: ${currencyFormat.format(_safeDouble(_selectedProduct!.pricePerTon))} / ${_selectedProduct!.unit}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                          SizedBox(height: 12.h),

                          // Input Jumlah & Tombol Tambah
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: _quantityController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: InputDecoration(
                                    labelText: 'Jumlah',
                                    suffixText:
                                        _selectedProduct?.unit ?? 'Kg/Ton',
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  height:
                                      50.h, // Samakan tinggi dengan textfield
                                  child: ElevatedButton(
                                    onPressed: _addToCart,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E7D32),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Icon(Icons.add_shopping_cart),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // --- BAGIAN 2: KERANJANG BELANJA (CART) ---
                  Text(
                    '2. Keranjang Belanja (${ref.watch(cartProvider).length} Item)',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  ref.watch(cartProvider).isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(30.h),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.remove_shopping_cart_outlined,
                                size: 40.sp,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8.h),
                              const Text('Belum ada produk di keranjang'),
                            ],
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: ref.watch(cartProvider).length,
                          separatorBuilder: (_, __) => SizedBox(height: 8.h),
                          itemBuilder: (context, index) {
                            final cartItems = ref.watch(cartProvider);
                            final item = cartItems[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green[100],
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ),
                                title: Text(
                                  item.product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${_safeDouble(item.quantity)} ${item.product.unit} x ${currencyFormat.format(_safeDouble(item.product.pricePerTon))}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      currencyFormat.format(
                                        _safeDouble(item.subtotal),
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _removeFromCart(item.id),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                  SizedBox(height: 24.h),

                  // --- BAGIAN 3: PENGIRIMAN ---
                  Text(
                    '3. Info Pengiriman',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Address field with auto-fill button
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _addressController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Alamat Lengkap Pengiriman',
                          hintText: 'Nama Jalan, Gudang, Kota...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isLoadingAddress
                                  ? null
                                  : _fillAddressFromCurrentLocation,
                              icon: _isLoadingAddress
                                  ? SizedBox(
                                      width: 16.w,
                                      height: 16.h,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    )
                                  : const Icon(Icons.my_location, size: 18),
                              label: const Text(
                                'Gunakan Lokasi Saat Ini',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF2E7D32),
                                side: const BorderSide(
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _loadUserProfile,
                              icon: const Icon(
                                Icons.person_pin_circle,
                                size: 18,
                              ),
                              label: const Text(
                                'Gunakan Alamat Profil',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF2E7D32),
                                side: const BorderSide(
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Date Picker
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDeliveryDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (picked != null) {
                        setState(() => _selectedDeliveryDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Rencana Tanggal Kirim',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(
                        DateFormat(
                          'EEEE, d MMMM yyyy',
                          'id_ID',
                        ).format(_selectedDeliveryDate),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Catatan Tambahan (Opsional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note_alt_outlined),
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // --- BAGIAN 4: TOTAL & SUBMIT ---
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9), // Light Green
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Estimasi:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          ref.watch(formattedCartTotalProvider),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  SizedBox(
                    width: double.infinity,
                    height: 55.h,
                    child: ElevatedButton(
                      onPressed:
                          _isSubmitting || ref.watch(cartProvider).isEmpty
                          ? null
                          : _submitOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'KIRIM PESANAN',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
    );
  }

  /// Fill address from current GPS location
  Future<void> _fillAddressFromCurrentLocation() async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Izin lokasi ditolak';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Izin lokasi ditolak permanen. Silakan aktifkan di pengaturan.';
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Note: Location is used only for geocoding, not stored

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '';

        if (place.street != null && place.street!.isNotEmpty) {
          address += place.street!;
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          address += address.isEmpty
              ? place.subLocality!
              : ', ${place.subLocality}';
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          address += address.isEmpty ? place.locality! : ', ${place.locality}';
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          address += address.isEmpty
              ? place.administrativeArea!
              : ', ${place.administrativeArea}';
        }

        _addressController.text = address.isEmpty
            ? 'Alamat tidak ditemukan'
            : address;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alamat berhasil diisi dari lokasi saat ini'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendapatkan lokasi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAddress = false;
        });
      }
    }
  }
}
