import 'package:flutter_test/flutter_test.dart';
import 'package:cangkang_sawit_app/features/cart/domain/entities/cart_item.dart';

void main() {
  group('CartItem Entity', () {
    final tCartItem = CartItem(
      productId: 'prod-1',
      productName: 'Cangkang Sawit Grade A',
      quantity: 10,
      price: 150000,
      imageUrl: 'https://example.com/image.jpg',
      addedAt: DateTime(2024, 1, 1),
    );

    group('Business Logic', () {
      test('should calculate subtotal correctly', () {
        // Assert
        expect(tCartItem.subtotal, 1500000);
      });

      test('should calculate subtotal for different quantities', () {
        // Arrange
        final item = CartItem(
          productId: tCartItem.productId,
          productName: tCartItem.productName,
          price: tCartItem.price,
          quantity: 5,
          imageUrl: tCartItem.imageUrl,
          addedAt: tCartItem.addedAt,
        );

        // Assert
        expect(item.subtotal, 750000);
      });

      test('should check if quantity is valid (> 0)', () {
        // Assert
        expect(tCartItem.hasValidQuantity, true);

        final zeroQuantityItem = CartItem(
          productId: 'prod-1',
          productName: 'Test',
          price: 100,
          quantity: 0,
          addedAt: DateTime.now(),
        );
        expect(zeroQuantityItem.hasValidQuantity, false);
      });

      test('should check if can increase/decrease quantity', () {
        // Arrange
        final itemWithStock = CartItem(
          productId: 'prod-1',
          productName: 'Test',
          price: 100,
          quantity: 5,
          stock: 10,
          addedAt: DateTime.now(),
        );

        // Assert
        expect(itemWithStock.canIncreaseQuantity(), true);
        expect(itemWithStock.canDecreaseQuantity(), true);
      });

      test('should get age in days', () {
        // Arrange
        final oldItem = CartItem(
          productId: 'prod-1',
          productName: 'Test',
          price: 100,
          quantity: 1,
          addedAt: DateTime.now().subtract(const Duration(days: 5)),
        );

        // Assert
        expect(oldItem.getAgeInDays(), 5);
      });
    });

    group('Equality', () {
      test('should be equal when all properties are same', () {
        // Arrange
        final item1 = tCartItem;
        final item2 = tCartItem.copyWith();

        // Assert
        expect(item1, equals(item2));
      });

      test('should not be equal when productId differs', () {
        // Arrange
        final item1 = tCartItem;
        final item2 = tCartItem.copyWith(productId: 'prod-2');

        // Assert
        expect(item1, isNot(equals(item2)));
      });

      test('should have same hashCode when equal', () {
        // Arrange
        final item1 = tCartItem;
        final item2 = tCartItem.copyWith();

        // Assert
        expect(item1.hashCode, equals(item2.hashCode));
      });
    });

    group('CopyWith', () {
      test('should copy with new quantity', () {
        // Act
        final newItem = tCartItem.copyWith(quantity: 20);

        // Assert
        expect(newItem.quantity, 20);
        expect(newItem.productId, tCartItem.productId);
        expect(newItem.price, tCartItem.price);
      });

      test('should copy with new price', () {
        // Act
        final newItem = tCartItem.copyWith(price: 200000);

        // Assert
        expect(newItem.price, 200000);
        expect(newItem.subtotal, 2000000);
      });
    });
  });
}
