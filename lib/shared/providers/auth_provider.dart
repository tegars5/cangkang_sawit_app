import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../repositories/auth_repository.dart';
import '../../core/utils/result.dart';
import '../../core/errors/app_exception.dart';

/// Auth state model
class AuthState {
  final User? user;
  final UserProfile? profile;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.profile,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    UserProfile? profile,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => user != null && profile != null;
  bool get isAdmin => profile?.isAdmin ?? false;
  bool get isMitraBisnis => profile?.isMitraBisnis ?? false;
  bool get isDriver => profile?.isDriver ?? false;
}

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  // Listen to auth state changes
  final supabase = Supabase.instance.client;

  // Watch auth state stream to auto-refresh
  ref.listen(authStateStreamProvider, (previous, next) {
    // Invalidate self when auth changes
    ref.invalidateSelf();
  });

  return supabase.auth.currentUser;
});

/// Auth state stream provider to watch for changes
final authStateStreamProvider = StreamProvider<AuthState>((ref) {
  final supabase = Supabase.instance.client;

  return supabase.auth.onAuthStateChange.map((data) {
    return AuthState(user: data.session?.user, isLoading: false);
  });
});

/// Current user profile provider
final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final authRepository = ref.watch(authRepositoryProvider);
  final result = await authRepository.getUserProfile();

  // Handle Result type
  return result.when(
    success: (profile) => profile,
    failure: (exception) {
      // Log error but return null instead of throwing
      if (exception is AppException) {
        print('Error getting user profile: ${exception.message}');
      } else {
        print('Error getting user profile: $exception');
      }
      return null;
    },
  );
});

/// Auth state provider
final authStateProvider = Provider<AuthState>((ref) {
  final user = ref.watch(currentUserProvider);
  final profileAsync = ref.watch(currentUserProfileProvider);

  return profileAsync.when(
    data: (profile) => AuthState(user: user, profile: profile),
    loading: () => AuthState(user: user, isLoading: true),
    error: (error, _) => AuthState(user: user, error: error.toString()),
  );
});

/// Login method provider
final loginMethodProvider =
    Provider<Future<Result<User>> Function(String, String)>((ref) {
      final authRepository = ref.watch(authRepositoryProvider);
      return (email, password) async {
        final result = await authRepository.signIn(
          email: email,
          password: password,
        );

        // Map Result<AuthResponse> to Result<User>
        return result.map((authResponse) => authResponse.user!);
      };
    });

/// Register method provider
final registerMethodProvider =
    Provider<Future<Result<User>> Function(String, String, String, String)>((
      ref,
    ) {
      final authRepository = ref.watch(authRepositoryProvider);
      return (email, password, fullName, role) async {
        final result = await authRepository.signUp(
          email: email,
          password: password,
          namaLengkap: fullName,
          roleId: role == 'admin'
              ? 1
              : role == 'mitra'
              ? 2
              : 3,
        );

        // Map Result<AuthResponse> to Result<User>
        return result.map((authResponse) => authResponse.user!);
      };
    });

/// Logout method provider
final logoutMethodProvider = Provider<Future<Result<void>> Function()>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return () async {
    return await authRepository.signOut();
  };
});
