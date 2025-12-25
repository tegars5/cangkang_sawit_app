import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cangkang_sawit_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:cangkang_sawit_app/features/cart/domain/usecases/remove_from_cart.dart';
import 'package:cangkang_sawit_app/core/error/failures.dart';

import 'remove_from_cart_test.mocks.dart';

@GenerateMocks([CartRepository])
void main() {
  late RemoveFromCart useCase;
  late MockCartRepository mockRepository;

  setUp(() {
    mockRepository = MockCartRepository();
    useCase = RemoveFromCart(mockRepository);
  });

  group('RemoveFromCart', () {
    const tProductId = 'prod-1';

    test('should remove item from cart successfully', () async {
      // Arrange
      when(
        mockRepository.removeFromCart(any),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(
        const RemoveFromCartParams(productId: tProductId),
      );

      // Assert
      expect(result, const Right(null));
      verify(mockRepository.removeFromCart(tProductId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when removal fails', () async {
      // Arrange
      const tFailure = CacheFailure();
      when(
        mockRepository.removeFromCart(any),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(
        const RemoveFromCartParams(productId: tProductId),
      );

      // Assert
      expect(result, const Left(tFailure));
      verify(mockRepository.removeFromCart(tProductId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should succeed even if item does not exist', () async {
      // Arrange
      when(
        mockRepository.removeFromCart(any),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(
        const RemoveFromCartParams(productId: 'non-existent-id'),
      );

      // Assert
      expect(result, const Right(null));
      verify(mockRepository.removeFromCart('non-existent-id'));
    });
  });
}
