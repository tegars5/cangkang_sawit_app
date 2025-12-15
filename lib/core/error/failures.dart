import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
/// Failures represent expected errors in the domain layer
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Server failure - when API calls fail
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred'])
    : super(message);
}

/// Cache failure - when local storage fails
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred'])
    : super(message);
}

/// Network failure - when there's no internet connection
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection'])
    : super(message);
}

/// Validation failure - when input validation fails
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation error'])
    : super(message);
}

/// Authentication failure - when auth fails
class AuthFailure extends Failure {
  const AuthFailure([String message = 'Authentication failed'])
    : super(message);
}

/// Not found failure - when resource not found
class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Resource not found'])
    : super(message);
}

/// Permission failure - when user doesn't have access
class PermissionFailure extends Failure {
  const PermissionFailure([String message = 'Permission denied'])
    : super(message);
}

/// Unknown failure - for unexpected errors
class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'An unexpected error occurred'])
    : super(message);
}
