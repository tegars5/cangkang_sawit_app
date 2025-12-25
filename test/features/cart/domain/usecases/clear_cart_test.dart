import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cangkang_sawit_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:cangkang_sawit_app/features/cart/domain/usecases/clear_cart.dart';
import 'package:cangkang_sawit_app/core/error/failures.dart';
import 'package:cangkang_sawit_app/core/usecases/usecase.dart';

import 'clear_cart_test.mocks.dart';

@GenerateMocks([CartRepository])
void main() {
  late ClearCart useCase;
  late MockCartRepository mockRepository;

  setUp(() {
    mockRepository = MockCartRepository();
    useCase = ClearCart(mockRepository);
  });

  group('ClearCart', () {
    test('should clear all items from cart successfully', () async {
      // Arrange
      when(
        mockRepository.clearCart(),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, const Right(null));
      verify(mockRepository.clearCart());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when clearing fails', () async {
      // Arrange
      final tFailure = CacheFailure();
      when(mockRepository.clearCart()).thenAnswer((_) async => Left(tFailure));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, Left(tFailure));
      verify(mockRepository.clearCart());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should succeed even if cart is already empty', () async {
      // Arrange
      when(
        mockRepository.clearCart(),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, const Right(null));
      verify(mockRepository.clearCart());
    });
  });
}
