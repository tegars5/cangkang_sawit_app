/// Base class untuk semua custom exceptions di aplikasi
/// Menyediakan struktur yang konsisten untuk error handling
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.details,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('$runtimeType: $message');
    if (code != null) buffer.write(' (code: $code)');
    if (details != null) buffer.write('\nDetails: $details');
    return buffer.toString();
  }

  /// User-friendly message untuk ditampilkan di UI
  String get userMessage => message;
}

/// Network/connectivity related exceptions
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.details,
    super.stackTrace,
  });

  /// Factory untuk no internet connection
  factory NetworkException.noConnection() {
    return const NetworkException(
      message: 'Tidak ada koneksi internet',
      code: 'NO_CONNECTION',
    );
  }

  /// Factory untuk timeout
  factory NetworkException.timeout() {
    return const NetworkException(
      message: 'Koneksi timeout. Silakan coba lagi',
      code: 'TIMEOUT',
    );
  }

  /// Factory untuk server unreachable
  factory NetworkException.serverUnreachable() {
    return const NetworkException(
      message: 'Server tidak dapat dijangkau',
      code: 'SERVER_UNREACHABLE',
    );
  }
}

/// Authentication related exceptions
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.details,
    super.stackTrace,
  });

  /// Factory untuk invalid credentials
  factory AuthException.invalidCredentials() {
    return const AuthException(
      message: 'Email atau password salah',
      code: 'INVALID_CREDENTIALS',
    );
  }

  /// Factory untuk session expired
  factory AuthException.sessionExpired() {
    return const AuthException(
      message: 'Sesi Anda telah berakhir. Silakan login kembali',
      code: 'SESSION_EXPIRED',
    );
  }

  /// Factory untuk unauthorized
  factory AuthException.unauthorized() {
    return const AuthException(
      message: 'Anda tidak memiliki akses',
      code: 'UNAUTHORIZED',
    );
  }

  /// Factory untuk user not found
  factory AuthException.userNotFound() {
    return const AuthException(
      message: 'Pengguna tidak ditemukan',
      code: 'USER_NOT_FOUND',
    );
  }

  /// Factory untuk email already exists
  factory AuthException.emailAlreadyExists() {
    return const AuthException(
      message: 'Email sudah terdaftar',
      code: 'EMAIL_ALREADY_EXISTS',
    );
  }

  /// Factory untuk weak password
  factory AuthException.weakPassword() {
    return const AuthException(
      message: 'Password terlalu lemah. Minimal 6 karakter',
      code: 'WEAK_PASSWORD',
    );
  }
}

/// Data validation related exceptions
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.details,
    super.stackTrace,
  });

  /// Factory untuk required field
  factory ValidationException.requiredField(String fieldName) {
    return ValidationException(
      message: '$fieldName tidak boleh kosong',
      code: 'REQUIRED_FIELD',
      details: fieldName,
    );
  }

  /// Factory untuk invalid email
  factory ValidationException.invalidEmail() {
    return const ValidationException(
      message: 'Format email tidak valid',
      code: 'INVALID_EMAIL',
    );
  }

  /// Factory untuk invalid format
  factory ValidationException.invalidFormat(String fieldName) {
    return ValidationException(
      message: 'Format $fieldName tidak valid',
      code: 'INVALID_FORMAT',
      details: fieldName,
    );
  }
}

/// File storage related exceptions
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.details,
    super.stackTrace,
  });

  /// Factory untuk upload failed
  factory StorageException.uploadFailed([String? reason]) {
    return StorageException(
      message: 'Gagal mengunggah file${reason != null ? ': $reason' : ''}',
      code: 'UPLOAD_FAILED',
      details: reason,
    );
  }

  /// Factory untuk file too large
  factory StorageException.fileTooLarge({int? maxSizeMB}) {
    return StorageException(
      message:
          'Ukuran file terlalu besar${maxSizeMB != null ? ' (maks ${maxSizeMB}MB)' : ''}',
      code: 'FILE_TOO_LARGE',
      details: maxSizeMB,
    );
  }

  /// Factory untuk invalid file type
  factory StorageException.invalidFileType({List<String>? allowedTypes}) {
    return StorageException(
      message:
          'Tipe file tidak didukung${allowedTypes != null ? '. Hanya ${allowedTypes.join(', ')}' : ''}',
      code: 'INVALID_FILE_TYPE',
      details: allowedTypes,
    );
  }

  /// Factory untuk file not found
  factory StorageException.fileNotFound() {
    return const StorageException(
      message: 'File tidak ditemukan',
      code: 'FILE_NOT_FOUND',
    );
  }
}

/// Database operation related exceptions
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.code,
    super.details,
    super.stackTrace,
  });

  /// Factory untuk query failed
  factory DatabaseException.queryFailed([String? reason]) {
    return DatabaseException(
      message: 'Gagal mengambil data${reason != null ? ': $reason' : ''}',
      code: 'QUERY_FAILED',
      details: reason,
    );
  }

  /// Factory untuk record not found
  factory DatabaseException.recordNotFound(String recordType) {
    return DatabaseException(
      message: '$recordType tidak ditemukan',
      code: 'RECORD_NOT_FOUND',
      details: recordType,
    );
  }

  /// Factory untuk constraint violation
  factory DatabaseException.constraintViolation([String? constraint]) {
    return DatabaseException(
      message:
          'Operasi melanggar aturan database${constraint != null ? ': $constraint' : ''}',
      code: 'CONSTRAINT_VIOLATION',
      details: constraint,
    );
  }

  /// Factory untuk duplicate entry
  factory DatabaseException.duplicateEntry(String field) {
    return DatabaseException(
      message: '$field sudah ada',
      code: 'DUPLICATE_ENTRY',
      details: field,
    );
  }
}

/// Server/API related exceptions
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.details,
    super.stackTrace,
  });

  /// Factory untuk internal server error
  factory ServerException.internalError() {
    return const ServerException(
      message: 'Terjadi kesalahan pada server',
      code: 'INTERNAL_ERROR',
    );
  }

  /// Factory untuk service unavailable
  factory ServerException.serviceUnavailable() {
    return const ServerException(
      message: 'Layanan sedang tidak tersedia',
      code: 'SERVICE_UNAVAILABLE',
    );
  }

  /// Factory untuk bad request
  factory ServerException.badRequest([String? reason]) {
    return ServerException(
      message: 'Permintaan tidak valid${reason != null ? ': $reason' : ''}',
      code: 'BAD_REQUEST',
      details: reason,
    );
  }
}

/// Unknown/unexpected exceptions
class UnknownException extends AppException {
  const UnknownException({
    required super.message,
    super.code,
    super.details,
    super.stackTrace,
  });

  /// Factory untuk generic unknown error
  factory UnknownException.generic([dynamic error]) {
    return UnknownException(
      message: 'Terjadi kesalahan tidak terduga',
      code: 'UNKNOWN_ERROR',
      details: error?.toString(),
    );
  }
}
