import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/models/shipment_timeline.dart';

/// Widget to display shipment timeline in vertical format
class TrackingTimelineWidget extends StatelessWidget {
  final List<ShipmentTimeline> timeline;
  final String currentStatus;

  const TrackingTimelineWidget({
    super.key,
    required this.timeline,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    if (timeline.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(24.w),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.timeline, size: 48.sp, color: Colors.grey[400]),
              SizedBox(height: 12.h),
              Text(
                'Belum ada riwayat pengiriman',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      itemCount: timeline.length,
      itemBuilder: (context, index) {
        final item = timeline[index];
        final isLast = index == timeline.length - 1;
        final isFirst = index == 0;

        return _buildTimelineItem(item, isLast: isLast, isFirst: isFirst);
      },
    );
  }

  Widget _buildTimelineItem(
    ShipmentTimeline item, {
    required bool isLast,
    required bool isFirst,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              // Icon
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: Color(item.statusColor).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(item.statusColor), width: 2),
                ),
                child: Center(
                  child: Text(
                    item.statusIcon,
                    style: TextStyle(fontSize: 20.sp),
                  ),
                ),
              ),
              // Line
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    color: Colors.grey[300],
                  ),
                ),
            ],
          ),

          SizedBox(width: 16.w),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status and time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.message,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: isFirst
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isFirst ? Colors.black87 : Colors.black54,
                          ),
                        ),
                      ),
                      Text(
                        item.formattedTime,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  // Date
                  Text(
                    item.formattedDate,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),

                  // Location if available
                  if (item.locationLat != null && item.locationLng != null) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14.sp,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            '${item.locationLat!.toStringAsFixed(6)}, ${item.locationLng!.toStringAsFixed(6)}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
