import 'package:intl/intl.dart';

/// Utility class for formatting numbers, especially currency
class NumberFormatter {
  NumberFormatter._();

  /// Format number as Indonesian Rupiah currency
  /// Example: 1000000 -> "Rp 1.000.000"
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Format number with thousand separators
  /// Example: 1000000 -> "1.000.000"
  static String formatNumber(double number, {int decimalDigits = 0}) {
    final formatter = NumberFormat.decimalPattern('id_ID');
    if (decimalDigits > 0) {
      return number
          .toStringAsFixed(decimalDigits)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
    }
    return formatter.format(number);
  }

  /// Format number as percentage
  /// Example: 0.75 -> "75%"
  static String formatPercentage(double value, {int decimalDigits = 0}) {
    final percentage = value * 100;
    return '${percentage.toStringAsFixed(decimalDigits)}%';
  }

  /// Format weight in tons
  /// Example: 1.5 -> "1,5 ton"
  static String formatWeight(double tons, {int decimalDigits = 2}) {
    final formatted = tons.toStringAsFixed(decimalDigits).replaceAll('.', ',');
    return '$formatted ton';
  }

  /// Parse currency string to double
  /// Example: "Rp 1.000.000" -> 1000000.0
  static double parseCurrency(String currencyString) {
    final cleaned = currencyString
        .replaceAll('Rp', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(cleaned) ?? 0.0;
  }
}
