import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/driver_location.dart';

/// Repository interface for Tracking operations
abstract class TrackingRepository {
  /// Subscribe to driver location updates (real-time stream)
  ///
  /// [shipmentId] - Shipment ID to track
  /// Returns a stream of driver locations
  Stream<Either<Failure, DriverLocation>> subscribeToDriverLocation(
    String shipmentId,
  );

  /// Get driver's current location
  ///
  /// [driverId] - Driver ID
  Future<Either<Failure, DriverLocation>> getCurrentLocation(String driverId);

  /// Get location history for a shipment
  ///
  /// [shipmentId] - Shipment ID
  /// [limit] - Maximum number of locations to return (default 100)
  Future<Either<Failure, List<DriverLocation>>> getLocationHistory(
    String shipmentId, {
    int limit = 100,
  });

  /// Update driver location (for driver app)
  ///
  /// [location] - New location data
  Future<Either<Failure, DriverLocation>> updateDriverLocation(
    DriverLocation location,
  );

  /// Get latest location for multiple drivers
  ///
  /// [driverIds] - List of driver IDs
  Future<Either<Failure, Map<String, DriverLocation>>>
  getMultipleDriverLocations(List<String> driverIds);

  /// Stop tracking (unsubscribe from real-time updates)
  ///
  /// [shipmentId] - Shipment ID to stop tracking
  Future<Either<Failure, void>> stopTracking(String shipmentId);
}
