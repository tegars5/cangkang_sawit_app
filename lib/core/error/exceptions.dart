/// Base class for all exceptions in the application
/// Exceptions represent unexpected errors in the data layer
class ServerException implements Exception {
  final String message;

  const ServerException([this.message = 'Server exception occurred']);

  @override
  String toString() => 'ServerException: $message';
}

/// Cache exception - when local storage operations fail
class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Cache exception occurred']);

  @override
  String toString() => 'CacheException: $message';
}

/// Network exception - when network operations fail
class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'Network exception occurred']);

  @override
  String toString() => 'NetworkException: $message';
}

/// Validation exception - when data validation fails
class ValidationException implements Exception {
  final String message;

  const ValidationException([this.message = 'Validation exception occurred']);

  @override
  String toString() => 'ValidationException: $message';
}

/// Authentication exception - when auth operations fail
class AuthException implements Exception {
  final String message;

  const AuthException([this.message = 'Authentication exception occurred']);

  @override
  String toString() => 'AuthException: $message';
}

/// Not found exception - when resource is not found
class NotFoundException implements Exception {
  final String message;

  const NotFoundException([this.message = 'Resource not found']);

  @override
  String toString() => 'NotFoundException: $message';
}
