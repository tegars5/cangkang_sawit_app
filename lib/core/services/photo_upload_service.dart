import 'dart:io';
import 'dart:typed_data';
import 'dart:developer';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_client.dart';

class PhotoUploadService {
  static final SupabaseClient _supabase = SupabaseConfig.client;
  static const String _bucketName = 'delivery-photos';
  static const int _maxFileSize = 5 * 1024 * 1024; // 5MB
  static const int _compressQuality = 80;
  static const int _maxWidth = 1080;
  static const int _maxHeight = 1920;

  // Initialize storage bucket
  static Future<void> initializeBucket() async {
    try {
      // Check if bucket exists, create if not
      final buckets = await _supabase.storage.listBuckets();
      final bucketExists = buckets.any((bucket) => bucket.name == _bucketName);

      if (!bucketExists) {
        await _supabase.storage.createBucket(
          _bucketName,
          const BucketOptions(
            public: false,
            allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp'],
            fileSizeLimit: _maxFileSize,
          ),
        );
        log('Created delivery-photos bucket');
      }
    } catch (e, stackTrace) {
      log(
        'Error initializing photo bucket: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Compress image before upload
  static Future<Uint8List?> _compressImage(String filePath) async {
    try {
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        filePath,
        minWidth: 400,
        minHeight: 400,
        quality: _compressQuality,
        format: CompressFormat.jpeg,
      );

      if (compressedBytes != null && compressedBytes.length > _maxFileSize) {
        // If still too large, compress more aggressively
        return await FlutterImageCompress.compressWithFile(
          filePath,
          minWidth: 300,
          minHeight: 300,
          quality: 60,
          format: CompressFormat.jpeg,
        );
      }

      return compressedBytes;
    } catch (e, stackTrace) {
      log('Error compressing image: $e', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // Generate unique file path for photo
  static String _generatePhotoPath(String shipmentId, String originalFileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(originalFileName).toLowerCase();
    return 'shipments/$shipmentId/delivery_${timestamp}$extension';
  }

  // Upload delivery photo
  static Future<String> uploadDeliveryPhoto({
    required String shipmentId,
    required String photoPath,
    String? description,
    Function(double)? onProgress,
  }) async {
    try {
      // Validate file exists
      final file = File(photoPath);
      if (!await file.exists()) {
        throw Exception('Photo file not found');
      }

      // Check file size
      final fileSize = await file.length();
      if (fileSize > _maxFileSize) {
        log('File too large, compressing: ${fileSize} bytes');
      }

      // Compress image if needed
      Uint8List? photoBytes;
      if (fileSize > _maxFileSize ||
          !photoPath.toLowerCase().endsWith('.jpg') &&
              !photoPath.toLowerCase().endsWith('.jpeg')) {
        photoBytes = await _compressImage(photoPath);
        if (photoBytes == null) {
          throw Exception('Failed to compress image');
        }
      } else {
        photoBytes = await file.readAsBytes();
      }

      // Generate unique file path
      final fileName = path.basename(photoPath);
      final storagePath = _generatePhotoPath(shipmentId, fileName);

      // Upload to Supabase Storage
      final uploadResult = await _supabase.storage
          .from(_bucketName)
          .uploadBinary(
            storagePath,
            photoBytes,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: false,
              contentType: 'image/jpeg',
            ),
          );

      // Get public URL
      final publicUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(storagePath);

      log('Uploaded delivery photo: $storagePath');
      return publicUrl;
    } catch (e, stackTrace) {
      log(
        'Error uploading delivery photo: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to upload delivery photo: $e');
    }
  }

  // Upload multiple delivery photos
  static Future<List<String>> uploadMultipleDeliveryPhotos({
    required String shipmentId,
    required List<String> photoPaths,
    Function(int current, int total)? onProgress,
  }) async {
    final uploadedUrls = <String>[];

    try {
      for (int i = 0; i < photoPaths.length; i++) {
        onProgress?.call(i + 1, photoPaths.length);

        final url = await uploadDeliveryPhoto(
          shipmentId: shipmentId,
          photoPath: photoPaths[i],
        );

        uploadedUrls.add(url);
      }

      return uploadedUrls;
    } catch (e, stackTrace) {
      log(
        'Error uploading multiple photos: $e',
        error: e,
        stackTrace: stackTrace,
      );
      // Clean up any successfully uploaded photos
      for (final url in uploadedUrls) {
        try {
          await deletePhotoByUrl(url);
        } catch (deleteError) {
          log('Error cleaning up uploaded photo: $deleteError');
        }
      }
      throw Exception('Failed to upload photos: $e');
    }
  }

  // Delete photo by URL
  static Future<void> deletePhotoByUrl(String photoUrl) async {
    try {
      // Extract file path from public URL
      final uri = Uri.parse(photoUrl);
      final pathSegments = uri.pathSegments;

      // Find the bucket name and file path in the URL
      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex == -1 || bucketIndex + 1 >= pathSegments.length) {
        throw Exception('Invalid photo URL format');
      }

      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      await _supabase.storage.from(_bucketName).remove([filePath]);

      log('Deleted photo: $filePath');
    } catch (e, stackTrace) {
      log('Error deleting photo: $e', error: e, stackTrace: stackTrace);
      throw Exception('Failed to delete photo: $e');
    }
  }

  // Delete all photos for a shipment
  static Future<void> deleteShipmentPhotos(String shipmentId) async {
    try {
      final files = await _supabase.storage
          .from(_bucketName)
          .list(path: 'shipments/$shipmentId');

      if (files.isNotEmpty) {
        final filePaths = files
            .map((file) => 'shipments/$shipmentId/${file.name}')
            .toList();

        await _supabase.storage.from(_bucketName).remove(filePaths);

        log('Deleted ${filePaths.length} photos for shipment: $shipmentId');
      }
    } catch (e, stackTrace) {
      log(
        'Error deleting shipment photos: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to delete shipment photos: $e');
    }
  }

  // Get photo download URL (for private access)
  static Future<String> getPhotoDownloadUrl(
    String photoUrl, {
    int expiresIn = 3600,
  }) async {
    try {
      // Extract file path from public URL
      final uri = Uri.parse(photoUrl);
      final pathSegments = uri.pathSegments;

      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex == -1 || bucketIndex + 1 >= pathSegments.length) {
        throw Exception('Invalid photo URL format');
      }

      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      final signedUrl = await _supabase.storage
          .from(_bucketName)
          .createSignedUrl(filePath, expiresIn);

      return signedUrl;
    } catch (e, stackTrace) {
      log(
        'Error getting photo download URL: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to get photo download URL: $e');
    }
  }

  // Validate photo file
  static bool isValidPhotoFile(String filePath) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return false;

      final extension = path.extension(filePath).toLowerCase();
      final validExtensions = ['.jpg', '.jpeg', '.png', '.webp'];

      return validExtensions.contains(extension);
    } catch (e) {
      return false;
    }
  }

  // Get photo file size
  static Future<int> getPhotoFileSize(String filePath) async {
    try {
      final file = File(filePath);
      return await file.length();
    } catch (e) {
      return 0;
    }
  }

  // Check if photo needs compression
  static Future<bool> needsCompression(String filePath) async {
    try {
      final fileSize = await getPhotoFileSize(filePath);
      return fileSize > _maxFileSize;
    } catch (e) {
      return false;
    }
  }
}
