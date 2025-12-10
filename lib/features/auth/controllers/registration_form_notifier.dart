import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/registration_form_state.dart';

/// Notifier for managing registration form state
/// Centralizes all state mutations for better testability and performance
class RegistrationFormNotifier extends Notifier<RegistrationFormState> {
  @override
  RegistrationFormState build() => const RegistrationFormState();

  /// Move to next step in the stepper
  void nextStep() {
    if (state.currentStep < 1) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  /// Move to previous step in the stepper
  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  /// Set specific step (used for validation flow)
  void setCurrentStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  /// Change selected role and reset to first step
  void setRole(String role) {
    state = state.copyWith(
      selectedRole: role,
      currentStep: 0, // Reset step when role changes
    );
  }

  /// Update selected location from map
  void setLocation(LatLng location) {
    state = state.copyWith(selectedLocation: location);
  }

  /// Fill address from current device location
  /// Updates both location and address text field
  Future<String?> fillAddressFromCurrentLocation(
    TextEditingController addressController,
  ) async {
    // Set loading state
    state = state.copyWith(isLoadingAddress: true);

    try {
      // Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Izin lokasi ditolak';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Izin lokasi ditolak permanen. Silakan aktifkan di pengaturan.';
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update location state
      final newLocation = LatLng(position.latitude, position.longitude);
      state = state.copyWith(
        selectedLocation: newLocation,
        isLoadingAddress: false,
      );

      // Get address from coordinates
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        final address = _buildAddressString(place);

        // Update address controller
        addressController.text = address.isEmpty
            ? 'Alamat tidak ditemukan'
            : address;

        return null; // Success
      }

      return 'Alamat tidak ditemukan';
    } catch (e) {
      // Reset loading state on error
      state = state.copyWith(isLoadingAddress: false);
      return 'Gagal mendapatkan lokasi: $e';
    }
  }

  /// Build address string from placemark
  String _buildAddressString(Placemark place) {
    final parts = <String>[];

    if (place.street != null && place.street!.isNotEmpty) {
      parts.add(place.street!);
    }
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      parts.add(place.subLocality!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      parts.add(place.locality!);
    }
    if (place.administrativeArea != null &&
        place.administrativeArea!.isNotEmpty) {
      parts.add(place.administrativeArea!);
    }

    return parts.join(', ');
  }

  /// Reset form state to initial values
  void reset() {
    state = const RegistrationFormState();
  }
}

/// Provider for registration form state management
final registrationFormNotifierProvider =
    NotifierProvider<RegistrationFormNotifier, RegistrationFormState>(
      () => RegistrationFormNotifier(),
    );
