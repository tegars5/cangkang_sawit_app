import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/lottie_animations.dart';
import '../../services/admin_dashboard_service.dart';

class ManageOrdersScreen extends ConsumerStatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  ConsumerState<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends ConsumerState<ManageOrdersScreen> {
  List<dynamic> orders = [];
  bool isLoading = true;
  String filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => isLoading = true);

    try {
      final result = await AdminDashboardService.getRecentOrders(limit: 100);
      if (result['success']) {
        setState(() {
          orders = result['data'] as List<dynamic>;
        });
      } else {
        if (mounted) {
          LottieSnackbar.showError(
            context,
            message: result['message'] ?? 'Gagal load pesanan',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        LottieSnackbar.showError(context, message: 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  List<dynamic> get filteredOrders {
    if (filterStatus == 'all') return orders;
    return orders
        .where((order) => order['status_pesanan'] == filterStatus)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pesanan'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.grey[100],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Semua', 'all'),
                  SizedBox(width: 8.w),
                  _buildFilterChip('Pending', 'pending'),
                  SizedBox(width: 8.w),
                  _buildFilterChip('Dikonfirmasi', 'confirmed'),
                  SizedBox(width: 8.w),
                  _buildFilterChip('Diproses', 'processing'),
                  SizedBox(width: 8.w),
                  _buildFilterChip('Selesai', 'completed'),
                  SizedBox(width: 8.w),
                  _buildFilterChip('Dibatalkan', 'cancelled'),
                ],
              ),
            ),
          ),

          // Orders list
          Expanded(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF2E7D32),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Memuat data pesanan...',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : filteredOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 80.sp, color: Colors.grey[400]),
                        SizedBox(height: 16.h),
                        Text(
                          'Tidak ada pesanan',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadOrders,
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return _buildOrderCard(order);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "manage_orders_fab",
        onPressed: _showCreateOrderDialog,
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          filterStatus = value;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF2E7D32).withOpacity(0.2),
      checkmarkColor: const Color(0xFF2E7D32),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status_pesanan'] ?? 'pending';
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order['nomor_pesanan'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'Mitra: ${order['mitra_name'] ?? 'N/A'}',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
              ),
              SizedBox(height: 4.h),
              Text(
                'Total: Rp ${_formatCurrency(order['total_harga'] ?? 0)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Tanggal: ${_formatDate(order['created_at'])}',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showOrderDetails(order),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Detail'),
                  ),
                  if (status == 'pending') ...[
                    SizedBox(width: 8.w),
                    TextButton.icon(
                      onPressed: () => _confirmCancelOrder(order),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Batal'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'processing':
        return 'Diproses';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0';
    final value = amount is int ? amount : (amount as num).toInt();
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dt = DateTime.parse(date.toString());
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return date.toString();
    }
  }

  void _showOrderDetails(Map<String, dynamic> order) async {
    // Load detail pesanan dari database
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await AdminDashboardService.getOrderDetails(
        order['order_id'],
      );

      if (mounted) {
        Navigator.pop(context); // Close loading

        if (result['success']) {
          final orderDetail = result['data'];
          _showDetailDialog(orderDetail);
        } else {
          LottieSnackbar.showError(
            context,
            message: result['message'] ?? 'Gagal load detail',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        LottieSnackbar.showError(context, message: 'Error: $e');
      }
    }
  }

  void _showDetailDialog(Map<String, dynamic> orderDetail) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(orderDetail['nomor_pesanan'] ?? 'Detail Pesanan'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                'Status',
                _getStatusText(orderDetail['status_pesanan'] ?? 'pending'),
              ),
              _buildDetailRow(
                'Mitra',
                orderDetail['customer']?['full_name'] ?? 'N/A',
              ),
              _buildDetailRow(
                'Total',
                'Rp ${_formatCurrency(orderDetail['total_harga'])}',
              ),
              _buildDetailRow(
                'Tanggal',
                _formatDate(orderDetail['created_at']),
              ),
              SizedBox(height: 16.h),
              Text(
                'Item Pesanan:',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              ...((orderDetail['items'] as List?) ?? []).map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['nama_produk'] ?? 'N/A',
                          style: TextStyle(fontSize: 13.sp),
                        ),
                      ),
                      Text(
                        '${item['quantity'] ?? 0} ${item['satuan'] ?? 'kg'}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
            width: 80.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 13.sp)),
          ),
        ],
      ),
    );
  }

  void _confirmCancelOrder(Map<String, dynamic> order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pesanan'),
        content: Text(
          'Apakah Anda yakin ingin membatalkan pesanan ${order['nomor_pesanan']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Cancel order
    try {
      final result = await AdminDashboardService.cancelOrder(
        order['order_id'],
        'Dibatalkan oleh admin',
      );

      if (mounted) {
        if (result['success']) {
          LottieSnackbar.showSuccess(
            context,
            message: 'Pesanan berhasil dibatalkan',
          );
          _loadOrders(); // Reload
        } else {
          LottieSnackbar.showError(
            context,
            message: result['message'] ?? 'Gagal membatalkan pesanan',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        LottieSnackbar.showError(context, message: 'Error: $e');
      }
    }
  }

  void _showCreateOrderDialog() {
    // TODO: Implement create order dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur tambah pesanan manual belum diimplementasikan'),
      ),
    );
  }
}
