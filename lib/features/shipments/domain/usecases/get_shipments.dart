import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/models.dart';
import '../repositories/shipment_repository.dart';

/// Use case for getting shipments
class GetShipments implements UseCase<List<Shipment>, GetShipmentsParams> {
  final ShipmentRepository repository;

  GetShipments(this.repository);

  @override
  Future<dartz.Either<Failure, List<Shipment>>> call(
    GetShipmentsParams params,
  ) async {
    return await repository.getShipments(
      status: params.status,
      driverId: params.driverId,
    );
  }
}

/// Parameters for GetShipments use case
class GetShipmentsParams {
  final String? status;
  final String? driverId;

  const GetShipmentsParams({this.status, this.driverId});
}
