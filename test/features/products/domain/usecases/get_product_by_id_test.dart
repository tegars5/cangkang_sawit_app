import 'package:cangkang_sawit_app/core/error/failures.dart';
import 'package:cangkang_sawit_app/features/products/domain/entities/product.dart';
import 'package:cangkang_sawit_app/features/products/domain/repositories/product_repository.dart';
import 'package:cangkang_sawit_app/features/products/domain/usecases/get_product_by_id.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_product_by_id_test.mocks.dart';

@GenerateMocks([ProductRepository])
void main() {
  late GetProductById usecase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    usecase = GetProductById(mockRepository);
  });

  const testProductId = '123';
  const testProduct = Product(
    id: testProductId,
    name: 'Palm Shell Grade A',
    description: 'High quality palm shell',
    pricePerTon: 500000,
    stockAvailable: 100,
    minimumOrder: 5,
    category: 'Palm Shell',
  );

  group('GetProductById UseCase', () {
    test('should return product when repository succeeds', () async {
      // arrange
      when(
        mockRepository.getProductById(any),
      ).thenAnswer((_) async => const Right(testProduct));

      // act
      final result = await usecase(
        const GetProductByIdParams(id: testProductId),
      );

      // assert
      expect(result, const Right(testProduct));
      verify(mockRepository.getProductById(testProductId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when ID is empty', () async {
      // act
      final result = await usecase(const GetProductByIdParams(id: ''));

      // assert
      expect(
        result,
        const Left(ValidationFailure('Product ID cannot be empty')),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should return NotFoundFailure when product does not exist', () async {
      // arrange
      when(mockRepository.getProductById(any)).thenAnswer(
        (_) async => const Left(NotFoundFailure('Product not found')),
      );

      // act
      final result = await usecase(
        const GetProductByIdParams(id: testProductId),
      );

      // assert
      expect(result, const Left(NotFoundFailure('Product not found')));
      verify(mockRepository.getProductById(testProductId));
    });

    test('should return ServerFailure when repository fails', () async {
      // arrange
      when(
        mockRepository.getProductById(any),
      ).thenAnswer((_) async => const Left(ServerFailure('Server error')));

      // act
      final result = await usecase(
        const GetProductByIdParams(id: testProductId),
      );

      // assert
      expect(result, const Left(ServerFailure('Server error')));
    });
  });
}
