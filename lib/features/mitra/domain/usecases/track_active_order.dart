import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/mitra_repository.dart';

/// Track Active Order Use Case
/// Retrieves real-time tracking information for an active order
class TrackActiveOrder
    implements UseCase<Map<String, dynamic>, TrackActiveOrderParams> {
  final MitraRepository repository;

  TrackActiveOrder(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    TrackActiveOrderParams params,
  ) async {
    return await repository.trackActiveOrder(params.orderId);
  }
}

class TrackActiveOrderParams {
  final String orderId;

  TrackActiveOrderParams({required this.orderId});
}
