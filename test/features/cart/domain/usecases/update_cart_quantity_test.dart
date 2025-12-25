import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cangkang_sawit_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:cangkang_sawit_app/features/cart/domain/usecases/update_cart_quantity.dart';
import 'package:cangkang_sawit_app/core/error/failures.dart';

import 'update_cart_quantity_test.mocks.dart';

@GenerateMocks([CartRepository])
void main() {
  late UpdateCartQuantity useCase;
  late MockCartRepository mockRepository;

  setUp(() {
    mockRepository = MockCartRepository();
    useCase = UpdateCartQuantity(mockRepository);
  });

  group('UpdateCartQuantity', () {
    const tProductId = 'prod-1';
    const tQuantity = 15;

    test('should update quantity successfully', () async {
      // Arrange
      when(
        mockRepository.updateQuantity(any, any),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(
        UpdateCartQuantityParams(productId: tProductId, quantity: tQuantity),
      );

      // Assert
      expect(result, const Right(null));
      verify(mockRepository.updateQuantity(tProductId, tQuantity));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when update fails', () async {
      // Arrange
      final tFailure = CacheFailure();
      when(
        mockRepository.updateQuantity(any, any),
      ).thenAnswer((_) async => Left(tFailure));

      // Act
      final result = await useCase(
        UpdateCartQuantityParams(productId: tProductId, quantity: tQuantity),
      );

      // Assert
      expect(result, Left(tFailure));
      verify(mockRepository.updateQuantity(tProductId, tQuantity));
    });

    test('should return validation error for zero quantity', () async {
      // Act
      final result = await useCase(
        const UpdateCartQuantityParams(productId: tProductId, quantity: 0),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (r) => fail('Should be Left'),
      );
      verifyNever(mockRepository.updateQuantity(any, any));
    });
  });
}
