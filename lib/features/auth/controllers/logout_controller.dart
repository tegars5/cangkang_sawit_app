import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/repositories/auth_repository.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../core/errors/app_exception.dart';

/// Logout state
class LogoutState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const LogoutState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  LogoutState copyWith({bool? isLoading, String? error, bool? isSuccess}) {
    return LogoutState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// Logout controller using Notifier (Riverpod 2.x)
class LogoutController extends Notifier<LogoutState> {
  @override
  LogoutState build() => const LogoutState();

  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  /// Perform logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authRepository.signOut();

      result.when(
        success: (_) {
          state = state.copyWith(isLoading: false, isSuccess: true);
        },
        failure: (exception) {
          String errorMessage = 'Gagal logout';
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

  /// Reset state
  void reset() {
    state = const LogoutState();
  }
}

/// Logout controller provider
final logoutControllerProvider =
    NotifierProvider<LogoutController, LogoutState>(() {
      return LogoutController();
    });
