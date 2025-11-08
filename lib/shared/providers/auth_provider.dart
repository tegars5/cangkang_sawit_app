import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../repositories/auth_repository.dart';

/// Provider untuk AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider untuk current user (dari Supabase Auth)
final currentUserProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateStream.map((state) => state.session?.user);
});

/// Provider untuk user profile (dari database)
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  if (!authRepository.isLoggedIn) return null;

  return await authRepository.getUserProfile();
});

/// State class untuk auth
class AuthState {
  final bool isLoading;
  final User? user;
  final UserProfile? profile;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.profile,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    User? user,
    UserProfile? profile,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      profile: profile ?? this.profile,
      error: error ?? this.error,
    );
  }

  bool get isAuthenticated => user != null && profile != null;
  bool get isAdmin => profile?.isAdmin ?? false;
  bool get isMitraBisnis => profile?.isMitraBisnis ?? false;
  bool get isDriver => profile?.isDriver ?? false;
}

/// StateNotifier untuk mengelola auth state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState()) {
    _initializeAuth();
  }

  /// Inisialisasi auth state saat startup
  void _initializeAuth() async {
    state = state.copyWith(isLoading: true);

    try {
      final user = _authRepository.getCurrentUser();
      if (user != null) {
        final profile = await _authRepository.getUserProfile();
        state = state.copyWith(isLoading: false, user: user, profile: profile);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Sign in
  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authRepository.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final profile = await _authRepository.getUserProfile();
        state = state.copyWith(
          isLoading: false,
          user: response.user,
          profile: profile,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Sign up (untuk Admin membuat user baru)
  Future<void> signUp({
    required String email,
    required String password,
    required String namaLengkap,
    required int roleId,
    String? telepon,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authRepository.signUp(
        email: email,
        password: password,
        namaLengkap: namaLengkap,
        roleId: roleId,
        telepon: telepon,
      );

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authRepository.signOut();
      state = const AuthState(); // Reset state
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Update profile
  Future<void> updateProfile({
    required String namaLengkap,
    String? telepon,
  }) async {
    if (state.profile == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authRepository.updateUserProfile(
        namaLengkap: namaLengkap,
        telepon: telepon,
      );

      // Refresh profile
      final updatedProfile = await _authRepository.getUserProfile();
      state = state.copyWith(isLoading: false, profile: updatedProfile);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Change password
  Future<void> changePassword({required String newPassword}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authRepository.changePassword(newPassword: newPassword);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword({required String email}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authRepository.resetPassword(email: email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider untuk AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
