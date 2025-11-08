import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/animation_widgets.dart';
import '../../widgets/lottie_animations.dart';

// Model untuk Order
class Order {
  final String id;
  final String orderNumber;
  final String mitraId;
  final String mitraName;
  final DateTime tanggalPesanan;
  final String statusPesanan;
  final double totalKuantitas;
  final double totalKuantitasDiterima;
  final double totalHarga;
  final String? catatanAdmin;
  final String? catatanMitra;
  final DateTime? tanggalKonfirmasi;
  final List<OrderDetail> details;

  Order({
    required this.id,
    required this.orderNumber,
    required this.mitraId,
    required this.mitraName,
    required this.tanggalPesanan,
    required this.statusPesanan,
    required this.totalKuantitas,
    required this.totalKuantitasDiterima,
    required this.totalHarga,
    this.catatanAdmin,
    this.catatanMitra,
    this.tanggalKonfirmasi,
    required this.details,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      mitraId: json['mitra_id'] as String,
      mitraName: json['mitra_name'] as String? ?? 'Unknown Mitra',
      tanggalPesanan: DateTime.parse(json['tanggal_pesanan'] as String),
      statusPesanan: json['status_pesanan'] as String,
      totalKuantitas: (json['total_kuantitas'] as num).toDouble(),
      totalKuantitasDiterima:
          (json['total_kuantitas_diterima'] as num?)?.toDouble() ?? 0.0,
      totalHarga: (json['total_harga'] as num).toDouble(),
      catatanAdmin: json['catatan_admin'] as String?,
      catatanMitra: json['catatan_mitra'] as String?,
      tanggalKonfirmasi: json['tanggal_konfirmasi'] != null
          ? DateTime.parse(json['tanggal_konfirmasi'] as String)
          : null,
      details: [], // Will be populated separately
    );
  }
}

// Model untuk Order Detail
class OrderDetail {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final double jumlahDipesan;
  final double jumlahDiterima;
  final double hargaSatuan;
  final double subtotal;
  final String? catatan;

