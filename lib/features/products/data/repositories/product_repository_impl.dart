import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

/// Implementation of ProductRepository
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final products = await remoteDataSource.getProducts();
      return Right(products.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(String id) async {
    try {
      final product = await remoteDataSource.getProductById(id);
      return Right(product.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> searchProducts(String query) async {
    try {
      final products = await remoteDataSource.searchProducts(query);
      return Right(products.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct({
    required String name,
    String? description,
    required double pricePerTon,
    double? stockAvailable,
    double? minimumOrder,
    String? category,
    String? specifications,
  }) async {
    try {
      final product = await remoteDataSource.createProduct(
        name: name,
        description: description,
        pricePerTon: pricePerTon,
        stockAvailable: stockAvailable,
        minimumOrder: minimumOrder,
        category: category,
        specifications: specifications,
      );
      return Right(product.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct({
    required String id,
    String? name,
    String? description,
    double? pricePerTon,
    double? stockAvailable,
    double? minimumOrder,
    bool? isActive,
  }) async {
    try {
      final product = await remoteDataSource.updateProduct(
        id: id,
        name: name,
        description: description,
        pricePerTon: pricePerTon,
        stockAvailable: stockAvailable,
        minimumOrder: minimumOrder,
        isActive: isActive,
      );
      return Right(product.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await remoteDataSource.deleteProduct(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
