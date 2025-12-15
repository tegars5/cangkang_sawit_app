import 'package:cangkang_sawit_app/core/error/failures.dart';
import 'package:cangkang_sawit_app/core/usecases/usecase.dart';
import 'package:cangkang_sawit_app/features/products/domain/entities/product.dart';
import 'package:cangkang_sawit_app/features/products/domain/repositories/product_repository.dart';
import 'package:cangkang_sawit_app/features/products/domain/usecases/get_products.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_products_test.mocks.dart';

@GenerateMocks([ProductRepository])
void main() {
  late GetProducts usecase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    usecase = GetProducts(mockRepository);
  });

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
    const Product(
      id: '2',
      name: 'Palm Shell Grade B',
      description: 'Standard quality palm shell',
      pricePerTon: 450000,
      stockAvailable: 50,
      minimumOrder: 10,
      category: 'Palm Shell',
    ),
  ];

  group('GetProducts UseCase', () {
    test('should return list of products when repository succeeds', () async {
      // arrange
      when(
        mockRepository.getProducts(),
      ).thenAnswer((_) async => Right(testProducts));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, Right(testProducts));
      verify(mockRepository.getProducts());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no products available', () async {
      // arrange
      when(
        mockRepository.getProducts(),
      ).thenAnswer((_) async => const Right([]));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return empty list'),
        (products) => expect(products, isEmpty),
      );
      verify(mockRepository.getProducts());
    });

    test('should return ServerFailure when repository fails', () async {
      // arrange
      when(mockRepository.getProducts()).thenAnswer(
        (_) async => const Left(ServerFailure('Failed to fetch products')),
      );

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(ServerFailure('Failed to fetch products')));
      verify(mockRepository.getProducts());
    });

    test('should return NotFoundFailure when products not found', () async {
      // arrange
      when(mockRepository.getProducts()).thenAnswer(
        (_) async => const Left(NotFoundFailure('Products not found')),
      );

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(NotFoundFailure('Products not found')));
    });
  });
}
