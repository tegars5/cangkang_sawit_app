import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/common/common_widgets.dart';

/// Admin Users Page - Driver Management
class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({super.key});

  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _tabs = [
    'Active Drivers',
    'Available',
    'On Duty',
    'Inactive',
  ];

  // Dummy data
  final List<Map<String, dynamic>> _drivers = [
    {
      'id': 'DRV-001',
      'name': 'Ahmad Sutrisno',
      'phone': '+62 812-3456-7890',
      'email': 'ahmad.sutrisno@example.com',
      'vehicle': 'B 1234 ABC',
      'vehicleType': 'Truck Container 20ft',
      'status': 'On Duty',
      'currentTrip': 'SH-202405-00456',
      'completedTrips': 125,
      'rating': 4.8,
      'joinDate': '15 Jan 2023',
      'lastActive': '2 minutes ago',
    },
    {
      'id': 'DRV-002',
      'name': 'Budi Santoso',
      'phone': '+62 812-9876-5432',
      'email': 'budi.santoso@example.com',
      'vehicle': 'B 5678 DEF',
      'vehicleType': 'Truck Container 40ft',
      'status': 'Available',
      'currentTrip': null,
      'completedTrips': 89,
      'rating': 4.6,
      'joinDate': '03 Mar 2023',
      'lastActive': '15 minutes ago',
    },
    {
      'id': 'DRV-003',
      'name': 'Andi Wijaya',
      'phone': '+62 812-1111-2222',
      'email': 'andi.wijaya@example.com',
      'vehicle': 'B 9012 GHI',
      'vehicleType': 'Truck Container 20ft',
      'status': 'Inactive',
      'currentTrip': null,
      'completedTrips': 67,
      'rating': 4.4,
      'joinDate': '20 May 2023',
      'lastActive': '2 days ago',
    },
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
          'Drivers',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Show driver statistics
            },
            icon: Icon(
              Icons.bar_chart_outlined,
              color: Colors.white,
              size: 24.sp,
            ),
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
                        '2',
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
            hintText: 'Search by name or vehicle',
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

          // Drivers List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // TODO: Implement refresh
              },
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _drivers.length,
                itemBuilder: (context, index) {
                  final driver = _drivers[index];
                  return _buildDriverCard(driver);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "admin_users_fab",
        onPressed: () {
          _showAddDriverDialog();
        },
        backgroundColor: const Color(0xFF1B5E20),
        child: Icon(
          Icons.person_add_outlined,
          color: Colors.white,
          size: 24.sp,
        ),
      ),
    );
  }

  Widget _buildDriverCard(Map<String, dynamic> driver) {
    return GestureDetector(
      onTap: () {
        _showDriverDetails(driver);
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
                children: [
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor: const Color(0xFF1B5E20).withOpacity(0.1),
                    child: Text(
                      driver['name'].split(' ').map((n) => n[0]).take(2).join(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1B5E20),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              driver['name'],
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            StatusBadge(status: driver['status']),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          driver['id'],
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Vehicle Info
              Row(
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 16.sp,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${driver['vehicle']} - ${driver['vehicleType']}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              // Contact Info
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 16.sp,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    driver['phone'],
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Stats Row
              Row(
                children: [
                  _buildStatItem('Trips', driver['completedTrips'].toString()),
                  SizedBox(width: 24.w),
                  _buildStatItem('Rating', driver['rating'].toString()),
                  SizedBox(width: 24.w),
                  _buildStatItem('Active', driver['lastActive']),
                ],
              ),

              // Current Trip (if on duty)
              if (driver['currentTrip'] != null) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_shipping,
                        size: 16.sp,
                        color: const Color(0xFF1B5E20),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Current Trip: ${driver['currentTrip']}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF1B5E20),
                          fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  void _showDriverDetails(Map<String, dynamic> driver) {
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
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: const Color(0xFF1B5E20).withOpacity(0.1),
                    child: Text(
                      driver['name'].split(' ').map((n) => n[0]).take(2).join(),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1B5E20),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver['name'],
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          driver['id'],
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        StatusBadge(status: driver['status']),
                      ],
                    ),
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
                    // Contact Information
                    _buildDetailSection('Contact Information', [
                      {'label': 'Phone', 'value': driver['phone']},
                      {'label': 'Email', 'value': driver['email']},
                      {'label': 'Join Date', 'value': driver['joinDate']},
                      {'label': 'Last Active', 'value': driver['lastActive']},
                    ]),

                    // Vehicle Information
                    _buildDetailSection('Vehicle Information', [
                      {'label': 'Vehicle Number', 'value': driver['vehicle']},
                      {'label': 'Vehicle Type', 'value': driver['vehicleType']},
                      {'label': 'License Plate', 'value': driver['vehicle']},
                    ]),

                    // Performance Stats
                    _buildDetailSection('Performance', [
                      {
                        'label': 'Completed Trips',
                        'value': driver['completedTrips'].toString(),
                      },
                      {
                        'label': 'Average Rating',
                        'value': '${driver['rating']}/5.0',
                      },
                      {'label': 'On Time Delivery', 'value': '94%'},
                      {'label': 'Customer Satisfaction', 'value': '96%'},
                    ]),

                    SizedBox(height: 20.h),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(
                            text: 'Call Driver',
                            onPressed: () {
                              // TODO: Call driver
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: PrimaryButton(
                            text: 'Send Message',
                            onPressed: () {
                              // TODO: Send message
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
                          width: 120.w,
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

  void _showAddDriverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Driver'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Driver Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Vehicle Number',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement add driver logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Driver added successfully'),
                  backgroundColor: Color(0xFF1B5E20),
                ),
              );
            },
            child: const Text('Add Driver'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
