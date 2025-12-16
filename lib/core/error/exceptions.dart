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
/// Renamed to AppAuthException to avoid conflict with Supabase AuthException
class AppAuthException implements Exception {
  final String message;

  const AppAuthException([this.message = 'Authentication exception occurred']);

  @override
  String toString() => 'AppAuthException: $message';
}

/// Not found exception - when resource is not found
class NotFoundException implements Exception {
  final String message;

  const NotFoundException([this.message = 'Resource not found']);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Permission exception - when user doesn't have required permissions
class PermissionException implements Exception {
  final String message;

  const PermissionException([this.message = 'Permission denied']);

  @override
  String toString() => 'PermissionException: $message';
}

/// Unauthorized exception - when user is not authenticated
class UnauthorizedException implements Exception {
  final String message;

  const UnauthorizedException([this.message = 'Unauthorized access']);

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Conflict exception - when there's a data conflict (e.g., duplicate entry)
class ConflictException implements Exception {
  final String message;

  const ConflictException([this.message = 'Data conflict occurred']);

  @override
  String toString() => 'ConflictException: $message';
}

/// Timeout exception - when operation times out
class TimeoutException implements Exception {
  final String message;

  const TimeoutException([this.message = 'Operation timed out']);

  @override
  String toString() => 'TimeoutException: $message';
}

/// Bad request exception - when request data is invalid
class BadRequestException implements Exception {
  final String message;

  const BadRequestException([this.message = 'Bad request']);

  @override
  String toString() => 'BadRequestException: $message';
}

/// File upload exception - when file upload fails
class FileUploadException implements Exception {
  final String message;

  const FileUploadException([this.message = 'File upload failed']);

  @override
  String toString() => 'FileUploadException: $message';
}

/// Location exception - when location services fail
class LocationException implements Exception {
  final String message;

  const LocationException([this.message = 'Location service error']);

  @override
  String toString() => 'LocationException: $message';
}
