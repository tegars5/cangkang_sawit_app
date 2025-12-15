import 'package:intl/intl.dart';

/// Utility class for formatting dates and times
class DateFormatter {
  DateFormatter._();

  static const List<String> _monthsIndonesian = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _daysIndonesian = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  /// Format date as Indonesian format
  /// Example: 2024-12-16 -> "16 Desember 2024"
  static String formatDate(DateTime date) {
    return '${date.day} ${_monthsIndonesian[date.month - 1]} ${date.year}';
  }

  /// Format time as WIB
  /// Example: 14:30 -> "14:30 WIB"
  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }

  /// Format datetime with full Indonesian format
  /// Example: "16 Desember 2024 14:30 WIB"
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  /// Format date with day name
  /// Example: "Senin, 16 Desember 2024"
  static String formatDateWithDay(DateTime date) {
    final dayName = _daysIndonesian[date.weekday - 1];
    return '$dayName, ${formatDate(date)}';
  }

  /// Format as short date
  /// Example: "16/12/2024"
  static String formatShortDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format as ISO 8601 string
  /// Example: "2024-12-16T14:30:00.000Z"
  static String formatISO(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  /// Get relative time (e.g., "2 jam yang lalu")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years tahun yang lalu';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months bulan yang lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  /// Parse ISO string to DateTime
  static DateTime? parseISO(String isoString) {
    try {
      return DateTime.parse(isoString);
    } catch (e) {
      return null;
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }
}
