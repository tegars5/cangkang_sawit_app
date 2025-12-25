import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/common/common_widgets.dart';
import '../../shipments/domain/entities/shipment.dart';
import '../../shipments/data/repositories/shipment_repository_impl.dart';
import '../../shipments/data/datasources/shipment_remote_datasource.dart';
import '../widgets/assign_driver_dialog.dart';

/// Admin Shipments Page - Prepare and Track Shipments
class AdminShipmentsPage extends ConsumerStatefulWidget {
  const AdminShipmentsPage({super.key});

  @override
  ConsumerState<AdminShipmentsPage> createState() => _AdminShipmentsPageState();
}

class _AdminShipmentsPageState extends ConsumerState<AdminShipmentsPage> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _tabs = [
    'All Shipments',
    'Ready to Ship',
    'In Transit',
    'Delivered',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Shipments',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Show live tracking map
            },
            icon: Icon(Icons.map_outlined, color: Colors.white, size: 24.sp),
          ),
          IconButton(
            onPressed: () {
              // TODO: Show notifications
            },
            icon: Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 24.sp,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 12.w,
                    height: 12.h,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '3',
                        style: TextStyle(
                          fontSize: 8.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          CustomSearchBar(
            controller: _searchController,
            hintText: 'Search by shipment # or driver',
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

          // Shipments List
          Expanded(
            child: FutureBuilder<List<Shipment>>(
              future: _loadShipments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        TextButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final allShipments = snapshot.data ?? [];

                // Filter by selected tab
                final shipments = _filterShipmentsByTab(allShipments);

                if (shipments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text('No shipments found'),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: shipments.length,
                    itemBuilder: (context, index) {
                      final shipment = shipments[index];
                      return _buildShipmentCard(shipment);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: null, // Remove create shipment FAB for now
    );
  }

  Future<List<Shipment>> _loadShipments() async {
    try {
      final datasource = ShipmentRemoteDataSource();
      final repository = ShipmentRepositoryImpl(remoteDataSource: datasource);

      final result = await repository.getShipments();
      return result.fold(
        (failure) => throw Exception(failure.message),
        (shipments) => shipments,
      );
    } catch (e) {
      throw Exception('Failed to load shipments: $e');
    }
  }

  List<Shipment> _filterShipmentsByTab(List<Shipment> shipments) {
    switch (_selectedTabIndex) {
      case 0: // All Shipments
        return shipments;
      case 1: // Ready to Ship (confirmed orders, no driver assigned yet)
        // Only show shipments from CONFIRMED orders that don't have driver
        return shipments
            .where(
              (s) => s.status == 'pending' && s.driverId == null,
              // Order status check removed since order is just ID
            )
            .toList();
      case 2: // In Transit
        return shipments.where((s) => s.status == 'in_transit').toList();
      case 3: // Delivered
        return shipments.where((s) => s.status == 'completed').toList();
      default:
        return shipments;
    }
  }

  Widget _buildShipmentCard(Shipment shipment) {
    final hasDriver = shipment.driverId != null;

    return GestureDetector(
      onTap: () {
        // Navigate to shipment detail (will implement later)
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
              // Header with Delivery Note Number and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      shipment.deliveryNoteNumber ?? shipment.id,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  StatusBadge(status: shipment.status),
                ],
              ),

              SizedBox(height: 8.h),

              // Order ID
              Text(
                'Order: ${shipment.orderId.substring(0, 8)}...',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: 12.h),

              // Driver Info or Assign Button
              if (hasDriver)
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16.sp,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Driver Assigned',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                )
              else
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (context) => AssignDriverDialog(
                        shipmentId: shipment.id,
                        currentDriverId: shipment.driverId,
                      ),
                    );

                    if (result == true) {
                      // Refresh the list
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.person_add, size: 16),
                  label: const Text('Assign Driver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                  ),
                ),

              SizedBox(height: 8.h),

              // Created Date
              Row(
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 16.sp,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Created: ${_formatDate(shipment.createdAt)}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
