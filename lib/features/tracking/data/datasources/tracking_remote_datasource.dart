import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/driver_location_model.dart';

/// Abstract interface for Tracking remote data source
abstract class TrackingRemoteDataSource {
  Stream<DriverLocationModel> subscribeToDriverLocation(String shipmentId);
  Future<DriverLocationModel> getCurrentLocation(String driverId);
  Future<List<DriverLocationModel>> getLocationHistory(
    String shipmentId, {
    int limit = 100,
  });
  Future<DriverLocationModel> updateDriverLocation(
    DriverLocationModel location,
  );
  Future<Map<String, DriverLocationModel>> getMultipleDriverLocations(
    List<String> driverIds,
  );
  Future<void> stopTracking(String shipmentId);
}

/// Implementation of TrackingRemoteDataSource using Supabase Realtime
class TrackingRemoteDataSourceImpl implements TrackingRemoteDataSource {
  final SupabaseClient client;
  final Map<String, RealtimeChannel> _activeChannels = {};
  final Map<String, StreamController<DriverLocationModel>> _controllers = {};

  TrackingRemoteDataSourceImpl({required this.client});

  @override
  Stream<DriverLocationModel> subscribeToDriverLocation(String shipmentId) {
    try {
      // Check if already subscribed
      if (_controllers.containsKey(shipmentId)) {
        return _controllers[shipmentId]!.stream;
      }

      // Create new stream controller
      final controller = StreamController<DriverLocationModel>.broadcast();
      _controllers[shipmentId] = controller;

      // Subscribe to Supabase Realtime
      final channel = client
          .channel('driver_location_$shipmentId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'driver_locations',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'shipment_id',
              value: shipmentId,
            ),
            callback: (payload) {
              try {
                final location = DriverLocationModel.fromJson(
                  payload.newRecord,
                );
                controller.add(location);
              } catch (e) {
                controller.addError(
                  ServerException('Failed to parse location update: $e'),
                );
              }
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'driver_locations',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'shipment_id',
              value: shipmentId,
            ),
            callback: (payload) {
              try {
                final location = DriverLocationModel.fromJson(
                  payload.newRecord,
                );
                controller.add(location);
              } catch (e) {
                controller.addError(
                  ServerException('Failed to parse location update: $e'),
                );
              }
            },
          )
          .subscribe();

      _activeChannels[shipmentId] = channel;

      // Cleanup when stream is cancelled
      controller.onCancel = () {
        stopTracking(shipmentId);
      };

      return controller.stream;
    } catch (e) {
      throw ServerException('Failed to subscribe to driver location: $e');
    }
  }

  @override
  Future<DriverLocationModel> getCurrentLocation(String driverId) async {
    try {
      final response = await client
          .from('driver_locations')
          .select()
          .eq('driver_id', driverId)
          .order('timestamp', ascending: false)
          .limit(1)
          .single();

      return DriverLocationModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw NotFoundException('Driver location not found');
      }
      throw ServerException('Failed to get current location: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get current location: $e');
    }
  }

  @override
  Future<List<DriverLocationModel>> getLocationHistory(
    String shipmentId, {
    int limit = 100,
  }) async {
    try {
      final response = await client
          .from('driver_locations')
          .select()
          .eq('shipment_id', shipmentId)
          .order('timestamp', ascending: false)
          .limit(limit);

      return (response as List)
          .map(
            (json) =>
                DriverLocationModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Failed to get location history: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get location history: $e');
    }
  }

  @override
  Future<DriverLocationModel> updateDriverLocation(
    DriverLocationModel location,
  ) async {
    try {
      final response = await client
          .from('driver_locations')
          .insert(location.toJson())
          .select()
          .single();

      return DriverLocationModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to update driver location: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to update driver location: $e');
    }
  }

  @override
  Future<Map<String, DriverLocationModel>> getMultipleDriverLocations(
    List<String> driverIds,
  ) async {
    try {
      final response = await client
          .from('driver_locations')
          .select()
          .inFilter('driver_id', driverIds)
          .order('timestamp', ascending: false);

      final locations = <String, DriverLocationModel>{};
      final list = response as List;

      for (final json in list) {
        final location = DriverLocationModel.fromJson(
          json as Map<String, dynamic>,
        );
        // Keep only the latest location for each driver
        if (!locations.containsKey(location.driverId)) {
          locations[location.driverId] = location;
        }
      }

      return locations;
    } on PostgrestException catch (e) {
      throw ServerException('Failed to get multiple locations: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get multiple locations: $e');
    }
  }

  @override
  Future<void> stopTracking(String shipmentId) async {
    try {
      // Remove and unsubscribe channel
      final channel = _activeChannels.remove(shipmentId);
      if (channel != null) {
        await client.removeChannel(channel);
      }

      // Close and remove controller
      final controller = _controllers.remove(shipmentId);
      if (controller != null && !controller.isClosed) {
        await controller.close();
      }
    } catch (e) {
      throw ServerException('Failed to stop tracking: $e');
    }
  }

  /// Cleanup all active subscriptions
  Future<void> dispose() async {
    final shipmentIds = List<String>.from(_activeChannels.keys);
    for (final shipmentId in shipmentIds) {
      await stopTracking(shipmentId);
    }
  }
}
