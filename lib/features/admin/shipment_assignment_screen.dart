import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../widgets/animation_widgets.dart';
import '../../widgets/lottie_animations.dart';

// Model untuk Confirmed Order yang siap untuk pengiriman
class ConfirmedOrder {
  final String id;
  final String orderNumber;
  final String mitraId;
  final String mitraName;
  final DateTime tanggalPesanan;
  final DateTime tanggalKonfirmasi;
  final double totalKuantitasDiterima;
  final double totalHarga;
  final String? catatanAdmin;

  ConfirmedOrder({
    required this.id,
    required this.orderNumber,
    required this.mitraId,
    required this.mitraName,
    required this.tanggalPesanan,
    required this.tanggalKonfirmasi,
    required this.totalKuantitasDiterima,
    required this.totalHarga,
    this.catatanAdmin,
  });

  factory ConfirmedOrder.fromJson(Map<String, dynamic> json) {
    return ConfirmedOrder(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      mitraId: json['mitra_id'] as String,
      mitraName: json['mitra_name'] as String? ?? 'Unknown Mitra',
      tanggalPesanan: DateTime.parse(json['tanggal_pesanan'] as String),
      tanggalKonfirmasi: DateTime.parse(json['tanggal_konfirmasi'] as String),
      totalKuantitasDiterima: (json['total_kuantitas_diterima'] as num)
          .toDouble(),
      totalHarga: (json['total_harga'] as num).toDouble(),
      catatanAdmin: json['catatan_admin'] as String?,
    );
  }
}

// Model untuk Driver (Profile dengan role driver)
class Driver {
  final String id;
  final String fullName;
  final String? phone;
  final bool isActive;

