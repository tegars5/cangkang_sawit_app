import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Use case to get product by ID
class GetProductById implements UseCase<Product, GetProductByIdParams> {
  final ProductRepository repository;

  GetProductById(this.repository);

  @override
  Future<Either<Failure, Product>> call(GetProductByIdParams params) async {
    if (params.id.isEmpty) {
      return const Left(ValidationFailure('Product ID cannot be empty'));
    }

    return await repository.getProductById(params.id);
  }
}

class GetProductByIdParams {
  final String id;

  const GetProductByIdParams({required this.id});
}
