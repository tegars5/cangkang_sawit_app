import 'package:dartz/dartz.dart' hide Order;
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../orders/domain/entities/order.dart';
import '../repositories/admin_repository.dart';

/// Get All Orders Use Case
/// Retrieves all orders with optional filtering
class GetAllOrders implements UseCase<List<Order>, GetAllOrdersParams> {
  final AdminRepository repository;

  GetAllOrders(this.repository);

  @override
  Future<Either<Failure, List<Order>>> call(GetAllOrdersParams params) async {
    return await repository.getAllOrders(
      status: params.status,
      startDate: params.startDate,
      endDate: params.endDate,
      limit: params.limit,
    );
  }
}

class GetAllOrdersParams extends Equatable {
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? limit;

  const GetAllOrdersParams({
    this.status,
    this.startDate,
    this.endDate,
    this.limit,
  });

  @override
  List<Object?> get props => [status, startDate, endDate, limit];
}