  Driver({
    required this.id,
    required this.fullName,
    this.phone,
    required this.isActive,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class ShipmentAssignmentScreen extends ConsumerStatefulWidget {
  const ShipmentAssignmentScreen({super.key});

  @override
  ConsumerState<ShipmentAssignmentScreen> createState() =>
      _ShipmentAssignmentScreenState();
}

class _ShipmentAssignmentScreenState
    extends ConsumerState<ShipmentAssignmentScreen> {
  List<ConfirmedOrder> _confirmedOrders = [];
  List<Driver> _availableDrivers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Future.wait([_loadConfirmedOrders(), _loadAvailableDrivers()]);
    } catch (e) {
      setState(() {
        _error = 'Error loading data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadConfirmedOrders() async {
    final supabase = Supabase.instance.client;

    // Load orders dengan status 'Dikonfirmasi' yang belum ada shipment-nya
    final ordersResponse = await supabase
        .from('orders')
        .select('''
          *,
          profiles!customer_id(full_name)
        ''')
        .eq('status', 'confirmed')
        .order('confirmed_at', ascending: true);

    final List<ConfirmedOrder> orders = [];

    for (final orderData in ordersResponse) {
      // Check apakah order ini sudah punya shipment
      final shipmentCheck = await supabase
          .from('shipments')
          .select('id')
          .eq('order_id', orderData['id'])
          .maybeSingle();

      // Jika belum ada shipment, tambahkan ke list
      if (shipmentCheck == null) {
        final order = ConfirmedOrder(
          id: orderData['id'],
          orderNumber: orderData['order_number'],
          mitraId: orderData['customer_id'],
          mitraName: orderData['profiles']?['full_name'] ?? 'Unknown Customer',
          tanggalPesanan: DateTime.parse(orderData['order_date']),
          tanggalKonfirmasi: DateTime.parse(orderData['confirmed_at']),
          totalKuantitasDiterima: (orderData['confirmed_quantity'] as num)
              .toDouble(),
          totalHarga: (orderData['total_amount'] as num).toDouble(),
          catatanAdmin: orderData['admin_notes'],
        );
        orders.add(order);
      }
    }

    setState(() {
      _confirmedOrders = orders;
    });
  }

  Future<void> _loadAvailableDrivers() async {
    final supabase = Supabase.instance.client;

    // Load drivers (profiles dengan role = 'driver' dan is_active = true)
    final driversResponse = await supabase
        .from('profiles')
        .select('*')
        .eq('role', 'driver')
        .eq('is_active', true)
        .order('full_name', ascending: true);

    final List<Driver> drivers = driversResponse.map((driverData) {
      return Driver.fromJson(driverData);
    }).toList();

    setState(() {
      _availableDrivers = drivers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Penugasan Pengiriman',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, color: Colors.red),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(onPressed: _loadData, child: Text('Coba Lagi')),
          ],
        ),
      );
    }

    if (_confirmedOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 64.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              'Tidak ada pesanan yang siap untuk pengiriman',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 8.h),
            Text(
              'Pastikan ada pesanan dengan status "Dikonfirmasi"',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF2E7D32),
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _confirmedOrders.length,
        itemBuilder: (context, index) {
          final order = _confirmedOrders[index];
          return SlideInWidget(
            direction: SlideDirection.left,
            delay: Duration(milliseconds: 100 * index),
            child: _buildOrderCard(order),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(ConfirmedOrder order) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Mitra: ${order.mitraName}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Dikonfirmasi: ${_formatDate(order.tanggalKonfirmasi)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    'Siap Kirim',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Order Summary
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kuantitas: ${order.totalKuantitasDiterima.toStringAsFixed(2)} ton',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Total: Rp ${_formatCurrency(order.totalHarga)}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (order.catatanAdmin != null) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catatan Admin:',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      order.catatanAdmin!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.blue[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 16.h),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAssignDialog(order),
                icon: Icon(Icons.assignment),
                label: Text('Tugaskan Pengiriman'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignDialog(ConfirmedOrder order) {
    showDialog(
      context: context,
      builder: (context) => ShipmentAssignDialog(
        order: order,
        availableDrivers: _availableDrivers,
        onAssigned: () {
          _loadData(); // Refresh data after assignment
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]},',
        );
  }
}

// Dialog untuk assign pengiriman dengan upload surat jalan
class ShipmentAssignDialog extends StatefulWidget {
  final ConfirmedOrder order;
  final List<Driver> availableDrivers;
  final VoidCallback onAssigned;

  const ShipmentAssignDialog({
    super.key,
    required this.order,
    required this.availableDrivers,
    required this.onAssigned,
  });

  @override
  State<ShipmentAssignDialog> createState() => _ShipmentAssignDialogState();
}

class _ShipmentAssignDialogState extends State<ShipmentAssignDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomorSuratJalanController =
      TextEditingController();
  String? _selectedDriverId;
  File? _selectedFile;
  String? _fileName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateSuratJalanNumber();
  }

  void _generateSuratJalanNumber() {
    final now = DateTime.now();
    final orderNum = widget.order.orderNumber.split('/').last;
    _nomorSuratJalanController.text =
        'SJ/${now.year}/${now.month.toString().padLeft(2, '0')}/$orderNum';
  }

  @override
  void dispose() {
    _nomorSuratJalanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(maxHeight: 0.85.sh),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Color(0xFF2E7D32),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tugaskan Pengiriman',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Info
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order: ${widget.order.orderNumber}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Mitra: ${widget.order.mitraName}'),
                            Text(
                              'Kuantitas: ${widget.order.totalKuantitasDiterima.toStringAsFixed(2)} ton',
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Nomor Surat Jalan
                      TextFormField(
                        controller: _nomorSuratJalanController,
                        decoration: InputDecoration(
                          labelText: 'Nomor Surat Jalan',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.receipt_long),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nomor surat jalan wajib diisi';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16.h),

                      // Driver Selection
                      DropdownButtonFormField<String>(
                        initialValue: _selectedDriverId,
                        decoration: InputDecoration(
                          labelText: 'Pilih Driver',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: widget.availableDrivers.map((driver) {
                          return DropdownMenuItem(
                            value: driver.id,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  driver.fullName,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                if (driver.phone != null)
                                  Text(
                                    driver.phone!,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDriverId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Driver wajib dipilih';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16.h),

                      // File Upload
                      Text(
                        'Upload Surat Jalan (PDF)',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      Container(
                        width: double.infinity,
                        height: 100.h,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: InkWell(
                          onTap: _pickFile,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _selectedFile != null
                                    ? Icons.description
                                    : Icons.cloud_upload,
                                size: 32.sp,
                                color: _selectedFile != null
                                    ? Color(0xFF2E7D32)
                                    : Colors.grey[600],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                _fileName ?? 'Tap untuk pilih file PDF',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: _selectedFile != null
                                      ? Color(0xFF2E7D32)
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (_selectedFile != null) ...[
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  'File siap untuk diupload',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: Text('Batal'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _assignShipment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text('Tugaskan'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: false,
        withReadStream: false,
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        setState(() {
          _selectedFile = file;
          _fileName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _assignShipment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Surat jalan PDF wajib diupload'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // 1. Upload PDF ke Supabase Storage
      String? pdfUrl;
      if (_selectedFile != null) {
        final fileName =
            'surat_jalan_${widget.order.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';

        try {
          await supabase.storage
              .from('delivery-notes')
              .upload(fileName, _selectedFile!);

          pdfUrl = supabase.storage
              .from('delivery-notes')
              .getPublicUrl(fileName);
          // PDF uploaded successfully
        } catch (uploadError) {
          // PDF upload failed, continue without PDF URL
        }
      }

      // 2. Create shipment record
      await supabase.from('shipments').insert({
        'order_id': widget.order.id,
        'driver_id': _selectedDriverId!,
        'delivery_note_number': _nomorSuratJalanController.text.trim(),
        'delivery_note_url': pdfUrl,
        'status': 'pending',
        'assigned_at': DateTime.now().toIso8601String(),
      });

      // 3. Update order status ke 'shipped'
      await supabase
          .from('orders')
          .update({
            'status': 'shipped',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', widget.order.id);

      if (mounted) {
        Navigator.pop(context);

        await LottieSuccessDialog.show(
          context,
          title: 'Pengiriman Berhasil Ditugaskan!',
          message:
              'Order ${widget.order.orderNumber} telah ditugaskan ke driver.\nNomor Surat Jalan: ${_nomorSuratJalanController.text}',
        );

        widget.onAssigned();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
