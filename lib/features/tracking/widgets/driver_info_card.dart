import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/models/models.dart';

/// Card widget to display driver information and current status
class DriverInfoCard extends StatelessWidget {
  final Shipment shipment;
  final DriverLocation? driverLocation;

  const DriverInfoCard({
    super.key,
    required this.shipment,
    this.driverLocation,
  });

  @override
  Widget build(BuildContext context) {
    final driver = shipment.driver;
    final hasLocation = driverLocation != null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // Driver avatar
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
                  backgroundImage: driver?.avatarUrl != null
                      ? NetworkImage(driver!.avatarUrl!)
                      : null,
                  child: driver?.avatarUrl == null
                      ? Icon(
                          Icons.person,
                          size: 32.sp,
                          color: const Color(0xFF2E7D32),
                        )
                      : null,
                ),

                SizedBox(width: 16.w),

                // Driver info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shipment.driverName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.local_shipping,
                            size: 14.sp,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            driver?.vehicleType ?? 'Kendaraan',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (driver?.vehiclePlate != null) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                driver!.vehiclePlate!,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Call button
                if (driver?.phone != null)
                  IconButton(
                    onPressed: () {
                      // TODO: Implement call functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Hubungi: ${driver!.phone}')),
                      );
                    },
                    icon: const Icon(Icons.phone),
                    color: const Color(0xFF2E7D32),
                  ),
              ],
            ),

            const Divider(height: 24),

            // Status info
            _buildInfoRow(
              icon: Icons.info_outline,
              label: 'Status',
              value: _getStatusText(shipment.status),
              valueColor: _getStatusColor(shipment.status),
            ),

            SizedBox(height: 12.h),

            _buildInfoRow(
              icon: Icons.receipt_long,
              label: 'No. Surat Jalan',
              value: shipment.deliveryNoteNumber,
            ),

            if (shipment.trackingNumber != null) ...[
              SizedBox(height: 12.h),
              _buildInfoRow(
                icon: Icons.qr_code,
                label: 'No. Tracking',
                value: shipment.trackingNumber!,
              ),
            ],

            // Location info
            if (hasLocation) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.speed, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 8.w),
                  Text(
                    'Kecepatan: ${driverLocation!.formattedSpeed}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                  ),
                  SizedBox(width: 16.w),
                  Icon(Icons.navigation, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 8.w),
                  Text(
                    'Arah: ${driverLocation!.directionText}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 8.w),
                  Text(
                    'Update terakhir: ${driverLocation!.timeAgo}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: driverLocation!.isRecent
                          ? const Color(0xFF2E7D32)
                          : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey[600]),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'in_transit':
        return 'Dalam Perjalanan';
      case 'arrived':
        return 'Sudah Tiba';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in_transit':
        return Colors.blue;
      case 'arrived':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
