import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../shared/models/models.dart';
import '../../shared/repositories/order_repository.dart';
import '../../shared/repositories/tracking_repository.dart';
import '../tracking/pages/tracking_progress_screen.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  final OrderRepository _orderRepository = OrderRepository();

  List<Order> orders = [];
  List<Order> filteredOrders = [];
  bool isLoading = true;
  String? error;
  String selectedFilter = 'all';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final fetchedOrders = await _orderRepository.getMyOrders();
      setState(() {
        orders = fetchedOrders;
        _filterOrders();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Gagal memuat riwayat pesanan: $e';
        isLoading = false;
      });
    }
  }

  void _filterOrders() {
    setState(() {
      switch (selectedFilter) {
        case 'all':
          filteredOrders = orders;
          break;
        case 'pending':
          filteredOrders = orders
              .where((order) => order.status == 'pending')
              .toList();
          break;
        case 'processing':
          filteredOrders = orders
              .where((order) => order.status == 'confirmed')
              .toList();
          break;
        case 'shipped':
          filteredOrders = orders
              .where((order) => order.status == 'shipped')
              .toList();
          break;
        case 'delivered':
          filteredOrders = orders
              .where((order) => order.status == 'completed')
              .toList();
          break;
      }

      // Sort by order date (newest first)
      filteredOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'processing':
        return 'Diproses';
      case 'shipped':
        return 'Dikirim';
      case 'delivered':
        return 'Selesai';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'processing':
        return Icons.engineering;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  Future<void> _cancelOrder(String orderId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pesanan'),
        content: const Text('Apakah Anda yakin ingin membatalkan pesanan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _orderRepository.cancelOrder(orderId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesanan berhasil dibatalkan'),
            backgroundColor: Colors.green,
          ),
        );
        _loadOrders(); // Refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membatalkan pesanan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          onTap: (index) {
            switch (index) {
              case 0:
                selectedFilter = 'all';
                break;
              case 1:
                selectedFilter = 'pending';
                break;
              case 2:
                selectedFilter = 'processing';
                break;
              case 3:
                selectedFilter = 'shipped';
                break;
              case 4:
                selectedFilter = 'delivered';
                break;
            }
            _filterOrders();
          },
          tabs: [
            Tab(text: 'Semua (${orders.length})'),
            Tab(
              text:
                  'Menunggu (${orders.where((o) => o.status == 'pending').length})',
            ),
            Tab(
              text:
                  'Diproses (${orders.where((o) => o.status == 'confirmed').length})',
            ),
            Tab(
              text:
                  'Dikirim (${orders.where((o) => o.status == 'shipped').length})',
            ),
            Tab(
              text:
                  'Selesai (${orders.where((o) => o.status == 'completed').length})',
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
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
                      'Gagal memuat pesanan',
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
                      onPressed: _loadOrders,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
            : filteredOrders.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64.sp,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Belum ada pesanan',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      selectedFilter == 'all'
                          ? 'Anda belum memiliki pesanan'
                          : 'Tidak ada pesanan dengan status ${_getStatusText(selectedFilter)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  return _buildOrderCard(order);
                },
              ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final orderDate = order.orderDate;
    final requestedDelivery = order.deliveryDate ?? order.orderDate;
    final status = order.status;

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with order ID and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: _getStatusColor(status).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(status),
                        size: 16.sp,
                        color: _getStatusColor(status),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _getStatusText(status),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Product info
            Text(
              order.orderDetails?.isNotEmpty == true
                  ? order.orderDetails!.first.product?.name ?? 'Produk'
                  : 'Produk',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '${order.totalQuantity.toStringAsFixed(1)} ton',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),

            SizedBox(height: 12.h),

            // Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Harga:',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                ),
                Text(
                  order.formattedTotalAmount,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Dates
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanggal Pesan:',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${orderDate.day}/${orderDate.month}/${orderDate.year}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengiriman:',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${requestedDelivery.day}/${requestedDelivery.month}/${requestedDelivery.year}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Delivery address
            if (order.deliveryAddress != null) ...[
              Text(
                'Alamat Pengiriman:',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
              Text(
                order.deliveryAddress!,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
              ),
            ],

            // Tracking button for shipped orders
            if (status == 'shipped') ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Text(
                    'Status: Sedang Dikirim',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () async {
                      // Show loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      );

                      try {
                        // Get shipment by order ID
                        final trackingRepo = TrackingRepository();
                        final shipment = await trackingRepo
                            .getShipmentByOrderId(order.id);

                        if (!mounted) return;
                        Navigator.pop(context); // Close loading

                        if (shipment == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data pengiriman belum tersedia'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        // Navigate to tracking screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TrackingProgressScreen(shipmentId: shipment.id),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        Navigator.pop(context); // Close loading
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal memuat tracking: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      Icons.location_on,
                      size: 16.sp,
                      color: const Color(0xFF2E7D32),
                    ),
                    label: Text(
                      'Lacak Pengiriman',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: 12.h),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status == 'pending') ...[
                  TextButton(
                    onPressed: () => _cancelOrder(order.id),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: Text('Batalkan', style: TextStyle(fontSize: 12.sp)),
                  ),
                  SizedBox(width: 8.w),
                ],
                OutlinedButton(
                  onPressed: () {
                    _showOrderDetails(order);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: const Color(0xFF2E7D32)),
                    foregroundColor: const Color(0xFF2E7D32),
                  ),
                  child: Text('Detail', style: TextStyle(fontSize: 12.sp)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Pesanan ${order.orderNumber}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                'Produk:',
                order.orderDetails?.isNotEmpty == true
                    ? order.orderDetails!.first.product?.name ?? 'Produk'
                    : 'Produk',
              ),
              _buildDetailRow(
                'Jumlah:',
                '${order.totalQuantity.toStringAsFixed(1)} ton',
              ),
              _buildDetailRow('Total Harga:', order.formattedTotalAmount),
              _buildDetailRow('Status:', _getStatusText(order.status)),
              _buildDetailRow(
                'Tanggal Pesan:',
                order.orderDate.toString().substring(0, 16),
              ),
              if (order.deliveryDate != null)
                _buildDetailRow(
                  'Pengiriman Diinginkan:',
                  order.deliveryDate!.toString().substring(0, 10),
                ),
              if (order.deliveryAddress != null)
                _buildDetailRow('Alamat Pengiriman:', order.deliveryAddress!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12.sp, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
