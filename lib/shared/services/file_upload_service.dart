import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

/// Service untuk upload file ke Supabase Storage
class FileUploadService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const String _deliveryNotesBucket = 'surat-jalan';

  /// Upload delivery note document to Supabase Storage
  /// Returns the public URL of the uploaded file
  static Future<String> uploadDeliveryNote(File file, String orderId) async {
    try {
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(file.path);
      final fileName = 'delivery_note_${orderId}_$timestamp$extension';
      final filePath = 'orders/$orderId/$fileName';

      // Upload file to Supabase Storage
      await _supabase.storage
          .from(_deliveryNotesBucket)
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Get public URL
      final publicUrl = _supabase.storage
          .from(_deliveryNotesBucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload delivery note: $e');
    }
  }

  /// Delete delivery note from storage
  static Future<void> deleteDeliveryNote(String fileUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;

      // Find the bucket name and file path
      final bucketIndex = pathSegments.indexOf('object');
      if (bucketIndex == -1 || bucketIndex + 2 >= pathSegments.length) {
        throw Exception('Invalid file URL');
      }

      final filePath = pathSegments.sublist(bucketIndex + 2).join('/');

      // Delete file
      await _supabase.storage.from(_deliveryNotesBucket).remove([filePath]);
    } catch (e) {
      throw Exception('Failed to delete delivery note: $e');
    }
  }

  /// Upload proof of delivery photo
  static Future<String> uploadProofOfDelivery(
    File file,
    String shipmentId,
  ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(file.path);
      final fileName = 'proof_${shipmentId}_$timestamp$extension';
      final filePath = 'shipments/$shipmentId/$fileName';

      await _supabase.storage
          .from('bukti-kirim')
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl = _supabase.storage
          .from('bukti-kirim')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload proof of delivery: $e');
    }
  }
}
