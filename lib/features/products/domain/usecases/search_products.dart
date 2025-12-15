import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Use case to search products by name
class SearchProducts implements UseCase<List<Product>, SearchProductsParams> {
  final ProductRepository repository;

  SearchProducts(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(
    SearchProductsParams params,
  ) async {
    if (params.query.isEmpty) {
      return const Left(ValidationFailure('Search query cannot be empty'));
    }

    if (params.query.length < 2) {
      return const Left(
        ValidationFailure('Search query must be at least 2 characters'),
      );
    }

    return await repository.searchProducts(params.query);
  }
}

class SearchProductsParams {
  final String query;

  const SearchProductsParams({required this.query});
}
