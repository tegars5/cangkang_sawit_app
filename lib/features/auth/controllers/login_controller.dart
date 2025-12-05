import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/repositories/auth_repository.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../core/errors/app_exception.dart';

/// Login state
class LoginState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final String? userId;
  final int? roleId;

  const LoginState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.userId,
    this.roleId,
  });

  LoginState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    String? userId,
    int? roleId,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
      userId: userId ?? this.userId,
      roleId: roleId ?? this.roleId,
    );
  }
}

/// Login controller using Notifier (Riverpod 2.x)
class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  /// Login user
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Use repository to sign in
      final result = await _authRepository.signIn(
        email: email,
        password: password,
      );

      await result.when(
        success: (authResponse) async {
          if (authResponse.user != null) {
            // Get user profile to determine role
            try {
              final profile = await _authRepository.getUserProfile();

              await profile.when(
                success: (userProfile) {
                  state = state.copyWith(
                    isLoading: false,
                    isSuccess: true,
                    userId: authResponse.user!.id,
                    roleId: userProfile.roleId,
                  );
                },
                failure: (exception) {
                  state = state.copyWith(
                    isLoading: false,
                    error: 'Gagal memuat profil pengguna',
                  );
                },
              );
            } catch (e) {
              state = state.copyWith(
                isLoading: false,
                error: 'Gagal memuat profil: $e',
              );
            }
          } else {
            state = state.copyWith(
              isLoading: false,
              error: 'Login gagal: User tidak ditemukan',
            );
          }
        },
        failure: (exception) {
          String errorMessage = 'Login gagal';
          if (exception is AuthException) {
            errorMessage = exception.message;
          }
          state = state.copyWith(isLoading: false, error: errorMessage);
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Terjadi kesalahan: $e');
    }
  }

  /// Reset state
  void reset() {
    state = const LoginState();
  }
}

/// Login controller provider
final loginControllerProvider = NotifierProvider<LoginController, LoginState>(
  () {
    return LoginController();
  },
);
