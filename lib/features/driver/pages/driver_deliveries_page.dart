import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/common/common_widgets.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Driver Deliveries Page - Delivery history and proof management
class DriverDeliveriesPage extends ConsumerStatefulWidget {
  const DriverDeliveriesPage({super.key});

  @override
  ConsumerState<DriverDeliveriesPage> createState() =>
      _DriverDeliveriesPageState();
}

class _DriverDeliveriesPageState extends ConsumerState<DriverDeliveriesPage> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _deliveries = [];
  bool _isLoading = true;

  final List<String> _tabs = ['Today', 'This Week', 'This Month'];

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
  }

  Future<void> _loadDeliveries() async {
    try {
      setState(() => _isLoading = true);

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Get deliveries from deliveries table with joins
        final response = await Supabase.instance.client
            .from('deliveries')
            .select('''
              *,
              shipments!inner(
                id,
                delivery_note_number,
                orders!inner(
                  id,
                  order_number,
                  total_amount,
                  pickup_address,
                  delivery_address,
                  profiles!customer_id(full_name)
                )
              )
            ''')
            .eq('driver_id', user.id)
            .order('created_at', ascending: false)
            .limit(50);

        final deliveries = response.map<Map<String, dynamic>>((delivery) {
          final shipment = delivery['shipments'];
          final order = shipment?['orders'];
          final customer = order?['profiles'];

          return {
            'id': delivery['id'],
            'deliveryNumber':
                shipment?['delivery_note_number'] ??
                'DEL-${delivery['id'].toString().substring(0, 8)}',
            'taskNumber': order?['order_number'] ?? 'Unknown',
            'customerName': customer?['full_name'] ?? 'Unknown Customer',
            'destination': order?['delivery_address'] ?? 'Unknown Destination',
            'pickupLocation': order?['pickup_address'] ?? 'Unknown Pickup',
            'completedTime': _formatTime(delivery['delivery_time']),
            'pickupTime': _formatTime(delivery['pickup_time']),
            'quantity':
                '${(order?['total_amount'] ?? 0).toStringAsFixed(0)} kg',
            'distance': 'N/A', // Calculate if needed
            'earnings':
                'Rp ${((order?['total_amount'] ?? 0) * 0.1).toStringAsFixed(0)}', // 10% of order value
            'rating': 4.5, // Default rating - could come from customer feedback
            'date': _formatDate(delivery['delivery_time']),
            'status': delivery['status'] ?? 'completed',
            'hasPhoto': delivery['delivery_photo'] != null,
            'hasSignature': delivery['delivery_signature'] != null,
            'deliveryPhoto': delivery['delivery_photo'],
            'deliverySignature': delivery['delivery_signature'],
            'notes': delivery['notes'],
          };
        }).toList();

        setState(() {
          _deliveries = deliveries;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading deliveries: $e');
      // Use fallback empty state
      setState(() {
        _deliveries = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Deliveries',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Show delivery statistics
            },
            icon: Icon(
              Icons.bar_chart_outlined,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Export delivery report
            },
            icon: Icon(
              Icons.download_outlined,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          // Summary Stats
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Today',
                    '2',
                    'Deliveries',
                    Icons.local_shipping_outlined,
                    const Color(0xFF1976D2),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildStatCard(
                    'Distance',
                    '130 km',
                    'Traveled',
                    Icons.route_outlined,
                    const Color(0xFF7B1FA2),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildStatCard(
                    'Earnings',
                    'Rp 550K',
                    'Today',
                    Icons.monetization_on_outlined,
                    const Color(0xFFE65100),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          CustomSearchBar(
            controller: _searchController,
            hintText: 'Search by delivery # or customer',
            onFilterTap: () {
              // TODO: Show filter options
            },
            onChanged: (value) {
              // TODO: Implement search
            },
          ),

          // Tab Header
          TabHeader(
            tabs: _tabs,
            selectedIndex: _selectedTabIndex,
            onTap: (index) {
              setState(() {
                _selectedTabIndex = index;
              });
            },
          ),

          // Deliveries List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadDeliveries,
                    child: _deliveries.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text('No deliveries found'),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            itemCount: _deliveries.length,
                            itemBuilder: (context, index) {
                              final delivery = _deliveries[index];
                              return _buildDeliveryCard(delivery);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 9.sp, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(Map<String, dynamic> delivery) {
    return GestureDetector(
      onTap: () {
        _showDeliveryDetails(delivery);
      },
      child: Container(
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    delivery['deliveryNumber'],
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              // Customer & Task Info
              Text(
                delivery['customerName'],
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 4.h),

              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14.sp,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      delivery['destination'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Delivery Stats
              Row(
                children: [
                  _buildDeliveryStatItem(
                    Icons.schedule_outlined,
                    delivery['completedTime'],
                  ),
                  SizedBox(width: 16.w),
                  _buildDeliveryStatItem(
                    Icons.route_outlined,
                    delivery['distance'],
                  ),
                  SizedBox(width: 16.w),
                  _buildDeliveryStatItem(
                    Icons.inventory_2_outlined,
                    delivery['quantity'],
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Earnings and Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on_outlined,
                        size: 16.sp,
                        color: const Color(0xFF1B5E20),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        delivery['earnings'],
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16.sp, color: Colors.amber),
                      SizedBox(width: 4.w),
                      Text(
                        delivery['rating'].toString(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Proof Status
              Row(
                children: [
                  _buildProofStatus('Photo', delivery['hasPhoto']),
                  SizedBox(width: 12.w),
                  _buildProofStatus('Signature', delivery['hasSignature']),
                  const Spacer(),
                  Text(
                    delivery['date'],
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryStatItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: Colors.grey[600]),
        SizedBox(width: 4.w),
        Text(
          value,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildProofStatus(String label, bool hasProof) {
    return Row(
      children: [
        Icon(
          hasProof ? Icons.check_circle : Icons.cancel,
          size: 14.sp,
          color: hasProof ? Colors.green : Colors.red,
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: hasProof ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showDeliveryDetails(Map<String, dynamic> delivery) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 8.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Details',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          delivery['deliveryNumber'],
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Delivery Information
                    _buildDetailSection('Delivery Information', [
                      {'label': 'Customer', 'value': delivery['customerName']},
                      {
                        'label': 'Destination',
                        'value': delivery['destination'],
                      },
                      {
                        'label': 'Completed',
                        'value': delivery['completedTime'],
                      },
                      {'label': 'Quantity', 'value': delivery['quantity']},
                      {'label': 'Distance', 'value': delivery['distance']},
                      {'label': 'Earnings', 'value': delivery['earnings']},
                    ]),

                    // Customer Rating
                    _buildDetailSection('Customer Rating', [
                      {'label': 'Rating', 'value': '${delivery['rating']}/5.0'},
                      {
                        'label': 'Feedback',
                        'value': 'Excellent service, on time delivery',
                      },
                    ]),

                    SizedBox(height: 20.h),

                    // Proof Documents
                    Text(
                      'Proof Documents',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    Row(
                      children: [
                        Expanded(
                          child: _buildProofCard(
                            'Delivery Photo',
                            delivery['hasPhoto'],
                            Icons.camera_alt_outlined,
                            () {
                              // TODO: View photo
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildProofCard(
                            'Customer Signature',
                            delivery['hasSignature'],
                            Icons.draw_outlined,
                            () {
                              // TODO: View signature
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Map<String, String>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: items
                .map(
                  (item) => Padding(
                    padding: EdgeInsets.only(
                      bottom: items.last == item ? 0 : 12.h,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100.w,
                          child: Text(
                            item['label']!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item['value']!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildProofCard(
    String title,
    bool hasProof,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: hasProof ? onTap : null,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: hasProof
              ? Colors.green.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: hasProof
                ? Colors.green.withOpacity(0.3)
                : Colors.red.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              hasProof ? icon : Icons.close,
              color: hasProof ? Colors.green : Colors.red,
              size: 32.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: hasProof ? Colors.green : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Text(
              hasProof ? 'Available' : 'Missing',
              style: TextStyle(
                fontSize: 10.sp,
                color: hasProof ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(dynamic dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      if (dateTime is String) {
        final parsed = DateTime.parse(dateTime);
        return '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
      }
      return 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatDate(dynamic dateTime) {
    if (dateTime == null) return 'Today';
    try {
      if (dateTime is String) {
        final parsed = DateTime.parse(dateTime);
        final now = DateTime.now();
        final diff = now.difference(parsed).inDays;

        if (diff == 0) return 'Today';
        if (diff == 1) return 'Yesterday';
        if (diff < 7) return '$diff days ago';

        return '${parsed.day}/${parsed.month}/${parsed.year}';
      }
      return 'Today';
    } catch (e) {
      return 'Today';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
