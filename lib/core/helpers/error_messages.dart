import '../errors/app_exception.dart';

/// Helper class for user-friendly error messages
class ErrorMessages {
  /// Get user-friendly error message from exception
  static String getErrorMessage(dynamic exception) {
    if (exception is AppException) {
      return _getAppExceptionMessage(exception);
    } else if (exception is String) {
      return exception;
    } else {
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  static String _getAppExceptionMessage(AppException exception) {
    if (exception is AuthException) {
      return _getAuthErrorMessage(exception);
    } else if (exception is DatabaseException) {
      return _getDatabaseErrorMessage(exception);
    } else if (exception is NetworkException) {
      return 'Tidak ada koneksi internet. Silakan periksa koneksi Anda dan coba lagi.';
    } else if (exception is ValidationException) {
      return exception.message;
    } else {
      return exception.message;
    }
  }

  static String _getAuthErrorMessage(AuthException exception) {
    final message = exception.message.toLowerCase();

    if (message.contains('invalid') || message.contains('wrong')) {
      return 'Email atau password salah. Silakan coba lagi.';
    } else if (message.contains('not found')) {
      return 'Akun tidak ditemukan. Silakan daftar terlebih dahulu.';
    } else if (message.contains('already exists') ||
        message.contains('duplicate')) {
      return 'Email sudah terdaftar. Silakan gunakan email lain atau login.';
    } else if (message.contains('session') || message.contains('expired')) {
      return 'Sesi Anda telah berakhir. Silakan login kembali.';
    } else if (message.contains('weak password')) {
      return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
    } else {
      return 'Gagal melakukan autentikasi. ${exception.message}';
    }
  }

  static String _getDatabaseErrorMessage(DatabaseException exception) {
    final message = exception.message.toLowerCase();

    if (message.contains('not found') || message.contains('no rows')) {
      return 'Data tidak ditemukan.';
    } else if (message.contains('duplicate') || message.contains('unique')) {
      return 'Data sudah ada. Silakan gunakan data yang berbeda.';
    } else if (message.contains('foreign key') ||
        message.contains('constraint')) {
      return 'Tidak dapat menghapus data karena masih digunakan.';
    } else if (message.contains('timeout')) {
      return 'Koneksi database timeout. Silakan coba lagi.';
    } else {
      return 'Gagal mengakses database. Silakan coba lagi.';
    }
  }

  /// Get error message for common operations
  static String getOperationErrorMessage(String operation, {String? details}) {
    final baseMessage = _getOperationMessage(operation);
    if (details != null && details.isNotEmpty) {
      return '$baseMessage Detail: $details';
    }
    return baseMessage;
  }

  static String _getOperationMessage(String operation) {
    switch (operation.toLowerCase()) {
      case 'login':
        return 'Gagal login. Silakan periksa email dan password Anda.';
      case 'register':
      case 'signup':
        return 'Gagal mendaftar. Silakan coba lagi.';
      case 'logout':
        return 'Gagal logout. Silakan coba lagi.';
      case 'create':
        return 'Gagal membuat data. Silakan coba lagi.';
      case 'update':
        return 'Gagal mengupdate data. Silakan coba lagi.';
      case 'delete':
        return 'Gagal menghapus data. Silakan coba lagi.';
      case 'fetch':
      case 'load':
        return 'Gagal memuat data. Silakan coba lagi.';
      case 'upload':
        return 'Gagal mengupload file. Silakan coba lagi.';
      case 'download':
        return 'Gagal mendownload file. Silakan coba lagi.';
      default:
        return 'Operasi gagal. Silakan coba lagi.';
    }
  }

  /// Get success message for common operations
  static String getSuccessMessage(String operation) {
    switch (operation.toLowerCase()) {
      case 'login':
        return 'Login berhasil!';
      case 'register':
      case 'signup':
        return 'Pendaftaran berhasil!';
      case 'logout':
        return 'Logout berhasil!';
      case 'create':
        return 'Data berhasil dibuat!';
      case 'update':
        return 'Data berhasil diupdate!';
      case 'delete':
        return 'Data berhasil dihapus!';
      case 'upload':
        return 'File berhasil diupload!';
      case 'download':
        return 'File berhasil didownload!';
      case 'send':
        return 'Berhasil dikirim!';
      case 'cancel':
        return 'Berhasil dibatalkan!';
      default:
        return 'Operasi berhasil!';
    }
  }
}
