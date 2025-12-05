import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/repositories/auth_repository.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../core/errors/app_exception.dart';

/// Registration state
class RegistrationState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const RegistrationState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  RegistrationState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return RegistrationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// Registration controller using Notifier (Riverpod 2.x)
class RegistrationController extends Notifier<RegistrationState> {
  @override
  RegistrationState build() => const RegistrationState();

  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  /// Register new user
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String role, // 'Mitra Bisnis' or 'Logistik'
    String? companyName,
    String? jobTitle,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Map role UI to database role ID
      int roleId;

      if (role == 'Mitra Bisnis') {
        roleId = 2;
      } else if (role == 'Logistik') {
        roleId = 3;
      } else {
        roleId = 2; // Default to mitra
      }

      // Use repository to sign up
      final result = await _authRepository.signUp(
        email: email,
        password: password,
        namaLengkap: fullName,
        roleId: roleId,
        telepon: phone,
      );

      result.when(
        success: (authResponse) async {
          // If Mitra Bisnis, update profile with additional data
          if (role == 'Mitra Bisnis' && authResponse.user != null) {
            try {
              // Update profile with company info
              await _updateMitraProfile(
                userId: authResponse.user!.id,
                companyName: companyName,
                jobTitle: jobTitle,
                phone: phone,
                address: address,
                latitude: latitude,
                longitude: longitude,
              );
            } catch (e) {
              // Profile update failed, but user is created
              print('Warning: Failed to update mitra profile: $e');
            }
          }

          state = state.copyWith(isLoading: false, isSuccess: true);
        },
        failure: (exception) {
          String errorMessage = 'Registrasi gagal';
          if (exception is AppException) {
            errorMessage = exception.message;
          }
          state = state.copyWith(isLoading: false, error: errorMessage);
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Terjadi kesalahan: $e');
    }
  }

  /// Update mitra profile with additional data
  Future<void> _updateMitraProfile({
    required String userId,
    String? companyName,
    String? jobTitle,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    final updates = <String, dynamic>{};

    if (companyName != null) updates['company_name'] = companyName;
    if (jobTitle != null) updates['job_title'] = jobTitle;
    if (phone != null) updates['phone'] = phone;
    if (address != null) updates['address'] = address;
    if (latitude != null) updates['latitude'] = latitude;
    if (longitude != null) updates['longitude'] = longitude;

    if (updates.isNotEmpty) {
      await ref.read(authRepositoryProvider).updateProfile(userId, updates);
    }
  }

  /// Reset state
  void reset() {
    state = const RegistrationState();
  }
}

/// Registration controller provider
final registrationControllerProvider =
    NotifierProvider<RegistrationController, RegistrationState>(() {
      return RegistrationController();
    });
