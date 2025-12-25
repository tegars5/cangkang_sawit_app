import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/shipment.dart';

/// Remote data source for Shipment operations
class ShipmentRemoteDataSource {
  final SupabaseClient _client;

  ShipmentRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Get all shipments with optional filtering
  Future<List<Shipment>> getShipments({
    String? status,
    String? driverId,
  }) async {
    try {
      var query = _client.from('shipments').select('''
            *,
            orders!inner(
              *,
              profiles:customer_id(*)
            )
          ''');

      if (status != null) {
        query = query.eq('status', status);
      }

      if (driverId != null) {
        query = query.eq('driver_id', driverId);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => Shipment.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Failed to get shipments: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get shipments: $e');
    }
  }

  /// Get shipment by ID
  Future<Shipment> getShipmentById(String shipmentId) async {
    try {
      final response = await _client
          .from('shipments')
          .select('''
            *,
            orders!inner(
              *,
              profiles:customer_id(*)
            )
          ''')
          .eq('id', shipmentId)
          .single();

      return Shipment.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw NotFoundException('Shipment not found');
      }
      throw ServerException('Failed to get shipment: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get shipment: $e');
    }
  }

  /// Assign driver to shipment
  Future<Shipment> assignDriver({
    required String shipmentId,
    required String driverId,
    String? driverName,
    String? vehiclePlate,
  }) async {
    try {
      final updateData = {
        'driver_id': driverId,
        'status': 'assigned',
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (driverName != null) updateData['driver_name'] = driverName;
      if (vehiclePlate != null) updateData['vehicle_plate'] = vehiclePlate;

      await _client.from('shipments').update(updateData).eq('id', shipmentId);

      return await getShipmentById(shipmentId);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to assign driver: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to assign driver: $e');
    }
  }

  /// Update shipment status
  Future<Shipment> updateShipmentStatus({
    required String shipmentId,
    required String newStatus,
    DateTime? actualPickupDate,
    DateTime? actualDeliveryDate,
    String? notes,
  }) async {
    try {
      final updateData = {
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (actualPickupDate != null) {
        updateData['actual_pickup_date'] = actualPickupDate.toIso8601String();
      }
      if (actualDeliveryDate != null) {
        updateData['actual_delivery_date'] = actualDeliveryDate
            .toIso8601String();
      }
      if (notes != null) {
        updateData['notes'] = notes;
      }

      await _client.from('shipments').update(updateData).eq('id', shipmentId);

      return await getShipmentById(shipmentId);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to update status: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to update status: $e');
    }
  }

  /// Create a new shipment from an order
  Future<Shipment> createShipment({
    required String orderId,
    required String pickupAddress,
    required String deliveryAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    double? deliveryLatitude,
    double? deliveryLongitude,
    DateTime? scheduledPickupDate,
    DateTime? estimatedDeliveryDate,
    required double totalWeight,
    required int totalQuantity,
    String? notes,
  }) async {
    try {
      final shipmentData = {
        'order_id': orderId,
        'status': 'pending',
        'pickup_address': pickupAddress,
        'delivery_address': deliveryAddress,
        'pickup_latitude': pickupLatitude,
        'pickup_longitude': pickupLongitude,
        'delivery_latitude': deliveryLatitude,
        'delivery_longitude': deliveryLongitude,
        'scheduled_pickup_date': scheduledPickupDate?.toIso8601String(),
        'estimated_delivery_date': estimatedDeliveryDate?.toIso8601String(),
        'total_weight': totalWeight,
        'total_quantity': totalQuantity,
        'notes': notes,
      };

      final response = await _client
          .from('shipments')
          .insert(shipmentData)
          .select()
          .single();

      return Shipment.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to create shipment: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to create shipment: $e');
    }
  }

  /// Mark shipment as picked up
  Future<Shipment> markAsPickedUp({
    required String shipmentId,
    DateTime? actualPickupDate,
  }) async {
    return updateShipmentStatus(
      shipmentId: shipmentId,
      newStatus: 'in_transit',
      actualPickupDate: actualPickupDate ?? DateTime.now(),
    );
  }

  /// Mark shipment as delivered
  Future<Shipment> markAsDelivered({
    required String shipmentId,
    DateTime? actualDeliveryDate,
    String? proofOfDeliveryUrl,
    String? recipientName,
    String? recipientSignature,
  }) async {
    try {
      final updateData = {
        'status': 'delivered',
        'actual_delivery_date': (actualDeliveryDate ?? DateTime.now())
            .toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (proofOfDeliveryUrl != null) {
        updateData['proof_of_delivery_url'] = proofOfDeliveryUrl;
      }
      if (recipientName != null) {
        updateData['recipient_name'] = recipientName;
      }
      if (recipientSignature != null) {
        updateData['recipient_signature'] = recipientSignature;
      }

      await _client.from('shipments').update(updateData).eq('id', shipmentId);

      return await getShipmentById(shipmentId);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to mark as delivered: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to mark as delivered: $e');
    }
  }

  /// Cancel a shipment
  Future<Shipment> cancelShipment({
    required String shipmentId,
    String? reason,
  }) async {
    return updateShipmentStatus(
      shipmentId: shipmentId,
      newStatus: 'cancelled',
      notes: reason,
    );
  }

  /// Update shipment details
  Future<Shipment> updateShipment({
    required String shipmentId,
    String? pickupAddress,
    String? deliveryAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    double? deliveryLatitude,
    double? deliveryLongitude,
    DateTime? scheduledPickupDate,
    DateTime? estimatedDeliveryDate,
    String? notes,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (pickupAddress != null) updateData['pickup_address'] = pickupAddress;
      if (deliveryAddress != null)
        updateData['delivery_address'] = deliveryAddress;
      if (pickupLatitude != null)
        updateData['pickup_latitude'] = pickupLatitude;
      if (pickupLongitude != null)
        updateData['pickup_longitude'] = pickupLongitude;
      if (deliveryLatitude != null)
        updateData['delivery_latitude'] = deliveryLatitude;
      if (deliveryLongitude != null)
        updateData['delivery_longitude'] = deliveryLongitude;
      if (scheduledPickupDate != null) {
        updateData['scheduled_pickup_date'] = scheduledPickupDate
            .toIso8601String();
      }
      if (estimatedDeliveryDate != null) {
        updateData['estimated_delivery_date'] = estimatedDeliveryDate
            .toIso8601String();
      }
      if (notes != null) updateData['notes'] = notes;

      await _client.from('shipments').update(updateData).eq('id', shipmentId);

      return await getShipmentById(shipmentId);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to update shipment: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to update shipment: $e');
    }
  }

  /// Get shipments by driver
  Future<List<Shipment>> getShipmentsByDriver(String driverId) async {
    return getShipments(driverId: driverId);
  }

  /// Get shipments by order
  Future<List<Shipment>> getShipmentsByOrder(String orderId) async {
    try {
      final response = await _client
          .from('shipments')
          .select('''
            *,
            orders!inner(
              *,
              profiles:customer_id(*)
            )
          ''')
          .eq('order_id', orderId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Shipment.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Failed to get shipments by order: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get shipments by order: $e');
    }
  }

  /// Get active shipments (not delivered or cancelled)
  Future<List<Shipment>> getActiveShipments() async {
    try {
      final response = await _client
          .from('shipments')
          .select('''
            *,
            orders!inner(
              *,
              profiles:customer_id(*)
            )
          ''')
          .not('status', 'in', '(delivered,cancelled)')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Shipment.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Failed to get active shipments: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get active shipments: $e');
    }
  }

  /// Get shipments requiring action (pending, assigned without pickup)
  Future<List<Shipment>> getShipmentsRequiringAction() async {
    try {
      final response = await _client
          .from('shipments')
          .select('''
            *,
            orders!inner(
              *,
              profiles:customer_id(*)
            )
          ''')
          .or(
            'status.eq.pending,and(status.eq.assigned,actual_pickup_date.is.null)',
          )
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Shipment.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        'Failed to get shipments requiring action: ${e.message}',
      );
    } catch (e) {
      throw ServerException('Failed to get shipments requiring action: $e');
    }
  }

  /// Add timeline event
  /// Note: Implement when ShipmentTimeline entity is created
  // Future<void> addTimelineEvent({
  //   required String shipmentId,
  //   required ShipmentTimeline event,
  // }) async {
  //   try {
  //     final eventData = event.toJson();
  //     eventData['shipment_id'] = shipmentId;
  //
  //     await _client.from('shipment_timeline').insert(eventData);
  //   } on PostgrestException catch (e) {
  //     throw ServerException('Failed to add timeline event: ${e.message}');
  //   } catch (e) {
  //     throw ServerException('Failed to add timeline event: $e');
  //   }
  // }
}
