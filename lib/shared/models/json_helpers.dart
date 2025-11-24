/// Helper class untuk safe JSON parsing
/// Menghindari runtime error "type 'int' is not a subtype of type 'double'"
/// saat mengambil data dari Supabase yang mungkin bertipe berbeda dari ekspektasi
class JsonHelpers {
  /// Safe parsing dari dynamic ke double
  /// Mendukung konversi dari int, double, String, num ke double dengan fallback
  static double safeDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Safe parsing dari dynamic ke double nullable
  /// Return null jika value null, atau double jika berhasil parsing
  static double? safeDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Safe parsing dari dynamic ke int
  /// Mendukung konversi dari int, double, String, num ke int dengan fallback
  static int safeInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Safe parsing dari dynamic ke int nullable
  /// Return null jika value null, atau int jika berhasil parsing
  static int? safeIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Safe parsing dari dynamic ke bool
  /// Mendukung konversi dari bool, int (0/1), String ("true"/"false") ke bool
  static bool safeBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return defaultValue;
  }

  /// Safe parsing dari dynamic ke String
  /// Konversi apapun ke String dengan fallback
  static String safeString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  /// Safe parsing dari dynamic ke String nullable
  static String? safeStringNullable(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  /// Safe parsing untuk DateTime dari String ISO8601
  static DateTime? safeDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Safe parsing untuk List dari dynamic
  static List<T> safeList<T>(
    dynamic value,
    T Function(dynamic) converter, {
    List<T> defaultValue = const [],
  }) {
    if (value == null) return defaultValue;
    if (value is! List) return defaultValue;

    try {
      return value.map((item) => converter(item)).toList();
    } catch (e) {
      return defaultValue;
    }
  }
}
