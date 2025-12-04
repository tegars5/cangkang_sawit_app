import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:developer' as developer;
import 'dart:typed_data';

/// Driver Service - Handles all driver-related operations
class DriverService {
  static final _supabase = Supabase.instance.client;
  static final ImagePicker _picker = ImagePicker();

  /// 1. UPDATE SHIPMENT STATUS - Driver updates delivery status
  static Future<Map<String, dynamic>> updateShipmentStatus({
    required String shipmentId,
    required String status, // 'in_transit', 'arrived', 'completed'
    String? notes,
    Position? currentLocation,
  }) async {
    try {
      final now = DateTime.now();
      final updates = <String, dynamic>{
        'status': status,
        'updated_at': now.toIso8601String(),
      };

      // Add specific timestamps based on status
      switch (status) {
        case 'in_transit':
          updates['started_at'] = now.toIso8601String();
          break;
        case 'arrived':
          // Could add arrival timestamp if needed
          break;
        case 'completed':
          updates['completed_at'] = now.toIso8601String();
          updates['actual_delivery'] = now.toIso8601String();
          break;
      }

      // Update shipment status
      await _supabase.from('shipments').update(updates).eq('id', shipmentId);

      // Update related order status if completed
      if (status == 'completed') {
        final shipment = await _supabase
            .from('shipments')
            .select('order_id')
            .eq('id', shipmentId)
            .single();

        if (shipment['order_id'] != null) {
          await _supabase
              .from('orders')
              .update({
                'status': 'completed',
                'completed_at': now.toIso8601String(),
              })
              .eq('id', shipment['order_id']);
        }
      }

      // Log driver location if provided
      if (currentLocation != null) {
        await logDriverLocation(
          driverId: _supabase.auth.currentUser?.id ?? '',
          shipmentId: shipmentId,
          location: currentLocation,
        );
      }

      // Send notification to admin
      await _supabase.from('notifications').insert({
        'user_id': null, // Broadcast to admins
        'title': 'Shipment Status Updated',
        'message': 'Shipment has been updated to $status',
        'type': 'shipment_update',
        'related_table': 'shipments',
        'related_id': shipmentId,
      });

      developer.log(
        'Successfully updated shipment $shipmentId status to $status',
      );

      return {
        'success': true,
        'message': 'Status berhasil diupdate ke $status',
        'data': {'shipment_id': shipmentId, 'status': status},
      };
    } catch (e) {
      developer.log('Error updating shipment status: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// 2. UPLOAD DELIVERY PROOF - Upload photo and signature
  static Future<Map<String, dynamic>> uploadDeliveryProof({
    required String shipmentId,
    File? photoFile,
    Uint8List? signatureBytes,
    String? notes,
  }) async {
    try {
      String? photoUrl;
      String? signatureUrl;

      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Upload photo if provided
      if (photoFile != null) {
        final photoExtension = photoFile.path.split('.').last;
        final photoPath =
            'delivery_photos/${shipmentId}_${DateTime.now().millisecondsSinceEpoch}.$photoExtension';

        await _supabase.storage
            .from('delivery-proofs')
            .upload(photoPath, photoFile);

        photoUrl = _supabase.storage
            .from('delivery-proofs')
            .getPublicUrl(photoPath);
      }

      // Upload signature if provided
      if (signatureBytes != null) {
        final signaturePath =
            'delivery_signatures/${shipmentId}_${DateTime.now().millisecondsSinceEpoch}.png';

        await _supabase.storage
            .from('delivery-proofs')
            .uploadBinary(signaturePath, signatureBytes);

        signatureUrl = _supabase.storage
            .from('delivery-proofs')
            .getPublicUrl(signaturePath);
      }

      // Create or update delivery record
      final deliveryData = {
        'shipment_id': shipmentId,
        'driver_id': user.id,
        'status': 'completed',
        'delivery_time': DateTime.now().toIso8601String(),
        'delivery_photo': photoUrl,
        'delivery_signature': signatureUrl,
        'notes': notes,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Check if delivery record exists
      final existingDelivery = await _supabase
          .from('deliveries')
          .select('id')
          .eq('shipment_id', shipmentId)
          .maybeSingle();

      if (existingDelivery != null) {
        // Update existing delivery
        await _supabase
            .from('deliveries')
            .update(deliveryData)
            .eq('id', existingDelivery['id']);
      } else {
        // Create new delivery
        await _supabase.from('deliveries').insert(deliveryData);
      }

      // Update shipment with proof URLs
      final shipmentUpdates = <String, dynamic>{
        'proof_of_delivery_url': photoUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('shipments')
          .update(shipmentUpdates)
          .eq('id', shipmentId);

      developer.log(
        'Successfully uploaded delivery proof for shipment $shipmentId',
      );

      return {
        'success': true,
        'message': 'Bukti pengiriman berhasil diupload',
        'data': {'photo_url': photoUrl, 'signature_url': signatureUrl},
      };
    } catch (e) {
      developer.log('Error uploading delivery proof: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// 3. LIVE LOCATION TRACKING - Log driver location
  static Future<Map<String, dynamic>> logDriverLocation({
    required String driverId,
    String? shipmentId,
    Position? location,
  }) async {
    try {
      Position currentLocation;

      if (location != null) {
        currentLocation = location;
      } else {
        // Get current location
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          throw Exception('Location services are disabled');
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            throw Exception('Location permission denied');
          }
        }

        if (permission == LocationPermission.deniedForever) {
          throw Exception('Location permissions are permanently denied');
        }

        currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      }

      // Log location to database
      await _supabase.from('driver_locations').insert({
        'driver_id': driverId,
        'shipment_id': shipmentId,
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
        'accuracy': currentLocation.accuracy,
        'altitude': currentLocation.altitude,
        'speed': currentLocation.speed,
        'heading': currentLocation.heading,
        'timestamp': DateTime.now().toIso8601String(),
      });

      return {
        'success': true,
        'message': 'Location logged successfully',
        'data': {
          'latitude': currentLocation.latitude,
          'longitude': currentLocation.longitude,
        },
      };
    } catch (e) {
      developer.log('Error logging driver location: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Start live location tracking
  static Future<Map<String, dynamic>> startLiveTracking({
    required String driverId,
    String? shipmentId,
    int intervalMinutes = 5,
  }) async {
    try {
      // Check permissions
      final status = await Permission.location.request();
      if (!status.isGranted) {
        throw Exception('Location permission not granted');
      }

      // Start location tracking (this would typically be handled by a background service)
      developer.log('Starting live tracking for driver $driverId');

      return {
        'success': true,
        'message': 'Live tracking started',
        'interval_minutes': intervalMinutes,
      };
    } catch (e) {
      developer.log('Error starting live tracking: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Stop live location tracking
  static Future<Map<String, dynamic>> stopLiveTracking({
    required String driverId,
  }) async {
    try {
      developer.log('Stopping live tracking for driver $driverId');

      return {'success': true, 'message': 'Live tracking stopped'};
    } catch (e) {
      developer.log('Error stopping live tracking: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get driver's active shipments
  static Future<Map<String, dynamic>> getActiveShipments({
    required String driverId,
  }) async {
    try {
      final response = await _supabase
          .from('shipments')
          .select('''
            *,
            orders!inner(
              id, order_number, customer_id, pickup_address, delivery_address,
              total_quantity, total_amount,
              profiles!customer_id(full_name, phone, email)
            )
          ''')
          .eq('driver_id', driverId)
          .inFilter('status', ['pending', 'in_transit', 'arrived'])
          .order('assigned_at', ascending: true);

      final shipments = (response as List<dynamic>).map((shipment) {
        final order = shipment['orders'];
        final customer = order['profiles'];

        return {
          'shipment_id': shipment['id'],
          'order_id': order['id'],
          'order_number': order['order_number'],
          'status': shipment['status'],
          'customer_name': customer['full_name'],
          'customer_phone': customer['phone'],
          'pickup_address': order['pickup_address'],
          'delivery_address': order['delivery_address'],
          'total_quantity': order['total_quantity'],
          'total_amount': order['total_amount'],
          'assigned_at': shipment['assigned_at'],
          'delivery_note_number': shipment['delivery_note_number'],
        };
      }).toList();

      return {
        'success': true,
        'data': shipments,
        'total_active': shipments.length,
      };
    } catch (e) {
      developer.log('Error getting active shipments: $e');
      return {'success': false, 'error': e.toString(), 'data': []};
    }
  }

  /// Capture photo for delivery proof
  static Future<File?> captureDeliveryPhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      return photo != null ? File(photo.path) : null;
    } catch (e) {
      developer.log('Error capturing delivery photo: $e');
      return null;
    }
  }

  /// Get driver location history
  static Future<Map<String, dynamic>> getLocationHistory({
    required String driverId,
    String? shipmentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase
          .from('driver_locations')
          .select('*')
          .eq('driver_id', driverId);

      if (shipmentId != null) {
        query = query.eq('shipment_id', shipmentId);
      }

      if (startDate != null) {
        query = query.gte('timestamp', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('timestamp', endDate.toIso8601String());
      }

      final response = await query.order('timestamp', ascending: false);

      return {
        'success': true,
        'data': response,
        'total_locations': (response as List).length,
      };
    } catch (e) {
      developer.log('Error getting location history: $e');
      return {'success': false, 'error': e.toString(), 'data': []};
    }
  }

  /// Create delivery record
  static Future<Map<String, dynamic>> createDeliveryRecord({
    required String shipmentId,
    required String driverId,
    String status = 'pending',
  }) async {
    try {
      final deliveryData = {
        'shipment_id': shipmentId,
        'driver_id': driverId,
        'status': status,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('deliveries')
          .insert(deliveryData)
          .select()
          .single();

      return {
        'success': true,
        'message': 'Delivery record created',
        'data': response,
      };
    } catch (e) {
      developer.log('Error creating delivery record: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
