/// Utility class for generating unique order and document numbers
class OrderNumberGenerator {
  OrderNumberGenerator._();

  /// Generate unique order number
  /// Format: PO/YYYY/MM/XXX
  /// Example: PO/2024/12/001234
  static String generateOrderNumber() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final timestamp = now.millisecondsSinceEpoch.toString().substring(8);

    return 'PO/$year/$month/$timestamp';
  }

  /// Generate unique delivery note number (Surat Jalan)
  /// Format: SJ/YYYY/MM/XXX
  /// Example: SJ/2024/12/001234
  static String generateDeliveryNoteNumber() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final timestamp = now.millisecondsSinceEpoch.toString().substring(8);

    return 'SJ/$year/$month/$timestamp';
  }

  /// Generate unique shipment tracking number
  /// Format: TRK-YYYYMMDD-XXX
  /// Example: TRK-20241216-001234
  static String generateTrackingNumber() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final timestamp = now.millisecondsSinceEpoch.toString().substring(8);

    return 'TRK-$year$month$day-$timestamp';
  }

  /// Generate unique invoice number
  /// Format: INV/YYYY/MM/XXX
  /// Example: INV/2024/12/001234
  static String generateInvoiceNumber() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final timestamp = now.millisecondsSinceEpoch.toString().substring(8);

    return 'INV/$year/$month/$timestamp';
  }

  /// Generate unique product code
  /// Format: PRD-XXX
  /// Example: PRD-001234
  static String generateProductCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(8);
    return 'PRD-$timestamp';
  }
}
