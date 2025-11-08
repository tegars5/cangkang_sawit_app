import 'dart:developer';
import '../repositories/shipment_repository.dart';
import '../services/photo_upload_service.dart';
import '../../shared/repositories/location_repository.dart';

class AppInitializationService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      log('Initializing app services...');

      // Initialize Supabase-dependent services
      await _initializeSupabaseServices();

      // Initialize background services
      await _initializeBackgroundServices();

      // Setup real-time subscriptions
      _setupRealtimeSubscriptions();

      _isInitialized = true;
      log('App initialization completed successfully');
    } catch (e, stackTrace) {
      log('Error during app initialization: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  static Future<void> _initializeSupabaseServices() async {
    try {
      // Initialize photo upload service bucket
      await PhotoUploadService.initializeBucket();
      log('Photo upload service initialized');

      // Initialize location repository
      LocationRepository.initialize();
      log('Location repository initialized');

      // Initialize shipment repository
      ShipmentRepository.initialize();
      log('Shipment repository initialized');
    } catch (e, stackTrace) {
      log('Error initializing Supabase services: $e', error: e, stackTrace: stackTrace);
      throw Exception('Failed to initialize Supabase services: $e');
    }
  }

  static Future<void> _initializeBackgroundServices() async {
    try {
      // Any background service initialization can be added here
      log('Background services initialized');
    } catch (e, stackTrace) {
      log('Error initializing background services: $e', error: e, stackTrace: stackTrace);
      throw Exception('Failed to initialize background services: $e');
    }
  }

  static void _setupRealtimeSubscriptions() {
    try {
      // Real-time subscriptions are automatically set up by repository initialization
      log('Real-time subscriptions established');
    } catch (e, stackTrace) {
      log('Error setting up real-time subscriptions: $e', error: e, stackTrace: stackTrace);
      // Non-fatal error - app can continue without real-time updates
    }
  }

  static void dispose() {
    try {
      if (!_isInitialized) return;

      // Dispose repositories
      ShipmentRepository.dispose();
      LocationRepository.dispose();
      
      _isInitialized = false;
      log('App services disposed');
    } catch (e, stackTrace) {
      log('Error during app disposal: $e', error: e, stackTrace: stackTrace);
    }
  }

  static bool get isInitialized => _isInitialized;
}