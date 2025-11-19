import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/common/common_widgets.dart';

/// Task Detail Page - Complete task information and actions
class TaskDetailPage extends StatefulWidget {
  final Map<String, dynamic> taskData;

  const TaskDetailPage({super.key, required this.taskData});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
        ),
        title: Text(
          'Task Details',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Show navigation/maps
            },
            icon: Icon(
              Icons.navigation_outlined,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Call customer
            },
            icon: Icon(Icons.phone, color: Colors.white, size: 24.sp),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Header Card
            InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.taskData['taskNumber'],
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      StatusBadge(status: widget.taskData['status']),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Order: ${widget.taskData['orderNumber']}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    widget.taskData['customerName'],
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Progress (for active tasks)
            if (widget.taskData['status'] == 'In Progress') ...[
              InfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Progress',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: widget.taskData['progress'],
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF1B5E20),
                            ),
                            minHeight: 8.h,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          '${(widget.taskData['progress'] * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: const Color(0xFF1B5E20),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Current Location: Tol Jakarta-Cikampek KM 25',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'ETA: ${widget.taskData['estimatedDelivery']}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],

            // Pickup Information
            InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pickup Information',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildDetailRow(
                    'Location',
                    widget.taskData['pickupLocation'],
                  ),
                  _buildDetailRow(
                    'Scheduled Time',
                    widget.taskData['pickupTime'],
                  ),
                  _buildDetailRow('Product Type', 'Palm Kernel Shell'),
                  _buildDetailRow('Quantity', widget.taskData['quantity']),
                  _buildDetailRow('Weight Check', 'Required'),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Delivery Information
            InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Information',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildDetailRow(
                    'Destination',
                    widget.taskData['destination'],
                  ),
                  _buildDetailRow('Customer', widget.taskData['customerName']),
                  _buildDetailRow('Contact Person', 'Budi Santoso'),
                  _buildDetailRow('Phone', '+62 812-3456-7890'),
                  _buildDetailRow(
                    'Estimated Time',
                    widget.taskData['estimatedDelivery'],
                  ),
                  _buildDetailRow('Distance', widget.taskData['distance']),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Special Instructions
            InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Special Instructions',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_outlined,
                              color: Colors.orange,
                              size: 16.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Important Notes:',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange[800],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '• Photo proof required for delivery\n• Check moisture content before loading\n• Customer requires signature upon delivery\n• Report any quality issues immediately',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.orange[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildActionButtons() {
    String status = widget.taskData['status'];

    if (status == 'Scheduled') {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: PrimaryButton(
          text: 'Start Task',
          onPressed: () {
            _showStartTaskDialog();
          },
        ),
      );
    } else if (status == 'In Progress') {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: 'Report Issue',
                onPressed: () {
                  _showReportIssueDialog();
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: PrimaryButton(
                text: 'Complete Delivery',
                onPressed: () {
                  _showCompleteDeliveryDialog();
                },
              ),
            ),
          ],
        ),
      );
    }
    return null;
  }

  void _showStartTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Task'),
        content: const Text(
          'Are you ready to start this delivery task? Make sure you have completed the pre-trip inspection.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement start task logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Task started successfully'),
                  backgroundColor: Color(0xFF1B5E20),
                ),
              );
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _showCompleteDeliveryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Delivery'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please confirm delivery completion:'),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(value: false, onChanged: (value) {}),
                const Expanded(child: Text('Photo proof uploaded')),
              ],
            ),
            Row(
              children: [
                Checkbox(value: false, onChanged: (value) {}),
                const Expanded(child: Text('Customer signature obtained')),
              ],
            ),
            Row(
              children: [
                Checkbox(value: false, onChanged: (value) {}),
                const Expanded(child: Text('Quality check completed')),
              ],
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
              // TODO: Implement complete delivery logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delivery completed successfully'),
                  backgroundColor: Color(0xFF1B5E20),
                ),
              );
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _showReportIssueDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please describe the issue:'),
            const SizedBox(height: 12),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Describe the issue...',
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
              // TODO: Implement report issue logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Issue reported successfully'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
}
