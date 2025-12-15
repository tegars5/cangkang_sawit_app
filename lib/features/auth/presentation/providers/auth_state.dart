import 'package:equatable/equatable.dart';
import '../../../../shared/models/user_profile.dart';

/// Presentation layer authentication state
class AuthState extends Equatable {
  final UserProfile? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Initial state
  const AuthState.initial()
    : user = null,
      isAuthenticated = false,
      isLoading = false,
      errorMessage = null;

  /// Loading state
  const AuthState.loading()
    : user = null,
      isAuthenticated = false,
      isLoading = true,
      errorMessage = null;

  /// Authenticated state
  const AuthState.authenticated(UserProfile this.user)
    : isAuthenticated = true,
      isLoading = false,
      errorMessage = null;

  /// Unauthenticated state
  const AuthState.unauthenticated()
    : user = null,
      isAuthenticated = false,
      isLoading = false,
      errorMessage = null;

  /// Error state
  const AuthState.error(String this.errorMessage)
    : user = null,
      isAuthenticated = false,
      isLoading = false;

  AuthState copyWith({
    UserProfile? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [user, isAuthenticated, isLoading, errorMessage];

  @override
  String toString() =>
      'AuthState(isAuthenticated: $isAuthenticated, isLoading: $isLoading, user: ${user?.email})';
}
