import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cangkang_sawit_app/features/cart/domain/entities/cart_item.dart';
import 'package:cangkang_sawit_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:cangkang_sawit_app/features/cart/domain/usecases/get_cart_items.dart';
import 'package:cangkang_sawit_app/core/error/failures.dart';
import 'package:cangkang_sawit_app/core/usecases/usecase.dart';

import 'get_cart_items_test.mocks.dart';

@GenerateMocks([CartRepository])
void main() {
  late GetCartItems useCase;
  late MockCartRepository mockRepository;

  setUp(() {
    mockRepository = MockCartRepository();
    useCase = GetCartItems(mockRepository);
  });

  group('GetCartItems', () {
    final tCartItems = [
      CartItem(
        productId: 'prod-1',
        productName: 'Cangkang Sawit Grade A',
        quantity: 10,
        price: 150000,
        imageUrl: 'https://example.com/image.jpg',
        addedAt: DateTime(2024, 1, 1),
      ),
      CartItem(
        productId: 'prod-2',
        productName: 'Cangkang Sawit Grade B',
        quantity: 5,
        price: 120000,
        imageUrl: 'https://example.com/image2.jpg',
        addedAt: DateTime(2024, 1, 2),
      ),
    ];

    test('should get cart items from repository', () async {
      // Arrange
      when(
        mockRepository.getCartItems(),
      ).thenAnswer((_) async => Right(tCartItems));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, Right(tCartItems));
      verify(mockRepository.getCartItems());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final tFailure = CacheFailure();
      when(
        mockRepository.getCartItems(),
      ).thenAnswer((_) async => Left(tFailure));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, Left(tFailure));
      verify(mockRepository.getCartItems());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when cart is empty', () async {
      // Arrange
      when(
        mockRepository.getCartItems(),
      ).thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isRight(), true);
      result.fold((l) => fail('Should be Right'), (r) => expect(r, isEmpty));
      verify(mockRepository.getCartItems());
    });
  });
}
