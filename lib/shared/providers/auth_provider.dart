import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../repositories/auth_repository.dart';

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
  return Supabase.instance.client.auth.currentUser;
});

/// Current user profile provider
final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final authRepository = ref.watch(authRepositoryProvider);
  return await authRepository.getUserProfile();
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
final loginMethodProvider = Provider<Future<User?> Function(String, String)>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return (email, password) async {
    final response = await authRepository.signIn(
      email: email,
      password: password,
    );
    return response.user;
  };
});

/// Register method provider
final registerMethodProvider =
    Provider<Future<User?> Function(String, String, String, String)>((ref) {
      final authRepository = ref.watch(authRepositoryProvider);
      return (email, password, fullName, role) async {
        final response = await authRepository.signUp(
          email: email,
          password: password,
          namaLengkap: fullName,
          roleId: role == 'admin'
              ? 1
              : role == 'mitra'
              ? 2
              : 3,
        );
        return response.user;
      };
    });

/// Logout method provider
final logoutMethodProvider = Provider<Future<void> Function()>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return () async {
    await authRepository.signOut();
  };
});
