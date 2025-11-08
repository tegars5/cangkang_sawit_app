/// Konfigurasi konstanta aplikasi
/// File ini berisi semua konstanta yang digunakan di seluruh aplikasi
class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = 'https://pblydtqugcbrlezemerg.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBibHlkdHF1Z2NicmxlemVtZXJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE1NzM2ODksImV4cCI6MjA3NzE0OTY4OX0.Dwd0AcSCRw2uBCQqZB1m63MD1ZcjzPDYoNpOnPRPmU4';

  // Bucket Names untuk Supabase Storage
  static const String suratJalanBucket = 'surat-jalan';
  static const String buktiKirimBucket = 'bukti-kirim';

  // Role IDs sesuai dengan database
  static const int adminRoleId = 1;
  static const int mitraBisnisRoleId = 2;
  static const int logistikRoleId = 3;

  // Status Pesanan
  static const String statusPesananBaru = 'Baru';
  static const String statusPesananDikonfirmasi = 'Dikonfirmasi';
  static const String statusPesananDikemas = 'Dikemas';
  static const String statusPesananDikirim = 'Dikirim';
  static const String statusPesananSelesai = 'Selesai';

  // Status Pengiriman
  static const String statusPengirimanMenunggu = 'Menunggu';
  static const String statusPengirimanDalamPerjalanan = 'Dalam Perjalanan';
  static const String statusPengirimanTiba = 'Tiba';

  // GPS Tracking Configuration
  static const int locationUpdateIntervalSeconds = 30; // Update setiap 30 detik
  static const double minimumDistanceFilter = 10.0; // Minimum 10 meter

  // File Upload Configuration
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png'];
  static const List<String> allowedDocumentExtensions = ['pdf'];

  // App Information
  static const String appName = 'Cangkang Sawit App';
  static const String companyName = 'PT. Fujiyama Biomass Energy';
  static const String appVersion = '1.0.0';
}

/// Enum untuk Role User
enum UserRole {
  admin(1, 'Admin'),
  mitraBisnis(2, 'Mitra Bisnis'),
  logistik(3, 'Logistik');

  const UserRole(this.id, this.displayName);

  final int id;
  final String displayName;

  static UserRole fromId(int id) {
    return UserRole.values.firstWhere((role) => role.id == id);
  }
}

/// Enum untuk Status Pesanan
enum OrderStatus {
  baru('Baru'),
  dikonfirmasi('Dikonfirmasi'),
  dikemas('Dikemas'),
  dikirim('Dikirim'),
  selesai('Selesai');

  const OrderStatus(this.value);

  final String value;

  static OrderStatus fromString(String status) {
    return OrderStatus.values.firstWhere((s) => s.value == status);
  }
}

/// Enum untuk Status Pengiriman
enum ShipmentStatus {
  menunggu('Menunggu'),
  dalamPerjalanan('Dalam Perjalanan'),
  tiba('Tiba');

  const ShipmentStatus(this.value);

  final String value;

  static ShipmentStatus fromString(String status) {
    return ShipmentStatus.values.firstWhere((s) => s.value == status);
  }
}
