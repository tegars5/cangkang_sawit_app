import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/driver_repository.dart';

/// Use case for uploading proof of delivery
class UploadProofOfDelivery
    implements UseCase<String, UploadProofOfDeliveryParams> {
  final DriverRepository repository;

  UploadProofOfDelivery(this.repository);

  @override
  Future<Either<Failure, String>> call(UploadProofOfDeliveryParams params) {
    return repository.uploadProofOfDelivery(
      shipmentId: params.shipmentId,
      imagePath: params.imagePath,
    );
  }
}

class UploadProofOfDeliveryParams {
  final String shipmentId;
  final String imagePath;

  const UploadProofOfDeliveryParams({
    required this.shipmentId,
    required this.imagePath,
  });
}
