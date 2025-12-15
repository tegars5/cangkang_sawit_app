import 'package:cangkang_sawit_app/core/error/exceptions.dart';
import 'package:cangkang_sawit_app/core/error/failures.dart';
import 'package:cangkang_sawit_app/features/products/data/datasources/product_remote_datasource.dart';
import 'package:cangkang_sawit_app/features/products/data/models/product_model.dart';
import 'package:cangkang_sawit_app/features/products/data/repositories/product_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'product_repository_impl_test.mocks.dart';

@GenerateMocks([ProductRemoteDataSource])
void main() {
  late ProductRepositoryImpl repository;
  late MockProductRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockProductRemoteDataSource();
    repository = ProductRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  final testProductModel = ProductModel(
    id: '1',
    name: 'Palm Shell Grade A',
    description: 'High quality palm shell',
    pricePerTon: 500000,
    stockAvailable: 100,
    minimumOrder: 5,
    category: 'Palm Shell',
    isActive: true,
    createdAt: DateTime.now(),
  );

  final testProductModels = [testProductModel];

  group('getProducts', () {
    test(
      'should return list of products when remote data source succeeds',
      () async {
        // arrange
        when(
          mockRemoteDataSource.getProducts(),
        ).thenAnswer((_) async => testProductModels);

        // act
        final result = await repository.getProducts();

        // assert
        expect(result.isRight(), true);
        result.fold((_) => fail('Should return products'), (products) {
          expect(products.length, testProductModels.length);
          expect(products.first.id, testProductModel.id);
          expect(products.first.name, testProductModel.name);
        });
        verify(mockRemoteDataSource.getProducts());
      },
    );

    test(
      'should return ServerFailure when remote data source throws ServerException',
      () async {
        // arrange
        when(
          mockRemoteDataSource.getProducts(),
        ).thenThrow(const ServerException('Failed to fetch'));

        // act
        final result = await repository.getProducts();

        // assert
        expect(result, const Left(ServerFailure('Failed to fetch')));
      },
    );

    test('should return ServerFailure when unexpected error occurs', () async {
      // arrange
      when(
        mockRemoteDataSource.getProducts(),
      ).thenThrow(Exception('Unexpected'));

      // act
      final result = await repository.getProducts();

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('getProductById', () {
    const testId = '1';

    test('should return product when remote data source succeeds', () async {
      // arrange
      when(
        mockRemoteDataSource.getProductById(any),
      ).thenAnswer((_) async => testProductModel);

      // act
      final result = await repository.getProductById(testId);

      // assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should return product'), (product) {
        expect(product.id, testProductModel.id);
        expect(product.name, testProductModel.name);
      });
      verify(mockRemoteDataSource.getProductById(testId));
    });

    test('should return NotFoundFailure when product does not exist', () async {
      // arrange
      when(
        mockRemoteDataSource.getProductById(any),
      ).thenThrow(const NotFoundException('Product not found'));

      // act
      final result = await repository.getProductById(testId);

      // assert
      expect(result, const Left(NotFoundFailure('Product not found')));
    });

    test('should return ServerFailure when server error occurs', () async {
      // arrange
      when(
        mockRemoteDataSource.getProductById(any),
      ).thenThrow(const ServerException('Server error'));

      // act
      final result = await repository.getProductById(testId);

      // assert
      expect(result, const Left(ServerFailure('Server error')));
    });
  });

  group('searchProducts', () {
    const testQuery = 'palm';

    test('should return products when search succeeds', () async {
      // arrange
      when(
        mockRemoteDataSource.searchProducts(any),
      ).thenAnswer((_) async => testProductModels);

      // act
      final result = await repository.searchProducts(testQuery);

      // assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return products'),
        (products) => expect(products.length, testProductModels.length),
      );
      verify(mockRemoteDataSource.searchProducts(testQuery));
    });

    test('should return empty list when no products match', () async {
      // arrange
      when(
        mockRemoteDataSource.searchProducts(any),
      ).thenAnswer((_) async => []);

      // act
      final result = await repository.searchProducts(testQuery);

      // assert
      expect(result, const Right([]));
    });

    test('should return ServerFailure when search fails', () async {
      // arrange
      when(
        mockRemoteDataSource.searchProducts(any),
      ).thenThrow(const ServerException('Search failed'));

      // act
      final result = await repository.searchProducts(testQuery);

      // assert
      expect(result, const Left(ServerFailure('Search failed')));
    });
  });

  group('createProduct', () {
    test('should return created product when creation succeeds', () async {
      // arrange
      when(
        mockRemoteDataSource.createProduct(
          name: anyNamed('name'),
          description: anyNamed('description'),
          pricePerTon: anyNamed('pricePerTon'),
          stockAvailable: anyNamed('stockAvailable'),
          minimumOrder: anyNamed('minimumOrder'),
          category: anyNamed('category'),
          specifications: anyNamed('specifications'),
        ),
      ).thenAnswer((_) async => testProductModel);

      // act
      final result = await repository.createProduct(
        name: 'Test Product',
        pricePerTon: 500000,
      );

      // assert
      expect(result.isRight(), true);
      verify(
        mockRemoteDataSource.createProduct(
          name: 'Test Product',
          pricePerTon: 500000,
        ),
      );
    });

    test('should return ServerFailure when creation fails', () async {
      // arrange
      when(
        mockRemoteDataSource.createProduct(
          name: anyNamed('name'),
          description: anyNamed('description'),
          pricePerTon: anyNamed('pricePerTon'),
          stockAvailable: anyNamed('stockAvailable'),
          minimumOrder: anyNamed('minimumOrder'),
          category: anyNamed('category'),
          specifications: anyNamed('specifications'),
        ),
      ).thenThrow(const ServerException('Creation failed'));

      // act
      final result = await repository.createProduct(
        name: 'Test Product',
        pricePerTon: 500000,
      );

      // assert
      expect(result, const Left(ServerFailure('Creation failed')));
    });
  });

  group('updateProduct', () {
    const testId = '1';

    test('should return updated product when update succeeds', () async {
      // arrange
      when(
        mockRemoteDataSource.updateProduct(
          id: anyNamed('id'),
          name: anyNamed('name'),
          description: anyNamed('description'),
          pricePerTon: anyNamed('pricePerTon'),
          stockAvailable: anyNamed('stockAvailable'),
          minimumOrder: anyNamed('minimumOrder'),
          isActive: anyNamed('isActive'),
        ),
      ).thenAnswer((_) async => testProductModel);

      // act
      final result = await repository.updateProduct(
        id: testId,
        name: 'Updated Product',
      );

      // assert
      expect(result.isRight(), true);
      verify(
        mockRemoteDataSource.updateProduct(id: testId, name: 'Updated Product'),
      );
    });

    test('should return ServerFailure when update fails', () async {
      // arrange
      when(
        mockRemoteDataSource.updateProduct(
          id: anyNamed('id'),
          name: anyNamed('name'),
          description: anyNamed('description'),
          pricePerTon: anyNamed('pricePerTon'),
          stockAvailable: anyNamed('stockAvailable'),
          minimumOrder: anyNamed('minimumOrder'),
          isActive: anyNamed('isActive'),
        ),
      ).thenThrow(const ServerException('Update failed'));

      // act
      final result = await repository.updateProduct(
        id: testId,
        name: 'Updated Product',
      );

      // assert
      expect(result, const Left(ServerFailure('Update failed')));
    });
  });

  group('deleteProduct', () {
    const testId = '1';

    test('should return Right(null) when deletion succeeds', () async {
      // arrange
      when(mockRemoteDataSource.deleteProduct(any)).thenAnswer((_) async => {});

      // act
      final result = await repository.deleteProduct(testId);

      // assert
      expect(result, const Right(null));
      verify(mockRemoteDataSource.deleteProduct(testId));
    });

    test('should return ServerFailure when deletion fails', () async {
      // arrange
      when(
        mockRemoteDataSource.deleteProduct(any),
      ).thenThrow(const ServerException('Deletion failed'));

      // act
      final result = await repository.deleteProduct(testId);

      // assert
      expect(result, const Left(ServerFailure('Deletion failed')));
    });
  });
}
