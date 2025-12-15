import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/user_profile.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';
import 'auth_state.dart';

/// StateNotifier for managing authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final Login _loginUseCase;
  final Register _registerUseCase;
  final Logout _logoutUseCase;
  final GetCurrentUser _getCurrentUserUseCase;

  AuthNotifier({
    required Login loginUseCase,
    required Register registerUseCase,
    required Logout logoutUseCase,
    required GetCurrentUser getCurrentUserUseCase,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _logoutUseCase = logoutUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       super(const AuthState.initial()) {
    // Check current user on initialization
    checkAuthStatus();
  }

  /// Check if user is already authenticated
  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();

    final result = await _getCurrentUserUseCase(NoParams());

    result.fold(
      (failure) {
        state = const AuthState.unauthenticated();
      },
      (user) {
        if (user != null) {
          state = AuthState.authenticated(user);
        } else {
          state = const AuthState.unauthenticated();
        }
      },
    );
  }

  /// Login with email and password
  Future<void> login({required String email, required String password}) async {
    state = const AuthState.loading();

    final result = await _loginUseCase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) {
        state = AuthState.error(failure.message);
      },
      (user) {
        state = AuthState.authenticated(user);
      },
    );
  }

  /// Register new user
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String role,
    Map<String, dynamic>? additionalData,
  }) async {
    state = const AuthState.loading();

    final result = await _registerUseCase(
      RegisterParams(
        email: email,
        password: password,
        name: name,
        role: role,
        additionalData: additionalData,
      ),
    );

    result.fold(
      (failure) {
        state = AuthState.error(failure.message);
      },
      (user) {
        state = AuthState.authenticated(user);
      },
    );
  }

  /// Logout current user
  Future<void> logout() async {
    state = const AuthState.loading();

    final result = await _logoutUseCase(NoParams());

    result.fold(
      (failure) {
        state = AuthState.error(failure.message);
      },
      (_) {
        state = const AuthState.unauthenticated();
      },
    );
  }

  /// Clear error message
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}

/// Provider for AuthNotifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier(
    loginUseCase: ref.watch(loginUseCaseProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    getCurrentUserUseCase: ref.watch(getCurrentUserUseCaseProvider),
  );
});

/// Convenience provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isAuthenticated;
});

/// Convenience provider to get current user
final currentUserProvider = Provider<UserProfile?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.user;
});
