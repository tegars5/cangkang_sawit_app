import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../error/exceptions.dart';

/// Service for uploading files to Supabase Storage
class FileUploadService {
  final SupabaseClient _supabase;

  FileUploadService(this._supabase);

  /// Upload proof of delivery photo
  Future<String> uploadProofOfDelivery({
    required String shipmentId,
    required File imageFile,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${shipmentId}_$timestamp.jpg';
      final path = '$fileName';

      // Upload file to Supabase Storage (bucket: bukti-kirim)
      await _supabase.storage
          .from('bukti-kirim')
          .upload(
            path,
            imageFile,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );

      // Get public URL
      final publicUrl = _supabase.storage
          .from('bukti-kirim')
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw ServerException('Failed to upload proof of delivery: $e');
    }
  }

  /// Upload delivery note document (PDF)
  Future<String> uploadDeliveryNote({
    required String shipmentId,
    required File pdfFile,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${shipmentId}_$timestamp.pdf';
      final path = '$fileName';

      // Upload file to Supabase Storage (bucket: surat-jalan)
      await _supabase.storage
          .from('surat-jalan')
          .upload(
            path,
            pdfFile,
            fileOptions: const FileOptions(
              contentType: 'application/pdf',
              upsert: false,
            ),
          );

      // Get public URL
      final publicUrl = _supabase.storage
          .from('surat-jalan')
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw ServerException('Failed to upload delivery note: $e');
    }
  }

  /// Upload profile photo
  Future<String> uploadProfilePhoto({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${userId}_$timestamp.jpg';
      final path = '$fileName';

      // Upload file to Supabase Storage (bucket: users)
      await _supabase.storage
          .from('users')
          .upload(
            path,
            imageFile,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );

      // Get public URL
      final publicUrl = _supabase.storage.from('users').getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw ServerException('Failed to upload profile photo: $e');
    }
  }

  /// Upload product image
  Future<String> uploadProductImage({
    required String productId,
    required File imageFile,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${productId}_$timestamp.jpg';
      final path = '$fileName';

      // Upload file to Supabase Storage (bucket: products)
      await _supabase.storage
          .from('products')
          .upload(
            path,
            imageFile,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );

      // Get public URL
      final publicUrl = _supabase.storage.from('products').getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw ServerException('Failed to upload product image: $e');
    }
  }

  /// Delete file from storage
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _supabase.storage.from(bucket).remove([path]);
    } catch (e) {
      throw ServerException('Failed to delete file: $e');
    }
  }

  /// Upload multiple images
  Future<List<String>> uploadMultipleImages({
    required String folder,
    required List<File> imageFiles,
    required String bucket,
  }) async {
    try {
      final List<String> urls = [];

      for (var imageFile in imageFiles) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = '${folder}_${urls.length}_$timestamp.jpg';
        final path = '$folder/$fileName';

        await _supabase.storage
            .from(bucket)
            .upload(
              path,
              imageFile,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                upsert: false,
              ),
            );

        final publicUrl = _supabase.storage.from(bucket).getPublicUrl(path);
        urls.add(publicUrl);
      }

      return urls;
    } catch (e) {
      throw ServerException('Failed to upload multiple images: $e');
    }
  }
}
