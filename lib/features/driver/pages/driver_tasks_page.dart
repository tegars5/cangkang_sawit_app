import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/common/common_widgets.dart';
import '../../../services/database_service.dart';
import 'task_detail_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Driver Tasks Page - Active and scheduled tasks
class DriverTasksPage extends ConsumerStatefulWidget {
  const DriverTasksPage({super.key});

  @override
  ConsumerState<DriverTasksPage> createState() => _DriverTasksPageState();
}

class _DriverTasksPageState extends ConsumerState<DriverTasksPage> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;

  final List<String> _tabs = ['Active', 'Scheduled', 'Completed'];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      setState(() => _isLoading = true);

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Get tasks for current driver
        final tasks = await DatabaseService.getTasks(
          driverId: user.id,
          limit: 50,
        );

        setState(() {
          _tasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading tasks: $e');
      // Use fallback dummy data
      setState(() {
        _tasks = [
          {
            'task_number': 'TSK-20241118-001',
            'title': 'Pickup from PT Sawit Jaya',
            'status': 'Scheduled',
            'priority': 'high',
            'scheduled_date': DateTime.now().toIso8601String(),
            'address': 'Medan Industrial Area',
            'customer_name': 'PT Sawit Jaya',
            'progress': 0.0,
          },
        ];
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
          'My Tasks',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Show task calendar
            },
            icon: Icon(
              Icons.calendar_today_outlined,
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
            hintText: 'Search by task # or customer',
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

          // Tasks List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadTasks,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: _getFilteredTasks().length,
                      itemBuilder: (context, index) {
                        final task = _getFilteredTasks()[index];
                        return TaskCard(
                          taskNumber: task['task_number'] ?? 'No Task Number',
                          customerName:
                              task['customer_name'] ??
                              task['title'] ??
                              'No Customer',
                          destination: task['address'] ?? 'No Address',
                          pickupTime: _formatTime(task['scheduled_date']),
                          status: task['status'] ?? 'Unknown',
                          progress: _getTaskProgress(task['status']),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TaskDetailPage(taskData: task),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredTasks() {
    switch (_selectedTabIndex) {
      case 0: // Active
        return _tasks
            .where(
              (task) =>
                  task['status'] == 'In Progress' || task['status'] == 'Ready',
            )
            .toList();
      case 1: // Scheduled
        return _tasks.where((task) => task['status'] == 'Scheduled').toList();
      case 2: // Completed
        return _tasks.where((task) => task['status'] == 'Completed').toList();
      default:
        return _tasks;
    }
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
