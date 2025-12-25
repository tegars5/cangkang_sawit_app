import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/driver_location.dart';
import '../repositories/tracking_repository.dart';

/// Use case for subscribing to real-time driver location updates
class SubscribeDriverLocation {
  final TrackingRepository repository;

  SubscribeDriverLocation(this.repository);

  Stream<Either<Failure, DriverLocation>> call(
    SubscribeDriverLocationParams params,
  ) {
    // Validation
    if (params.shipmentId.isEmpty) {
      return Stream.value(
        Left(ValidationFailure('Shipment ID cannot be empty')),
      );
    }

    return repository.subscribeToDriverLocation(params.shipmentId);
  }
}

/// Parameters for SubscribeDriverLocation use case
class SubscribeDriverLocationParams {
  final String shipmentId;

  const SubscribeDriverLocationParams({required this.shipmentId});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscribeDriverLocationParams &&
        other.shipmentId == shipmentId;
  }

  @override
  int get hashCode => shipmentId.hashCode;
}
