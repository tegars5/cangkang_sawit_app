import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Immutable state model for registration form
/// Manages UI state separately from business logic
class RegistrationFormState {
  /// Current step in the stepper (0 or 1 for Mitra Bisnis)
  final int currentStep;

  /// Selected user role ('Mitra Bisnis' or 'driver')
  final String selectedRole;

  /// Selected location on map (default: Jakarta)
  final LatLng selectedLocation;

  /// Loading state for address auto-fill from current location
  final bool isLoadingAddress;

  const RegistrationFormState({
    this.currentStep = 0,
    this.selectedRole = 'Mitra Bisnis',
    this.selectedLocation = const LatLng(-6.2088, 106.8456),
    this.isLoadingAddress = false,
  });

  /// Create a copy with modified fields
  RegistrationFormState copyWith({
    int? currentStep,
    String? selectedRole,
    LatLng? selectedLocation,
    bool? isLoadingAddress,
  }) {
    return RegistrationFormState(
      currentStep: currentStep ?? this.currentStep,
      selectedRole: selectedRole ?? this.selectedRole,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      isLoadingAddress: isLoadingAddress ?? this.isLoadingAddress,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegistrationFormState &&
        other.currentStep == currentStep &&
        other.selectedRole == selectedRole &&
        other.selectedLocation == selectedLocation &&
        other.isLoadingAddress == isLoadingAddress;
  }

  @override
  int get hashCode {
    return Object.hash(
      currentStep,
      selectedRole,
      selectedLocation,
      isLoadingAddress,
    );
  }
}
