import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/order.dart';
import '../providers/order_notifier.dart';

/// Page to create a new order
class CreateOrderPage extends ConsumerStatefulWidget {
  const CreateOrderPage({super.key});

  @override
  ConsumerState<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends ConsumerState<CreateOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _pickupAddressController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _pickupAddressController.dispose();
    _deliveryAddressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Pesanan Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Isi form di bawah untuk membuat pesanan baru',
                          style: TextStyle(color: Colors.blue[900]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quantity Field
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kuantitas (kg)',
                  hintText: 'Masukkan jumlah dalam kg',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.scale),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kuantitas harus diisi';
                  }
                  final quantity = double.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'Kuantitas harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price Per Unit Field
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga per kg (Rp)',
                  hintText: 'Masukkan harga per kg',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga harus diisi';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Harga harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Total Amount Display
              if (_quantityController.text.isNotEmpty &&
                  _priceController.text.isNotEmpty)
                Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Harga:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _calculateTotal(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Pickup Address Field
              TextFormField(
                controller: _pickupAddressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Alamat Pickup',
                  hintText: 'Masukkan alamat pengambilan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat pickup harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Delivery Address Field
              TextFormField(
                controller: _deliveryAddressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Alamat Pengiriman',
                  hintText: 'Masukkan alamat pengiriman',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_shipping),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat pengiriman harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notes Field
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  hintText: 'Tambahkan catatan untuk pesanan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              const SizedBox(height: 24),

              // Error Message
              if (orderState.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          orderState.errorMessage!,
                          style: TextStyle(color: Colors.red[900]),
                        ),
                      ),
                    ],
                  ),
                ),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: orderState.isCreating ? null : _submitOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: orderState.isCreating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Buat Pesanan',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateTotal() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    final total = quantity * price;

    return 'Rp ${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  Future<void> _submitOrder() async {
    // Clear previous error
    ref.read(orderNotifierProvider.notifier).clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final quantity = double.parse(_quantityController.text);
    final price = double.parse(_priceController.text);
    final totalAmount = quantity * price;

    // Create order entity
    final order = Order(
      id: '', // Will be generated by backend
      orderNumber: '', // Will be generated by backend
      customerId: '', // Will be set by backend from auth
      orderDate: DateTime.now(),
      status: 'pending',
      totalQuantity: quantity,
      totalAmount: totalAmount,
      createdAt: DateTime.now(),
      pickupAddress: _pickupAddressController.text,
      deliveryAddress: _deliveryAddressController.text,
      customerNotes: _notesController.text.isEmpty
          ? null
          : _notesController.text,
    );

    // Submit order
    final success = await ref
        .read(orderNotifierProvider.notifier)
        .createOrder(order);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesanan berhasil dibuat'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        // Error message will be shown in UI via orderState.errorMessage
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(orderNotifierProvider).errorMessage ??
                  'Gagal membuat pesanan',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
