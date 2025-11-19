import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/common/common_widgets.dart';

/// Shipment Detail Page - Complete shipment tracking and management
class ShipmentDetailPage extends StatefulWidget {
  final Map<String, dynamic> shipmentData;

  const ShipmentDetailPage({super.key, required this.shipmentData});

  @override
  State<ShipmentDetailPage> createState() => _ShipmentDetailPageState();
}

class _ShipmentDetailPageState extends State<ShipmentDetailPage> {
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
          'Shipment Details',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Show live tracking
            },
            icon: Icon(Icons.gps_fixed, color: Colors.white, size: 24.sp),
          ),
          IconButton(
            onPressed: () {
              // TODO: Call driver
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
            // Shipment Header Card
            InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.shipmentData['shipmentNumber'],
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      StatusBadge(status: widget.shipmentData['status']),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Order: ${widget.shipmentData['orderNumber']}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    widget.shipmentData['customerName'],
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Progress Tracking (for In Transit)
            if (widget.shipmentData['status'] == 'In Transit') ...[
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
                            value: widget.shipmentData['progress'],
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF1B5E20),
                            ),
                            minHeight: 8.h,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          '${(widget.shipmentData['progress'] * 100).toInt()}%',
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
                      'Last Location: Tol Jakarta-Cikampek KM 45',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Updated: 2 minutes ago',
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

            // Driver & Vehicle Information
            InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Driver & Vehicle',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildDetailRow('Driver Name', widget.shipmentData['driver']),
                  _buildDetailRow('Phone', '+62 812-9876-5432'),
                  _buildDetailRow(
                    'Vehicle Number',
                    widget.shipmentData['vehicle'],
                  ),
                  _buildDetailRow('Vehicle Type', 'Truck Container 20ft'),
                  _buildDetailRow('Driver License', 'A - 1234567890'),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Shipment Information
            InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shipment Information',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildDetailRow('Product Type', 'Palm Kernel Shell'),
                  _buildDetailRow('Quantity', widget.shipmentData['quantity']),
                  _buildDetailRow('Origin', 'Warehouse A - Medan'),
                  _buildDetailRow(
                    'Destination',
                    widget.shipmentData['destination'],
                  ),
                  _buildDetailRow(
                    'Scheduled Date',
                    widget.shipmentData['scheduledDate'],
                  ),
                  _buildDetailRow('Estimated Arrival', '26 May 2024, 14:00'),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Delivery Timeline
            InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Timeline',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildTimelineItem(
                    'Shipment Prepared',
                    '25 May 2024, 08:00 AM',
                    true,
                  ),
                  _buildTimelineItem(
                    'Vehicle Loaded',
                    '25 May 2024, 10:30 AM',
                    true,
                  ),
                  _buildTimelineItem(
                    'Departed from Origin',
                    '25 May 2024, 11:00 AM',
                    true,
                  ),
                  _buildTimelineItem(
                    'In Transit',
                    '25 May 2024, 11:15 AM',
                    widget.shipmentData['status'] == 'In Transit' ||
                        widget.shipmentData['status'] == 'Delivered',
                  ),
                  _buildTimelineItem(
                    'Arrived at Destination',
                    widget.shipmentData['status'] == 'Delivered'
                        ? '26 May 2024, 14:30 PM'
                        : 'Pending',
                    widget.shipmentData['status'] == 'Delivered',
                  ),
                  _buildTimelineItem(
                    'Delivered',
                    widget.shipmentData['status'] == 'Delivered'
                        ? '26 May 2024, 15:00 PM'
                        : 'Pending',
                    widget.shipmentData['status'] == 'Delivered',
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Documents Section
            InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Documents',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildDocumentItem('Delivery Note', 'DN-202405-00456.pdf'),
                  _buildDocumentItem('Invoice', 'INV-202405-00123.pdf'),
                  _buildDocumentItem(
                    'Quality Certificate',
                    'QC-202405-00456.pdf',
                  ),
                  if (widget.shipmentData['status'] == 'Delivered')
                    _buildDocumentItem(
                      'Proof of Delivery',
                      'POD-202405-00456.pdf',
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

  Widget _buildTimelineItem(String title, String time, bool isCompleted) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.h,
            decoration: BoxDecoration(
              color: isCompleted ? const Color(0xFF1B5E20) : Colors.grey[300],
              shape: BoxShape.circle,
            ),
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
                    color: isCompleted ? Colors.black87 : Colors.grey[600],
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  time,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String title, String filename) {
    return GestureDetector(
      onTap: () {
        // TODO: Open document
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(
              Icons.description_outlined,
              size: 20.sp,
              color: const Color(0xFF1B5E20),
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
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    filename,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.download_outlined, size: 20.sp, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget? _buildActionButtons() {
    if (widget.shipmentData['status'] == 'Ready to Ship') {
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
                text: 'Edit Shipment',
                onPressed: () {
                  // TODO: Edit shipment
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: PrimaryButton(
                text: 'Start Shipment',
                onPressed: () {
                  _showStartShipmentDialog();
                },
              ),
            ),
          ],
        ),
      );
    }
    return null;
  }

  void _showStartShipmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Shipment'),
        content: const Text(
          'Are you sure you want to start this shipment? The driver will be notified and tracking will begin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement start shipment logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Shipment started successfully'),
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
}
