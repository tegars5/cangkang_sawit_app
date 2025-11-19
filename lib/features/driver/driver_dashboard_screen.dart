import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/gps_service.dart';
import '../../shared/repositories/location_repository.dart';
import '../../shared/models/driver_location.dart';
import '../../core/repositories/shipment_repository.dart';
import '../../shared/models/shipment.dart';
import '../shipment/delivery_confirmation_screen.dart';

class DriverDashboardScreen extends ConsumerStatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  ConsumerState<DriverDashboardScreen> createState() =>
      _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends ConsumerState<DriverDashboardScreen> {
  final GpsService _gpsService = GpsService();
  final LocationRepository _locationRepository = LocationRepository();

  bool _isTrackingLocation = false;
  DriverLocation? _currentLocation;
  String? _trackingError;
  Timer? _locationTimer;

  // Real shipment data
  List<Shipment> _activeShipments = [];
  StreamSubscription<List<Shipment>>? _shipmentsSubscription;

  // Current user - replace with actual authentication
  final String _currentDriverId = 'driver_001';

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _initializeShipments();
  }

  Future<void> _initializeShipments() async {
    await _loadDriverShipments();
    _setupShipmentsSubscription();
  }

  Future<void> _loadDriverShipments() async {
    try {
      final shipments = await ShipmentRepository.getDriverShipments(
        _currentDriverId,
      );
      if (mounted) {
        setState(() {
          _activeShipments = shipments
              .where((s) => s.status == 'assigned' || s.status == 'picked_up')
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data pengiriman: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _setupShipmentsSubscription() {
    _shipmentsSubscription = ShipmentRepository.shipmentsStream.listen((
      allShipments,
    ) {
      if (mounted) {
        setState(() {
          _activeShipments = allShipments
              .where(
                (s) =>
                    s.driverId == _currentDriverId &&
                    (s.status == 'assigned' || s.status == 'picked_up'),
              )
              .toList();
        });
      }
    });
  }

  @override
  void dispose() {
    _gpsService.stopTracking();
    _locationTimer?.cancel();
    _shipmentsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      final position = await _gpsService.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentLocation = DriverLocation(
            id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
            driverId: 'current-driver', // Replace with actual driver ID
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy,
            speed: position.speed,
            bearing: position.heading,
            timestamp: DateTime.now(),
            createdAt: DateTime.now(),
            isActive: true,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _trackingError = 'Gagal mendapatkan lokasi: $e';
        });
      }
    }
  }

  void _toggleLocationTracking() async {
    if (_isTrackingLocation) {
      _stopLocationTracking();
    } else {
      _startLocationTracking();
    }
  }

  void _startLocationTracking() async {
    try {
      await _gpsService.startTracking(
        onLocationUpdate: _onLocationUpdate,
        intervalSeconds: 30,
      );

      // Also save location every 30 seconds
      _locationTimer = Timer.periodic(Duration(seconds: 30), (_) {
        if (_currentLocation != null) {
          _saveCurrentLocation();
        }
      });

      setState(() {
        _isTrackingLocation = true;
        _trackingError = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('GPS tracking dimulai'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _trackingError = 'Gagal memulai tracking: $e';
      });
    }
  }

  void _stopLocationTracking() {
    _gpsService.stopTracking();
    _locationTimer?.cancel();

    setState(() {
      _isTrackingLocation = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('GPS tracking dihentikan'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _onLocationUpdate(Position position) {
    setState(() {
      _currentLocation = DriverLocation(
        id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
        driverId: 'current-driver', // Replace with actual driver ID
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        speed: position.speed,
        bearing: position.heading,
        timestamp: DateTime.now(),
        createdAt: DateTime.now(),
        isActive: true,
      );
      _trackingError = null;
    });
  }

  Future<void> _saveCurrentLocation() async {
    if (_currentLocation == null) return;

    try {
      await _locationRepository.saveLocation(
        driverId: _currentLocation!.driverId,
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
        accuracy: _currentLocation!.accuracy,
        speed: _currentLocation!.speed,
        bearing: _currentLocation!.bearing,
        shipmentId: _activeShipments.isNotEmpty ? _activeShipments[0].id : null,
      );
    } catch (e) {
      print('Error saving location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isTrackingLocation ? Icons.gps_fixed : Icons.gps_off),
            onPressed: _toggleLocationTracking,
            tooltip: _isTrackingLocation ? 'Stop Tracking' : 'Start Tracking',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _initializeLocation,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              _buildStatusCard(),
              SizedBox(height: 16.h),

              // Current Location Card
              _buildLocationCard(),
              SizedBox(height: 16.h),

              // Active Shipments
              _buildActiveShipments(),
              SizedBox(height: 16.h),

              // Quick Actions
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isTrackingLocation
                      ? Icons.online_prediction
                      : Icons.offline_pin,
                  color: _isTrackingLocation ? Colors.green : Colors.grey,
                ),
                SizedBox(width: 8.w),
                Text(
                  _isTrackingLocation ? 'Online - Tracking Active' : 'Offline',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: _isTrackingLocation ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            if (_trackingError != null)
              Text(
                _trackingError!,
                style: TextStyle(color: Colors.red, fontSize: 14.sp),
              ),
            if (_activeShipments.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                'Active Deliveries: ${_activeShipments.length}',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.my_location, color: Theme.of(context).primaryColor),
                SizedBox(width: 8.w),
                Text(
                  'Current Location',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            if (_currentLocation != null) ...[
              _buildLocationDetail(
                'Coordinates',
                _currentLocation!.formattedCoordinates,
              ),
              _buildLocationDetail(
                'Accuracy',
                _currentLocation!.formattedAccuracy,
              ),
              _buildLocationDetail('Speed', _currentLocation!.formattedSpeed),
              _buildLocationDetail(
                'Last Update',
                _currentLocation!.formattedDateTime,
              ),
            ] else
              Text(
                'No location data available',
                style: TextStyle(color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveShipments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Shipments',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        if (_activeShipments.isEmpty)
          Card(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 48.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'No active shipments',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...(_activeShipments
              .map((shipment) => _buildShipmentCard(shipment))
              .toList()),
      ],
    );
  }

  Widget _buildShipmentCard(Shipment shipment) {
    Color statusColor = Colors.blue;
    String statusText = 'Unknown';

    switch (shipment.status) {
      case 'assigned':
        statusColor = Colors.orange;
        statusText = 'Ditugaskan';
        break;
      case 'picked_up':
        statusColor = Colors.blue;
        statusText = 'Dalam Perjalanan';
        break;
      case 'delivered':
        statusColor = Colors.green;
        statusText = 'Terkirim';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'Dibatalkan';
        break;
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${shipment.order?.id ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontSize: 12.sp),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'No. Surat Jalan: ${shipment.deliveryNoteNumber}',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4.h),
            if (shipment.order?.customerName != null) ...[
              Text(
                'Pelanggan: ${shipment.order!.customerName}',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
              ),
              SizedBox(height: 4.h),
            ],
            Text(
              'Tujuan: ${shipment.destinationAddress}',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (shipment.pickupDate != null) ...[
              SizedBox(height: 4.h),
              Text(
                'Tanggal Pickup: ${shipment.formattedPickupDate}',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
            ],
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showShipmentDetails(shipment),
                    icon: Icon(Icons.info_outline, size: 16.sp),
                    label: Text('Detail'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.grey[700],
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                if (shipment.canStart)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _startShipment(shipment),
                      icon: Icon(Icons.play_arrow, size: 16.sp),
                      label: Text('Mulai'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  )
                else if (shipment.inProgress)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _completeDelivery(shipment),
                      icon: Icon(Icons.check_circle_outline, size: 16.sp),
                      label: Text('Selesai'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              'Emergency',
              Icons.emergency,
              Colors.red,
              () => _showEmergencyDialog(),
            ),
            _buildActionCard(
              'Report Issue',
              Icons.report_problem,
              Colors.orange,
              () => _showReportDialog(),
            ),
            _buildActionCard(
              'Call Support',
              Icons.phone,
              Colors.green,
              () => _callSupport(),
            ),
            _buildActionCard(
              'Navigation',
              Icons.navigation,
              Colors.blue,
              () => _openNavigation(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32.sp, color: color),
              SizedBox(height: 8.h),
              Text(
                title,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startShipment(Shipment shipment) async {
    try {
      await ShipmentRepository.startShipment(shipment.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengiriman dimulai'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memulai pengiriman: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeDelivery(Shipment shipment) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DeliveryConfirmationScreen(shipment: shipment),
      ),
    );

    if (result == true) {
      // Refresh shipments after successful delivery
      _loadDriverShipments();
    }
  }

  void _showShipmentDetails(Shipment shipment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Pengiriman'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID Pengiriman:', shipment.id),
              _buildDetailRow('No. Surat Jalan:', shipment.deliveryNoteNumber),
              if (shipment.order?.customerName != null)
                _buildDetailRow('Pelanggan:', shipment.order!.customerName),
              _buildDetailRow('Alamat Tujuan:', shipment.destinationAddress),
              _buildDetailRow('Status:', _getStatusText(shipment.status)),
              if (shipment.pickupDate != null)
                _buildDetailRow(
                  'Tanggal Pickup:',
                  shipment.formattedPickupDate,
                ),
              if (shipment.deliveryDate != null)
                _buildDetailRow(
                  'Tanggal Kirim:',
                  shipment.formattedDeliveryDate,
                ),
              if (shipment.notes?.isNotEmpty == true)
                _buildDetailRow('Catatan:', shipment.notes!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value ?? '-', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'assigned':
        return 'Ditugaskan';
      case 'picked_up':
        return 'Dalam Perjalanan';
      case 'delivered':
        return 'Terkirim';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Emergency'),
        content: Text('Contact emergency services?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement emergency call
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Call 112'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Issue'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Describe the issue...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Issue reported successfully')),
              );
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _callSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.phone, color: Colors.green),
            SizedBox(width: 8.w),
            Text('Hubungi Support'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih metode kontak:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: Icon(Icons.phone, color: Colors.green),
              title: Text('Call Center'),
              subtitle: Text('+62-21-1234-5678'),
              onTap: () {
                Navigator.pop(context);
                _makePhoneCall('+622112345678');
              },
            ),
            ListTile(
              leading: Icon(Icons.support_agent, color: Colors.blue),
              title: Text('Emergency Hotline'),
              subtitle: Text('+62-811-9999-8888'),
              onTap: () {
                Navigator.pop(context);
                _makePhoneCall('+6281199998888');
              },
            ),
            ListTile(
              leading: Icon(Icons.email, color: Colors.orange),
              title: Text('Email Support'),
              subtitle: Text('support@fujiyama.com'),
              onTap: () {
                Navigator.pop(context);
                _sendEmail('support@fujiyama.com');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tidak dapat membuka aplikasi telepon'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _sendEmail(String email) async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: email,
        query: 'subject=Bantuan Driver&body=Halo, saya membutuhkan bantuan...',
      );
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tidak dapat membuka aplikasi email'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _openNavigation() {
    // Cek apakah ada shipment aktif
    if (_activeShipments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak ada pengiriman aktif'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Get active shipment dengan destination
    Shipment? activeShipment;
    try {
      activeShipment = _activeShipments.firstWhere(
        (s) => s.status == 'picked_up',
      );
    } catch (e) {
      // Jika tidak ada yang picked_up, ambil yang pertama
      activeShipment = _activeShipments.first;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.navigation, color: Colors.blue),
            SizedBox(width: 8.w),
            Text('Navigasi'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tujuan:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Text(activeShipment!.destinationAddress ?? 'Alamat tidak tersedia'),
            SizedBox(height: 16.h),
            Text(
              'Pilih aplikasi navigasi:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            ListTile(
              leading: Icon(Icons.map, color: Colors.blue),
              title: Text('Google Maps'),
              onTap: () {
                Navigator.pop(context);
                _launchGoogleMaps(activeShipment!.destinationAddress);
              },
            ),
            ListTile(
              leading: Icon(Icons.navigation, color: Colors.green),
              title: Text('Waze'),
              onTap: () {
                Navigator.pop(context);
                _launchWaze(activeShipment!.destinationAddress);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchGoogleMaps(String? address) async {
    if (address == null || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alamat tujuan tidak tersedia'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final encodedAddress = Uri.encodeComponent(address);
      final Uri mapsUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
      );

      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tidak dapat membuka Google Maps'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _launchWaze(String? address) async {
    if (address == null || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alamat tujuan tidak tersedia'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final encodedAddress = Uri.encodeComponent(address);
      final Uri wazeUri = Uri.parse('https://waze.com/ul?q=$encodedAddress');

      if (await canLaunchUrl(wazeUri)) {
        await launchUrl(wazeUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback ke Google Maps jika Waze tidak tersedia
        _launchGoogleMaps(address);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
