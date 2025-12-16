import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:typed_data';

/// Service for Supabase client access and generic utilities
/// This service should NOT contain business logic
/// All business logic belongs in feature-specific datasources/repositories
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance =>
      _instance ??= SupabaseService._internal();

  SupabaseService._internal();

  /// Supabase client - single source of truth
  SupabaseClient get client => Supabase.instance.client;

  /// Auth client for authentication operations
  GoTrueClient get auth => client.auth;

  /// Storage client for file operations
  SupabaseStorageClient get storage => client.storage;

  /// Realtime client for subscriptions
  RealtimeClient get realtime => client.realtime;

  // ============================================================================
  // GENERIC HELPERS - No business logic
  // ============================================================================

  /// Get current user ID (generic helper)
  String? get currentUserId => auth.currentUser?.id;

  /// Get current user (generic helper)
  User? get currentUser => auth.currentUser;

  /// Check if user is logged in (generic helper)
  bool get isLoggedIn => currentUser != null;

  /// Get current session (generic helper)
  Session? get currentSession => auth.currentSession;

  // ============================================================================
  // STORAGE HELPERS - Generic file operations only
  // ============================================================================

  /// Upload file to storage (generic helper)
  /// Business logic for which bucket/path should be in datasource
  Future<String> uploadFile({
    required String bucketName,
    required String filePath,
    required String fileName,
  }) async {
    final file = File(filePath);
    await storage.from(bucketName).upload(fileName, file);
    return storage.from(bucketName).getPublicUrl(fileName);
  }

  /// Upload file from bytes (generic helper)
  Future<String> uploadFileFromBytes({
    required String bucketName,
    required Uint8List fileBytes,
    required String fileName,
    String? mimeType,
  }) async {
    await storage
        .from(bucketName)
        .uploadBinary(
          fileName,
          fileBytes,
          fileOptions: mimeType != null
              ? FileOptions(contentType: mimeType)
              : null,
        );
    return storage.from(bucketName).getPublicUrl(fileName);
  }

  /// Delete file from storage (generic helper)
  Future<void> deleteFile({
    required String bucketName,
    required String fileName,
  }) async {
    await storage.from(bucketName).remove([fileName]);
  }

  /// Get public URL for file (generic helper)
  String getPublicUrl({required String bucketName, required String fileName}) {
    return storage.from(bucketName).getPublicUrl(fileName);
  }

  // ============================================================================
  // REALTIME HELPERS - Generic subscription helpers only
  // ============================================================================

  /// Create a realtime channel (generic helper)
  /// Specific subscription logic should be in datasource
  RealtimeChannel channel(String channelName) {
    return realtime.channel(channelName);
  }

  /// Remove all channels (generic helper)
  Future<void> removeAllChannels() async {
    await realtime.removeAllChannels();
  }
}