  OrderDetail({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.jumlahDipesan,
    required this.jumlahDiterima,
    required this.hargaSatuan,
    required this.subtotal,
    this.catatan,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String? ?? 'Unknown Product',
      jumlahDipesan: (json['jumlah_dipesan'] as num).toDouble(),
      jumlahDiterima: (json['jumlah_diterima'] as num?)?.toDouble() ?? 0.0,
      hargaSatuan: (json['harga_satuan'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      catatan: json['catatan'] as String?,
    );
  }
}

class OrderConfirmationScreen extends ConsumerStatefulWidget {
  const OrderConfirmationScreen({super.key});

  @override
  ConsumerState<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState
    extends ConsumerState<OrderConfirmationScreen> {
  List<Order> _pendingOrders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPendingOrders();
  }

  Future<void> _loadPendingOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final supabase = Supabase.instance.client;

      // Load orders dengan status 'pending'
      final ordersResponse = await supabase
          .from('orders')
          .select('''
            *,
            profiles!customer_id(full_name)
          ''')
          .eq('status', 'pending')
          .order('order_date', ascending: false);

      final List<Order> orders = [];

      for (final orderData in ordersResponse) {
        // Load order details untuk setiap order
        final detailsResponse = await supabase
            .from('order_details')
            .select('''
              *,
              products(name)
            ''')
            .eq('order_id', orderData['id']);

        final List<OrderDetail> details = detailsResponse.map((detailData) {
          return OrderDetail(
            id: detailData['id'],
            orderId: detailData['order_id'],
            productId: detailData['product_id'],
            productName: detailData['products']?['name'] ?? 'Unknown Product',
            jumlahDipesan: (detailData['requested_quantity'] as num).toDouble(),
            jumlahDiterima:
                (detailData['confirmed_quantity'] as num?)?.toDouble() ?? 0.0,
            hargaSatuan: (detailData['unit_price'] as num).toDouble(),
            subtotal: (detailData['subtotal'] as num).toDouble(),
            catatan: detailData['notes'],
          );
        }).toList();

        final order = Order(
          id: orderData['id'],
          orderNumber: orderData['order_number'],
          mitraId: orderData['customer_id'],
          mitraName: orderData['profiles']?['full_name'] ?? 'Unknown Customer',
          tanggalPesanan: DateTime.parse(orderData['order_date']),
          statusPesanan: orderData['status'],
          totalKuantitas: (orderData['total_quantity'] as num).toDouble(),
          totalKuantitasDiterima:
              (orderData['confirmed_quantity'] as num?)?.toDouble() ?? 0.0,
          totalHarga: (orderData['total_amount'] as num).toDouble(),
          catatanAdmin: orderData['admin_notes'],
          catatanMitra: orderData['customer_notes'],
          tanggalKonfirmasi: orderData['confirmed_at'] != null
              ? DateTime.parse(orderData['confirmed_at'])
              : null,
          details: details,
        );

        orders.add(order);
      }

      setState(() {
        _pendingOrders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading orders: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Konfirmasi Pesanan',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingOrders,
          ),
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
            ElevatedButton(
              onPressed: _loadPendingOrders,
              child: Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_pendingOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64.sp, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              'Tidak ada pesanan yang perlu dikonfirmasi',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPendingOrders,
      color: const Color(0xFF2E7D32),
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _pendingOrders.length,
        itemBuilder: (context, index) {
          final order = _pendingOrders[index];
          return SlideInWidget(
            direction: SlideDirection.left,
            delay: Duration(milliseconds: 100 * index),
            child: _buildOrderCard(order),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
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
                        'Tanggal: ${_formatDate(order.tanggalPesanan)}',
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
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Text(
                    order.statusPesanan,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Order Details
            Text(
              'Detail Pesanan:',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),

            ...order.details.map((detail) => _buildDetailItem(detail)),

            SizedBox(height: 16.h),

            // Summary
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
                        'Total Kuantitas: ${order.totalKuantitas.toStringAsFixed(2)} ton',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Total Harga: Rp ${_formatCurrency(order.totalHarga)}',
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

            SizedBox(height: 16.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showDetailDialog(order),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF2E7D32)),
                      foregroundColor: Color(0xFF2E7D32),
                    ),
                    child: Text('Lihat Detail'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showConfirmDialog(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Konfirmasi'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(OrderDetail detail) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              detail.productName,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              '${detail.jumlahDipesan.toStringAsFixed(2)} ton',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp),
            ),
          ),
          Expanded(
            child: Text(
              'Rp ${_formatCurrency(detail.hargaSatuan)}',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => OrderDetailDialog(order: order),
    );
  }

  void _showConfirmDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => OrderConfirmDialog(
        order: order,
        onConfirmed: () {
          _loadPendingOrders(); // Refresh list after confirmation
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

// Dialog untuk melihat detail lengkap order
class OrderDetailDialog extends StatelessWidget {
  final Order order;

  const OrderDetailDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(maxHeight: 0.8.sh),
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
                      'Detail Pesanan ${order.orderNumber}',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Info
                    _buildInfoRow('Mitra', order.mitraName),
                    _buildInfoRow(
                      'Tanggal Pesanan',
                      _formatDate(order.tanggalPesanan),
                    ),
                    _buildInfoRow('Status', order.statusPesanan),

                    if (order.catatanMitra != null) ...[
                      SizedBox(height: 8.h),
                      Text(
                        'Catatan Mitra:',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        order.catatanMitra!,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ],

                    SizedBox(height: 16.h),
                    Divider(),

                    // Details
                    Text(
                      'Item Pesanan:',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    ...order.details.map(
                      (detail) => Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail.productName,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Jumlah: ${detail.jumlahDipesan.toStringAsFixed(2)} ton',
                                ),
                                Text(
                                  '@ Rp ${_formatCurrency(detail.hargaSatuan)}',
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Subtotal:'),
                                Text(
                                  'Rp ${_formatCurrency(detail.subtotal)}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),
                    Divider(),

                    // Total
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Kuantitas:',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              Text(
                                '${order.totalKuantitas.toStringAsFixed(2)} ton',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Harga:',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Rp ${_formatCurrency(order.totalHarga)}',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 14.sp)),
          ),
        ],
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

// Dialog untuk konfirmasi order dengan partial acceptance
class OrderConfirmDialog extends StatefulWidget {
  final Order order;
  final VoidCallback onConfirmed;

  const OrderConfirmDialog({
    super.key,
    required this.order,
    required this.onConfirmed,
  });

  @override
  State<OrderConfirmDialog> createState() => _OrderConfirmDialogState();
}

class _OrderConfirmDialogState extends State<OrderConfirmDialog> {
  final Map<String, TextEditingController> _controllers = {};
  final TextEditingController _catatanController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers dengan jumlah dipesan sebagai default
    for (final detail in widget.order.details) {
      _controllers[detail.id] = TextEditingController(
        text: detail.jumlahDipesan.toStringAsFixed(2),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(maxHeight: 0.9.sh),
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
                      'Konfirmasi Pesanan',
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
                    Text(
                      'Mitra: ${widget.order.mitraName}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    Text(
                      'Sesuaikan jumlah yang dapat dipenuhi:',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '(Kosongkan atau isi 0 jika item tidak dapat dipenuhi)',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Item adjustment list
                    ...widget.order.details.map(
                      (detail) => Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail.productName,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Diminta: ${detail.jumlahDipesan.toStringAsFixed(2)} ton',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        '@ Rp ${_formatCurrency(detail.hargaSatuan)}/ton',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: _controllers[detail.id],
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: InputDecoration(
                                      labelText: 'Dipenuhi (ton)',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 8.h,
                                      ),
                                    ),
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Catatan admin
                    TextFormField(
                      controller: _catatanController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Catatan Admin (Opsional)',
                        border: OutlineInputBorder(),
                        hintText: 'Tambahkan catatan jika ada penyesuaian...',
                      ),
                    ),
                  ],
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
                      onPressed: () => Navigator.pop(context),
                      child: Text('Batal'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _confirmOrder,
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
                          : Text('Konfirmasi Pesanan'),
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

  Future<void> _confirmOrder() async {
    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // Prepare update data untuk order details
      double totalKuantitasDiterima = 0;
      final List<Future> detailUpdates = [];

      for (final detail in widget.order.details) {
        final controller = _controllers[detail.id]!;
        final jumlahDiterima = double.tryParse(controller.text) ?? 0.0;
        totalKuantitasDiterima += jumlahDiterima;

        // Update order detail
        detailUpdates.add(
          supabase
              .from('order_details')
              .update({
                'confirmed_quantity': jumlahDiterima,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', detail.id),
        );
      }

      // Execute all detail updates
      await Future.wait(detailUpdates);

      // Update order status dan total
      await supabase
          .from('orders')
          .update({
            'status': 'confirmed',
            'confirmed_quantity': totalKuantitasDiterima,
            'confirmed_at': DateTime.now().toIso8601String(),
            'admin_notes': _catatanController.text.isNotEmpty
                ? _catatanController.text
                : null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', widget.order.id);

      if (mounted) {
        Navigator.pop(context);

        await LottieSuccessDialog.show(
          context,
          title: 'Pesanan Dikonfirmasi!',
          message:
              'Pesanan ${widget.order.orderNumber} berhasil dikonfirmasi.\nTotal dipenuhi: ${totalKuantitasDiterima.toStringAsFixed(2)} ton',
        );

        widget.onConfirmed();
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

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]},',
        );
  }
}
