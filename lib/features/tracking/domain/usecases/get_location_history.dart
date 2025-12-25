import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/driver_location.dart';
import '../repositories/tracking_repository.dart';

/// Use case for getting location history
class GetLocationHistory
    implements UseCase<List<DriverLocation>, GetLocationHistoryParams> {
  final TrackingRepository repository;

  GetLocationHistory(this.repository);

  @override
  Future<Either<Failure, List<DriverLocation>>> call(
    GetLocationHistoryParams params,
  ) async {
    // Validation
    if (params.shipmentId.isEmpty) {
      return Left(ValidationFailure('Shipment ID cannot be empty'));
    }

    if (params.limit <= 0) {
      return Left(ValidationFailure('Limit must be greater than 0'));
    }

    return await repository.getLocationHistory(
      params.shipmentId,
      limit: params.limit,
    );
  }
}

/// Parameters for GetLocationHistory use case
class GetLocationHistoryParams {
  final String shipmentId;
  final int limit;

  const GetLocationHistoryParams({required this.shipmentId, this.limit = 100});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetLocationHistoryParams &&
        other.shipmentId == shipmentId &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(shipmentId, limit);
}
