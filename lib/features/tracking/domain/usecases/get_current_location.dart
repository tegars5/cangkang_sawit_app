import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/driver_location.dart';
import '../repositories/tracking_repository.dart';

/// Use case for getting current driver location
class GetCurrentLocation implements UseCase<DriverLocation, String> {
  final TrackingRepository repository;

  GetCurrentLocation(this.repository);

  @override
  Future<Either<Failure, DriverLocation>> call(String driverId) async {
    // Validation
    if (driverId.isEmpty) {
      return Left(ValidationFailure('Driver ID cannot be empty'));
    }

    return await repository.getCurrentLocation(driverId);
  }
}
