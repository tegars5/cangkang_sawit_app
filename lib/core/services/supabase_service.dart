import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import '../constants/app_constants.dart';

/// Service utama untuk mengelola koneksi dan operasi Supabase
/// Singleton pattern untuk memastikan hanya ada satu instance
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance =>
      _instance ??= SupabaseService._internal();

  SupabaseService._internal();

  /// Client Supabase yang akan digunakan di seluruh aplikasi
  SupabaseClient get client => Supabase.instance.client;

  /// Auth client untuk operasi autentikasi
  GoTrueClient get auth => client.auth;

  /// Database client untuk operasi database
  SupabaseQueryBuilder database(String table) => client.from(table);

  /// Storage client untuk operasi file
  SupabaseStorageClient get storage => client.storage;

  /// Realtime client untuk subscribe perubahan data
  RealtimeClient get realtime => client.realtime;

  /// Inisialisasi Supabase
  /// Harus dipanggil di main() sebelum runApp()
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
      debug: true, // Set false untuk production
    );
  }

  /// Helper method untuk mendapatkan user ID yang sedang login
  String? get currentUserId => auth.currentUser?.id;

  /// Helper method untuk mendapatkan user yang sedang login
  User? get currentUser => auth.currentUser;

  /// Helper method untuk cek apakah user sudah login
  bool get isLoggedIn => currentUser != null;

  /// Helper method untuk sign out
  Future<void> signOut() async {
    await auth.signOut();
  }

  /// Helper method untuk upload file ke storage
  /// [bucketName] nama bucket di Supabase Storage
  /// [filePath] path lokal file yang akan diupload
  /// [fileName] nama file yang akan disimpan di storage
  Future<String> uploadFile({
    required String bucketName,
    required String filePath,
    required String fileName,
  }) async {
    try {
      final file = File(filePath);
      await client.storage.from(bucketName).upload(fileName, file);

      // Return public URL
      final publicUrl = client.storage.from(bucketName).getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      throw Exception('Gagal upload file: $e');
    }
  }

  /// Helper method untuk upload file dari bytes
  Future<String> uploadFileFromBytes({
    required String bucketName,
    required Uint8List fileBytes,
    required String fileName,
    String? mimeType,
  }) async {
    try {
      await client.storage.from(bucketName).uploadBinary(fileName, fileBytes);

      // Return public URL
      final publicUrl = client.storage.from(bucketName).getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      throw Exception('Gagal upload file: $e');
    }
  }

  /// Helper method untuk delete file dari storage
  Future<void> deleteFile({
    required String bucketName,
    required String fileName,
  }) async {
    try {
      await client.storage.from(bucketName).remove([fileName]);
    } catch (e) {
      throw Exception('Gagal hapus file: $e');
    }
  }

  /// Helper method untuk download file dari storage
  Future<List<int>> downloadFile({
    required String bucketName,
    required String fileName,
  }) async {
    try {
      final file = await client.storage.from(bucketName).download(fileName);
      return file;
    } catch (e) {
      throw Exception('Gagal download file: $e');
    }
  }

  /// Helper method untuk mendapatkan signed URL (untuk file private)
  Future<String> getSignedUrl({
    required String bucketName,
    required String fileName,
    int expiresIn = 3600, // Default 1 jam
  }) async {
    try {
      final signedUrl = await client.storage
          .from(bucketName)
          .createSignedUrl(fileName, expiresIn);
      return signedUrl;
    } catch (e) {
      throw Exception('Gagal membuat signed URL: $e');
    }
  }

  /// Helper method untuk generate nomor pesanan unik
  /// Format: PO/YYYY/MM/XXX
  String generateOrderNumber() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final timestamp = now.millisecondsSinceEpoch.toString().substring(8);

    return 'PO/$year/$month/$timestamp';
  }

  /// Helper method untuk generate nomor surat jalan unik
  /// Format: SJ/YYYY/MM/XXX
  String generateSuratJalanNumber() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final timestamp = now.millisecondsSinceEpoch.toString().substring(8);

    return 'SJ/$year/$month/$timestamp';
  }

  /// Helper method untuk format currency Indonesia
  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  /// Helper method untuk format tanggal Indonesia
  String formatDate(DateTime date) {
    final months = [
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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Helper method untuk format waktu
  String formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }

  /// Helper method untuk format datetime lengkap
  String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }
}
