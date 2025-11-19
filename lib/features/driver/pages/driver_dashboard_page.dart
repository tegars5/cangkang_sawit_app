import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/common/common_widgets.dart';
import '../../../services/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Driver Dashboard Page - Overview and quick actions
class DriverDashboardPage extends ConsumerStatefulWidget {
  const DriverDashboardPage({super.key});

  @override
  ConsumerState<DriverDashboardPage> createState() =>
      _DriverDashboardPageState();
}

class _DriverDashboardPageState extends ConsumerState<DriverDashboardPage> {
  Map<String, dynamic>? dashboardStats;
  Map<String, dynamic>? currentUser;
  List<Map<String, dynamic>> todayTasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() => isLoading = true);

      // Get current user
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Get user profile
        final profileResponse = await Supabase.instance.client
            .from('profiles')
            .select('*')
            .eq('id', user.id)
            .single();

        currentUser = profileResponse;

        // Get driver dashboard stats
        dashboardStats = await DatabaseService.getDriverDashboardStats(user.id);

        // Get today's tasks
        todayTasks = await DatabaseService.getTasks(
          driverId: user.id,
          date: DateTime.now(),
          limit: 10,
        );
      }

      setState(() => isLoading = false);
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning!',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
            Text(
              currentUser?['full_name'] ?? 'Driver',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
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
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Driver Status Card
              InfoCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12.w,
                          height: 12.h,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Online & Available',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: true,
                          onChanged: (value) {
                            // TODO: Toggle online status
                          },
                          activeColor: const Color(0xFF1B5E20),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusItem(
                            'Vehicle',
                            currentUser?['vehicle_plate'] ?? 'Not Set',
                            Icons.local_shipping_outlined,
                          ),
                        ),
                        Expanded(
                          child: _buildStatusItem(
                            'Location',
                            currentUser?['city'] ?? 'Unknown',
                            Icons.location_on_outlined,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Today's Summary
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Tasks Today',
                      '${dashboardStats?['assigned_tasks'] ?? 0}',
                      Icons.assignment_outlined,
                      const Color(0xFF1976D2),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildSummaryCard(
                      'Completed',
                      '${dashboardStats?['completed_today'] ?? 0}',
                      Icons.check_circle_outline,
                      const Color(0xFF388E3C),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Distance',
                      '${dashboardStats?['total_distance']?.toStringAsFixed(0) ?? '0'} km',
                      Icons.route_outlined,
                      const Color(0xFF7B1FA2),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildSummaryCard(
                      'Deliveries',
                      '${dashboardStats?['active_deliveries'] ?? 0}',
                      Icons.monetization_on_outlined,
                      const Color(0xFFE65100),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Current Task
              Text(
                'Current Task',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12.h),

              todayTasks.isNotEmpty
                  ? TaskCard(
                      taskNumber: todayTasks.first['task_number'] ?? 'No Task',
                      customerName:
                          todayTasks.first['customer_name'] ?? 'No Customer',
                      destination: todayTasks.first['address'] ?? 'No Address',
                      pickupTime: _formatTime(
                        todayTasks.first['scheduled_date'],
                      ),
                      status: todayTasks.first['status'] ?? 'Scheduled',
                      progress: _getTaskProgress(todayTasks.first['status']),
                      onTap: () {
                        // TODO: Navigate to task details
                      },
                    )
                  : InfoCard(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.grey[600],
                              size: 24.sp,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'No tasks scheduled for today',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

              SizedBox(height: 20.h),

              // Quick Actions
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12.h),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      'Start Trip',
                      Icons.play_arrow,
                      const Color(0xFF1B5E20),
                      () {
                        // TODO: Start trip
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildQuickActionCard(
                      'Report Issue',
                      Icons.report_problem_outlined,
                      const Color(0xFFD32F2F),
                      () {
                        // TODO: Report issue
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      'Emergency',
                      Icons.emergency,
                      const Color(0xFFFF5722),
                      () {
                        // TODO: Emergency call
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildQuickActionCard(
                      'Call Support',
                      Icons.support_agent,
                      const Color(0xFF1976D2),
                      () {
                        // TODO: Call support
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Recent Activities
              Text(
                'Recent Activities',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12.h),

              InfoCard(
                child: Column(
                  children: [
                    _buildActivityItem(
                      'Delivery Completed',
                      'SH-202405-00454 - UD Makmur Mandiri',
                      '2 hours ago',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildActivityItem(
                      'Task Started',
                      'SH-202405-00456 - PT Sawit Jaya',
                      '4 hours ago',
                      Icons.play_arrow,
                      const Color(0xFF1B5E20),
                    ),
                    _buildActivityItem(
                      'Vehicle Inspection',
                      'Pre-trip safety check completed',
                      '8 hours ago',
                      Icons.verified,
                      Colors.blue,
                      isLast: true,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24.sp, color: const Color(0xFF1B5E20)),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32.sp),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
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
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
          ),
        ],
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

  double _getTaskProgress(String? status) {
    switch (status) {
      case 'Scheduled':
        return 0.0;
      case 'In Progress':
        return 0.65;
      case 'Completed':
        return 1.0;
      default:
        return 0.0;
    }
  }
}
