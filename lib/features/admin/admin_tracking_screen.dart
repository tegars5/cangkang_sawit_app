import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

import '../../shared/repositories/location_repository.dart';
import '../../shared/models/driver_location.dart';

class AdminTrackingScreen extends ConsumerStatefulWidget {
  const AdminTrackingScreen({super.key});

  @override
  ConsumerState<AdminTrackingScreen> createState() =>
      _AdminTrackingScreenState();
}

class _AdminTrackingScreenState extends ConsumerState<AdminTrackingScreen> {
  final LocationRepository _locationRepository = LocationRepository();

  List<DriverLocation> _activeDrivers = [];
  bool _isLoading = true;
  String? _error;
  StreamSubscription<List<DriverLocation>>? _locationSubscription;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeTracking() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load initial data
      await _loadActiveDrivers();

      // Start real-time subscription
      _startLocationSubscription();

      // Refresh data every 30 seconds as fallback
      _refreshTimer = Timer.periodic(Duration(seconds: 30), (_) {
        if (mounted) {
          _loadActiveDrivers();
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data tracking: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadActiveDrivers() async {
    try {
      final locations = await _locationRepository.getAllActiveLocations();
      setState(() {
        _activeDrivers = locations;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data driver: $e';
        _isLoading = false;
      });
    }
  }

  void _startLocationSubscription() {
    _locationSubscription = _locationRepository
        .subscribeToAllDriverLocations()
        .listen(
          (locations) {
            if (mounted) {
              setState(() {
                _activeDrivers = locations;
                _isLoading = false;
                _error = null;
              });
            }
          },
          onError: (error) {
            print('Location subscription error: $error');
            // Don't show error to user for subscription issues, just log it
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Tracking'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadActiveDrivers,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Icon(Icons.map),
            onPressed: () => _showMapView(),
            tooltip: 'Map View',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadActiveDrivers,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text('Loading driver locations...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(onPressed: _loadActiveDrivers, child: Text('Retry')),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Summary Card
        _buildSummaryCard(),

        // Driver List
        Expanded(
          child: _activeDrivers.isEmpty
              ? _buildEmptyState()
              : _buildDriverList(),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final onlineDrivers = _activeDrivers.where((d) => d.isRecent).length;
    final offlineDrivers = _activeDrivers.length - onlineDrivers;

    return Card(
      margin: EdgeInsets.all(16.w),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Driver Status Overview',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusItem('Online', onlineDrivers, Colors.green),
                _buildStatusItem('Offline', offlineDrivers, Colors.grey),
                _buildStatusItem('Total', _activeDrivers.length, Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 64.sp, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            'No active drivers found',
            style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 8.h),
          Text(
            'Drivers will appear here when they start GPS tracking',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: _activeDrivers.length,
      itemBuilder: (context, index) {
        final driver = _activeDrivers[index];
        return _buildDriverCard(driver);
      },
    );
  }

  Widget _buildDriverCard(DriverLocation driver) {
    final isOnline = driver.isRecent;
    final statusColor = isOnline ? Colors.green : Colors.grey;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      child: InkWell(
        onTap: () => _showDriverDetails(driver),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Driver Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.1),
                    child: Icon(
                      isOnline ? Icons.person : Icons.person_outline,
                      color: statusColor,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Driver ${driver.driverId}', // Replace with actual driver name
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8.w,
                              height: 8.h,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              isOnline ? 'Online' : 'Offline',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (driver.shipmentId != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Text(
                        'On Delivery',
                        style: TextStyle(color: Colors.blue, fontSize: 10.sp),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12.h),

              // Location Info
              Row(
                children: [
                  Icon(Icons.location_on, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      driver.formattedCoordinates,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),

              // Speed and Accuracy
              Row(
                children: [
                  Icon(Icons.speed, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 4.w),
                  Text(
                    driver.formattedSpeed,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(width: 16.w),
                  Icon(Icons.gps_fixed, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 4.w),
                  Text(
                    driver.formattedAccuracy,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(height: 4.h),

              // Last Update
              Row(
                children: [
                  Icon(Icons.access_time, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 4.w),
                  Text(
                    'Last update: ${driver.formattedTime}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDriverDetails(DriverLocation driver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Driver Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Driver ID', driver.driverId),
              _buildDetailRow('Coordinates', driver.formattedCoordinates),
              _buildDetailRow('Speed', driver.formattedSpeed),
              _buildDetailRow('Bearing', driver.formattedBearing),
              _buildDetailRow('Accuracy', driver.formattedAccuracy),
              _buildDetailRow('Last Update', driver.formattedDateTime),
              if (driver.shipmentId != null)
                _buildDetailRow('Shipment ID', driver.shipmentId!),
              _buildDetailRow('Status', driver.isRecent ? 'Online' : 'Offline'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showDriverHistory(driver);
            },
            child: Text('View History'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  void _showDriverHistory(DriverLocation driver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location History'),
        content: Container(
          width: double.maxFinite,
          height: 300.h,
          child: FutureBuilder<List<DriverLocation>>(
            future: _locationRepository.getLocationHistory(
              driverId: driver.driverId,
              limit: 20,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading history: ${snapshot.error}'),
                );
              }

              final history = snapshot.data ?? [];
              if (history.isEmpty) {
                return Center(child: Text('No location history found'));
              }

              return ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final location = history[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(Icons.location_on, size: 16.sp),
                    title: Text(
                      location.formattedCoordinates,
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    subtitle: Text(
                      location.formattedDateTime,
                      style: TextStyle(fontSize: 10.sp),
                    ),
                    trailing: Text(
                      location.formattedSpeed,
                      style: TextStyle(fontSize: 10.sp),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMapView() {
    // TODO: Implement map view with all driver locations
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Map view feature coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
