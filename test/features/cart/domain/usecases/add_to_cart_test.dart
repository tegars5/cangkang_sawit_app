import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cangkang_sawit_app/features/cart/domain/entities/cart_item.dart';
import 'package:cangkang_sawit_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:cangkang_sawit_app/features/cart/domain/usecases/add_to_cart.dart';
import 'package:cangkang_sawit_app/core/error/failures.dart';

import 'add_to_cart_test.mocks.dart';

@GenerateMocks([CartRepository])
void main() {
  late AddToCart useCase;
  late MockCartRepository mockRepository;

  setUp(() {
    mockRepository = MockCartRepository();
    useCase = AddToCart(mockRepository);
  });

  group('AddToCart', () {
    final tCartItem = CartItem(
      productId: 'prod-1',
      productName: 'Cangkang Sawit Grade A',
      quantity: 10,
      price: 150000,
      imageUrl: 'https://example.com/image.jpg',
      addedAt: DateTime(2024, 1, 1),
    );

    test('should add item to cart successfully', () async {
      // Arrange
      when(
        mockRepository.addToCart(any),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(AddToCartParams(item: tCartItem));

      // Assert
      expect(result, const Right(null));
      verify(mockRepository.addToCart(tCartItem));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when adding item fails', () async {
      // Arrange
      const tFailure = CacheFailure();
      when(
        mockRepository.addToCart(any),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(AddToCartParams(item: tCartItem));

      // Assert
      expect(result, const Left(tFailure));
      verify(mockRepository.addToCart(tCartItem));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should merge quantities when adding existing product', () async {
      // Arrange
      when(
        mockRepository.addToCart(any),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(AddToCartParams(item: tCartItem));

      // Assert
      expect(result, const Right(null));
      verify(mockRepository.addToCart(tCartItem));
    });
  });
}
