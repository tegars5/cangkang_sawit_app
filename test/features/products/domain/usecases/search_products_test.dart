import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cangkang_sawit_app/features/products/domain/entities/product.dart';
import 'package:cangkang_sawit_app/features/products/domain/repositories/product_repository.dart';
import 'package:cangkang_sawit_app/features/products/domain/usecases/search_products.dart';
import 'package:cangkang_sawit_app/core/error/failures.dart';

import 'search_products_test.mocks.dart';

@GenerateMocks([ProductRepository])
void main() {
  late SearchProducts useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = SearchProducts(mockRepository);
  });

  group('SearchProducts', () {
    const tQuery = 'Grade A';
    final tProducts = [
      Product(
        id: '1',
        name: 'Cangkang Sawit Grade A',
        description: 'High quality palm kernel shell',
        pricePerTon: 150000,
        stockAvailable: 100,
        minimumOrder: 10,
        category: 'Grade A',
        imageUrl: 'https://example.com/image1.jpg',
        isActive: true,
      ),
    ];

    test('should search products successfully', () async {
      // Arrange
      when(
        mockRepository.searchProducts(any),
      ).thenAnswer((_) async => Right(tProducts));

      // Act
      final result = await useCase(const SearchProductsParams(query: tQuery));

      // Assert
      expect(result, Right(tProducts));
      verify(mockRepository.searchProducts(tQuery));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no matches found', () async {
      // Arrange
      when(
        mockRepository.searchProducts(any),
      ).thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(
        const SearchProductsParams(query: 'Non-existent'),
      );

      // Assert
      expect(result.isRight(), true);
      result.fold((l) => fail('Should be Right'), (r) => expect(r, isEmpty));
      verify(mockRepository.searchProducts('Non-existent'));
    });

    test('should return failure when search fails', () async {
      // Arrange
      const tFailure = ServerFailure('Search failed');
      when(
        mockRepository.searchProducts(any),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(const SearchProductsParams(query: tQuery));

      // Assert
      expect(result, Left(tFailure));
      verify(mockRepository.searchProducts(tQuery));
    });

    test('should return validation error for empty query', () async {
      // Act
      final result = await useCase(const SearchProductsParams(query: ''));

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (r) => fail('Should be Left'),
      );
    });
  });
}
