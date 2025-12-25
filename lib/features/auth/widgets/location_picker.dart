import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

/// Location picker widget with Google Maps and auto-detect current location
class LocationPicker extends StatefulWidget {
  final LatLng initialLocation;
  final ValueChanged<LatLng> onLocationChanged;
  final ValueChanged<String>? onAddressChanged;

  const LocationPicker({
    super.key,
    required this.initialLocation,
    required this.onLocationChanged,
    this.onAddressChanged,
  });

  @override
  State<LocationPicker> createState() => LocationPickerState();
}

class LocationPickerState extends State<LocationPicker> {
  late LatLng _selectedLocation;
  late Set<Marker> _markers;
  GoogleMapController? _mapController;
  String _selectedAddress = 'Memuat alamat...';

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _updateMarker();
    _getAddressFromLatLng(_selectedLocation);
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  /// Public method to update location from parent widget
  void updateLocation(LatLng newLocation) {
    setState(() {
      _selectedLocation = newLocation;
      _updateMarker();
    });

    // Animate camera to new location
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newLocation, 15));

    // Get address for new location
    _getAddressFromLatLng(newLocation);

    // Notify parent
    widget.onLocationChanged(newLocation);
  }

  void _updateMarker() {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: _selectedLocation,
          infoWindow: InfoWindow(title: _selectedAddress),
        ),
      };
    });
  }

  Future<void> _getAddressFromLatLng(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '';

        if (place.street != null && place.street!.isNotEmpty) {
          address += place.street!;
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          address += address.isEmpty
              ? place.subLocality!
              : ', ${place.subLocality}';
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          address += address.isEmpty ? place.locality! : ', ${place.locality}';
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          address += address.isEmpty
              ? place.administrativeArea!
              : ', ${place.administrativeArea}';
        }
        if (place.country != null && place.country!.isNotEmpty) {
          address += address.isEmpty ? place.country! : ', ${place.country}';
        }

        setState(() {
          _selectedAddress = address.isEmpty
              ? 'Alamat tidak ditemukan'
              : address;
        });

        if (widget.onAddressChanged != null) {
          widget.onAddressChanged!(_selectedAddress);
        }

        _updateMarker();
      }
    } catch (e) {
      setState(() {
        _selectedAddress = 'Gagal mendapatkan alamat';
      });
    }
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _selectedAddress = 'Memuat alamat...';
      _updateMarker();
    });
    widget.onLocationChanged(location);
    _getAddressFromLatLng(location);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pilih Lokasi Perusahaan',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Map
        Container(
          height: 300.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          clipBehavior: Clip.antiAlias,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 15,
            ),
            markers: _markers,
            onTap: _onMapTap,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Tap pada peta untuk memilih lokasi perusahaan',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
