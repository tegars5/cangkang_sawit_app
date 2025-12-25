import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/shipment_model.dart';

/// Remote data source interface for shipment operations
abstract class ShipmentRemoteDataSourceV2 {
  Future<List<ShipmentModel>> getShipments({
    String? status,
    String? driverId,
    String? orderId,
  });

  Future<ShipmentModel> getShipmentById(String id);

  Future<ShipmentModel> createShipment({
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
  });

  Future<ShipmentModel> assignDriver({
    required String shipmentId,
    required String driverId,
    required String driverName,
    String? vehiclePlate,
  });

  Future<ShipmentModel> updateShipmentStatus({
    required String shipmentId,
    required String status,
    DateTime? actualPickupDate,
    DateTime? actualDeliveryDate,
    String? notes,
  });

  Future<ShipmentModel> markAsPickedUp({
    required String shipmentId,
    DateTime? actualPickupDate,
  });

  Future<ShipmentModel> markAsDelivered({
    required String shipmentId,
    DateTime? actualDeliveryDate,
    String? proofOfDeliveryUrl,
    String? recipientName,
    String? recipientSignature,
  });

  Future<ShipmentModel> cancelShipment({
    required String shipmentId,
    String? reason,
  });

  Future<ShipmentModel> updateShipment({
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
  });
}

/// Implementation of ShipmentRemoteDataSource using Supabase
class ShipmentRemoteDataSourceImplV2 implements ShipmentRemoteDataSourceV2 {
  final SupabaseClient client;

  ShipmentRemoteDataSourceImplV2(this.client);

  @override
  Future<List<ShipmentModel>> getShipments({
    String? status,
    String? driverId,
    String? orderId,
  }) async {
    try {
      var query = client.from('shipments').select();

      // Apply filters
      if (status != null) {
        query = query.eq('status', status);
      }
      if (driverId != null) {
        query = query.eq('driver_id', driverId);
      }
      if (orderId != null) {
        query = query.eq('order_id', orderId);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => ShipmentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ShipmentModel> getShipmentById(String id) async {
    try {
      final response = await client
          .from('shipments')
          .select()
          .eq('id', id)
          .single();

      return ShipmentModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw NotFoundException('Shipment not found');
      }
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ShipmentModel> createShipment({
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
      final data = {
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

      final response = await client
          .from('shipments')
          .insert(data)
          .select()
          .single();

      return ShipmentModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ShipmentModel> assignDriver({
    required String shipmentId,
    required String driverId,
    required String driverName,
    String? vehiclePlate,
  }) async {
    try {
      final data = {
        'driver_id': driverId,
        'driver_name': driverName,
        'vehicle_plate': vehiclePlate,
        'status': 'assigned',
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await client
          .from('shipments')
          .update(data)
          .eq('id', shipmentId)
          .select()
          .single();

      return ShipmentModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw NotFoundException('Shipment not found');
      }
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ShipmentModel> updateShipmentStatus({
    required String shipmentId,
    required String status,
    DateTime? actualPickupDate,
    DateTime? actualDeliveryDate,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (actualPickupDate != null) {
        data['actual_pickup_date'] = actualPickupDate.toIso8601String();
      }
      if (actualDeliveryDate != null) {
        data['actual_delivery_date'] = actualDeliveryDate.toIso8601String();
      }
      if (notes != null) {
        data['notes'] = notes;
      }

      final response = await client
          .from('shipments')
          .update(data)
          .eq('id', shipmentId)
          .select()
          .single();

      return ShipmentModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw NotFoundException('Shipment not found');
      }
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ShipmentModel> markAsPickedUp({
    required String shipmentId,
    DateTime? actualPickupDate,
  }) async {
    try {
      final data = {
        'status': 'in_transit',
        'actual_pickup_date': (actualPickupDate ?? DateTime.now())
            .toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await client
          .from('shipments')
          .update(data)
          .eq('id', shipmentId)
          .select()
          .single();

      return ShipmentModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw NotFoundException('Shipment not found');
      }
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ShipmentModel> markAsDelivered({
    required String shipmentId,
    DateTime? actualDeliveryDate,
    String? proofOfDeliveryUrl,
    String? recipientName,
    String? recipientSignature,
  }) async {
    try {
      final data = {
        'status': 'delivered',
        'actual_delivery_date': (actualDeliveryDate ?? DateTime.now())
            .toIso8601String(),
        'proof_of_delivery_url': proofOfDeliveryUrl,
        'recipient_name': recipientName,
        'recipient_signature': recipientSignature,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await client
          .from('shipments')
          .update(data)
          .eq('id', shipmentId)
          .select()
          .single();

      return ShipmentModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw NotFoundException('Shipment not found');
      }
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ShipmentModel> cancelShipment({
    required String shipmentId,
    String? reason,
  }) async {
    try {
      final data = {
        'status': 'cancelled',
        'notes': reason,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await client
          .from('shipments')
          .update(data)
          .eq('id', shipmentId)
          .select()
          .single();

      return ShipmentModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw NotFoundException('Shipment not found');
      }
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ShipmentModel> updateShipment({
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
      final data = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (pickupAddress != null) data['pickup_address'] = pickupAddress;
      if (deliveryAddress != null) data['delivery_address'] = deliveryAddress;
      if (pickupLatitude != null) data['pickup_latitude'] = pickupLatitude;
      if (pickupLongitude != null) data['pickup_longitude'] = pickupLongitude;
      if (deliveryLatitude != null)
        data['delivery_latitude'] = deliveryLatitude;
      if (deliveryLongitude != null) {
        data['delivery_longitude'] = deliveryLongitude;
      }
      if (scheduledPickupDate != null) {
        data['scheduled_pickup_date'] = scheduledPickupDate.toIso8601String();
      }
      if (estimatedDeliveryDate != null) {
        data['estimated_delivery_date'] = estimatedDeliveryDate
            .toIso8601String();
      }
      if (notes != null) data['notes'] = notes;

      final response = await client
          .from('shipments')
          .update(data)
          .eq('id', shipmentId)
          .select()
          .single();

      return ShipmentModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw NotFoundException('Shipment not found');
      }
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
