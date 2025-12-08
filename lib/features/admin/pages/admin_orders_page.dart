import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// Pastikan import ini sesuai dengan struktur project Kakak
import '../../../shared/models/models.dart';
import '../../../shared/repositories/order_repository.dart';
import '../../../widgets/common/status_badge.dart'; // Widget yang baru kita buat
import 'order_detail_page.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final OrderRepository _orderRepository = OrderRepository();
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filter status
  String _selectedStatus = 'All';
  final List<String> _statusOptions = [
    'All',
    'Pending',
    'Confirmed',
    'Shipped',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Ambil data langsung dari Repository (bukan Service lama)
      final orders = await _orderRepository.getOrders();

      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat pesanan: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<Order> get _filteredOrders {
    if (_selectedStatus == 'All') return _orders;
    return _orders
        .where((o) => o.status.toLowerCase() == _selectedStatus.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pesanan'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // --- Filter Chips ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: _statusOptions.map((status) {
                final isSelected = _selectedStatus == status;
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    selectedColor: const Color(0xFF2E7D32).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? const Color(0xFF2E7D32)
                          : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() {
                          _selectedStatus = status;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // --- List Orders ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : _filteredOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 48.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8.h),
                        Text('Tidak ada pesanan $_selectedStatus'),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.all(16.w),
                    itemCount: _filteredOrders.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: InkWell(
                          onTap: () async {
                            // Navigasi ke Detail (Tunggu hasil jika ada update)
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OrderDetailPage(order: order),
                              ),
                            );
                            // Refresh list setelah kembali (siapa tau status berubah)
                            _fetchOrders();
                          },
                          borderRadius: BorderRadius.circular(12.r),
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      order.orderNumber,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                    // Menggunakan Widget StatusBadge yang baru dibuat
                                    StatusBadge(status: order.status),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 14.sp,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      DateFormat(
                                        'dd MMM yyyy, HH:mm',
                                      ).format(order.orderDate),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(height: 24.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${order.totalQuantity} Ton',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    Text(
                                      currencyFormat.format(order.totalAmount),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                        color: const Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
