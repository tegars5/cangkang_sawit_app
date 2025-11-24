import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../features/maps/screens/delivery_tracking_screen.dart';
import '../features/maps/widgets/google_map_widget.dart';

class GoogleMapsTestScreen extends StatefulWidget {
  const GoogleMapsTestScreen({super.key});

  @override
  State<GoogleMapsTestScreen> createState() => _GoogleMapsTestScreenState();
}

class _GoogleMapsTestScreenState extends State<GoogleMapsTestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Google Maps Test',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📍 Google Maps Integration',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'Fitur Google Maps sudah terintegrasi dengan aplikasi. Pastikan Anda sudah setup Google Maps API Key.',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 24.h),

            // Test Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openBasicMap,
                icon: const Icon(Icons.map),
                label: const Text('Test Basic Google Map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openDeliveryTracking,
                icon: const Icon(Icons.local_shipping),
                label: const Text('Test Delivery Tracking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // Setup Instructions
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                border: Border.all(color: Colors.amber[200]!),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.amber[700]),
                      SizedBox(width: 8.w),
                      Text(
                        'Setup Required',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Untuk menggunakan Google Maps:',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '1. Dapatkan Google Maps API Key dari Google Cloud Console',
                    style: TextStyle(fontSize: 11.sp),
                  ),
                  Text(
                    '2. Ganti "YOUR_GOOGLE_MAPS_API_KEY_HERE" di AndroidManifest.xml dan Info.plist',
                    style: TextStyle(fontSize: 11.sp),
                  ),
                  Text(
                    '3. Test di device fisik (bukan emulator)',
                    style: TextStyle(fontSize: 11.sp),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Lihat file GOOGLE_MAPS_SETUP.md untuk panduan lengkap.',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontStyle: FontStyle.italic,
                      color: Colors.amber[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openBasicMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text(
              'Basic Google Map',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
          ),
          body: const GoogleMapWidget(
            initialLat: -6.2088, // Jakarta
            initialLng: 106.8456,
            zoom: 15.0,
            showCurrentLocation: true,
            enableLocationTracking: true,
          ),
        ),
      ),
    );
  }

  void _openDeliveryTracking() {
    // Mock shipment data
    final mockShipmentData = {
      'status': 'In Transit',
      'driver_name': 'Budi Santoso',
      'delivery_address': 'Jl. Sudirman No. 123, Jakarta',
      'phone': '+62 812-3456-7890',
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryTrackingScreen(
          shipmentId: 'SHIP-123',
          shipmentNumber: 'CS-2024-001',
          shipmentData: mockShipmentData,
        ),
      ),
    );
  }
}
