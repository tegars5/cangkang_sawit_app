import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cangkang_sawit_app/features/products/domain/entities/product.dart';
import 'package:cangkang_sawit_app/features/products/domain/repositories/product_repository.dart';
import 'package:cangkang_sawit_app/features/products/domain/usecases/get_products.dart';
import 'package:cangkang_sawit_app/core/error/failures.dart';
import 'package:cangkang_sawit_app/core/usecases/usecase.dart';

import 'get_products_test.mocks.dart';

@GenerateMocks([ProductRepository])
void main() {
  late GetProducts useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProducts(mockRepository);
  });

  group('GetProducts', () {
    final tProducts = [
      Product(
        id: '1',
        name: 'Cangkang Sawit Grade A',
        description: 'High quality palm kernel shell',
        pricePerTon: 150000,
        stockAvailable: 100,
        minimumOrder: 10,
        category: 'Grade A',
        isActive: true,
        imageUrl: 'https://example.com/image1.jpg',
      ),
      Product(
        id: '2',
        name: 'Cangkang Sawit Grade B',
        description: 'Standard quality palm kernel shell',
        pricePerTon: 120000,
        stockAvailable: 200,
        minimumOrder: 10,
        category: 'Grade B',
        imageUrl: 'https://example.com/image2.jpg',
        isActive: true,
      ),
    ];

    test('should get all products from repository', () async {
      // Arrange
      when(
        mockRepository.getProducts(),
      ).thenAnswer((_) async => Right(tProducts));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, Right(tProducts));
      verify(mockRepository.getProducts());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const tFailure = ServerFailure('Server error');
      when(
        mockRepository.getProducts(),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, Left(tFailure));
      verify(mockRepository.getProducts());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no products available', () async {
      // Arrange
      when(
        mockRepository.getProducts(),
      ).thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isRight(), true);
      result.fold((l) => fail('Should be Right'), (r) => expect(r, isEmpty));
      verify(mockRepository.getProducts());
    });
  });
}
