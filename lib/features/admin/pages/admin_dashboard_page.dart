import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/common/common_widgets.dart';

/// Admin Dashboard - Welcome back, Admin
class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Icon(Icons.menu, color: const Color(0xFF374151), size: 24.sp),
            const Spacer(),
            Text(
              'Fujiyama Biomass',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF374151),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.person_outline,
              color: const Color(0xFF374151),
              size: 24.sp,
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement refresh logic
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Text(
                'Welcome back, Admin',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Last updated: 10:45 AM',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),

              SizedBox(height: 24.h),

              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.shopping_bag_outlined,
                      title: 'New Orders',
                      value: '12',
                      color: const Color(0xFF1B5E20),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.local_shipping_outlined,
                      title: 'Pending Shipments',
                      value: '8',
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.people_outline,
                      title: 'Active Partners',
                      value: '54',
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.inventory_outlined,
                      title: 'Inventory (Tons)',
                      value: '1,200',
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              // Quick Actions
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 16.h),

              PrimaryButton(
                text: 'Create New Order',
                icon: Icons.add,
                onPressed: () {
                  // TODO: Navigate to create order
                },
              ),

              SizedBox(height: 12.h),

              SecondaryButton(
                text: 'Manage Products',
                icon: Icons.inventory_2_outlined,
                onPressed: () {
                  // TODO: Navigate to manage products
                },
              ),

              SizedBox(height: 12.h),

              SecondaryButton(
                text: 'View All Shipments',
                icon: Icons.local_shipping_outlined,
                onPressed: () {
                  // TODO: Navigate to shipments
                },
              ),

              SizedBox(height: 32.h),

              // Order Status Chart
              InfoCard(
                title: 'Order Status',
                child: Column(
                  children: [
                    // Simple circular progress representation
                    Container(
                      width: 120.w,
                      height: 120.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFF3F4F6),
                          width: 8,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Progress arc (simplified)
                          Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: CircularProgressIndicator(
                              value: 0.65,
                              strokeWidth: 8,
                              backgroundColor: const Color(0xFFF3F4F6),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFF59E0B),
                              ),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '48',
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                                Text(
                                  'Total Orders',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Status Legend
                    Wrap(
                      spacing: 16.w,
                      runSpacing: 8.h,
                      children: [
                        _buildStatusLegend(
                          'Completed',
                          const Color(0xFF10B981),
                        ),
                        _buildStatusLegend(
                          'In Transit',
                          const Color(0xFF1E40AF),
                        ),
                        _buildStatusLegend(
                          'Processing',
                          const Color(0xFFF59E0B),
                        ),
                        _buildStatusLegend('Awaiting', const Color(0xFF6B7280)),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Recent Activity
              InfoCard(
                title: 'Recent Activity',
                child: Column(
                  children: [
                    _buildActivityItem(
                      icon: Icons.shopping_cart,
                      title: 'New order #1024 placed',
                      time: '2 minutes ago',
                      color: const Color(0xFF1B5E20),
                    ),
                    _buildActivityItem(
                      icon: Icons.local_shipping,
                      title: 'Shipment #XYZ updated',
                      time: '15 minutes ago',
                      color: const Color(0xFFF59E0B),
                    ),
                    _buildActivityItem(
                      icon: Icons.person_add,
                      title: 'New partner onboarded',
                      time: '1 hour ago',
                      color: const Color(0xFF3B82F6),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.w,
          height: 12.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String time,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
