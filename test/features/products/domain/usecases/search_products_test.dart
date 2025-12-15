import 'package:cangkang_sawit_app/core/error/failures.dart';
import 'package:cangkang_sawit_app/features/products/domain/entities/product.dart';
import 'package:cangkang_sawit_app/features/products/domain/repositories/product_repository.dart';
import 'package:cangkang_sawit_app/features/products/domain/usecases/search_products.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'search_products_test.mocks.dart';

@GenerateMocks([ProductRepository])
void main() {
  late SearchProducts usecase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    usecase = SearchProducts(mockRepository);
  });

  const testQuery = 'palm';
  final testProducts = [
    const Product(
      id: '1',
      name: 'Palm Shell Grade A',
      description: 'High quality palm shell',
      pricePerTon: 500000,
      stockAvailable: 100,
      minimumOrder: 5,
      category: 'Palm Shell',
    ),
  ];

  group('SearchProducts UseCase', () {
    test('should return products when search succeeds', () async {
      // arrange
      when(
        mockRepository.searchProducts(any),
      ).thenAnswer((_) async => Right(testProducts));

      // act
      final result = await usecase(
        const SearchProductsParams(query: testQuery),
      );

      // assert
      expect(result, Right(testProducts));
      verify(mockRepository.searchProducts(testQuery));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no products match query', () async {
      // arrange
      when(
        mockRepository.searchProducts(any),
      ).thenAnswer((_) async => const Right([]));

      // act
      final result = await usecase(
        const SearchProductsParams(query: testQuery),
      );

      // assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return empty list'),
        (products) => expect(products, isEmpty),
      );
      verify(mockRepository.searchProducts(testQuery));
    });

    test('should return ValidationFailure when query is empty', () async {
      // act
      final result = await usecase(const SearchProductsParams(query: ''));

      // assert
      expect(
        result,
        const Left(ValidationFailure('Search query cannot be empty')),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should return ValidationFailure when query is too short', () async {
      // act
      final result = await usecase(const SearchProductsParams(query: 'a'));

      // assert
      expect(
        result,
        const Left(
          ValidationFailure('Search query must be at least 2 characters'),
        ),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      // arrange
      when(
        mockRepository.searchProducts(any),
      ).thenAnswer((_) async => const Left(ServerFailure('Search failed')));

      // act
      final result = await usecase(
        const SearchProductsParams(query: testQuery),
      );

      // assert
      expect(result, const Left(ServerFailure('Search failed')));
    });

    test('should handle special characters in query', () async {
      // arrange
      const specialQuery = 'palm@#\$%';
      when(
        mockRepository.searchProducts(any),
      ).thenAnswer((_) async => Right(testProducts));

      // act
      final result = await usecase(
        const SearchProductsParams(query: specialQuery),
      );

      // assert
      expect(result, Right(testProducts));
      verify(mockRepository.searchProducts(specialQuery));
    });
  });
}
