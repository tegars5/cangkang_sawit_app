import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:cangkang_sawit_app/core/error/failures.dart';
import 'package:cangkang_sawit_app/features/orders/domain/entities/order.dart';
import 'package:cangkang_sawit_app/features/orders/domain/repositories/order_repository.dart';
import 'package:cangkang_sawit_app/features/orders/domain/usecases/confirm_order.dart';

import 'confirm_order_test.mocks.dart';

@GenerateMocks([OrderRepository])
void main() {
  late ConfirmOrder useCase;
  late MockOrderRepository mockRepository;

  setUp(() {
    mockRepository = MockOrderRepository();
    useCase = ConfirmOrder(mockRepository);
  });

  final tConfirmedOrder = Order(
    id: 'order-1',
    orderNumber: 'ORD-001',
    customerId: 'customer-1',
    orderDate: DateTime(2024, 1, 1),
    status: 'confirmed',
    totalQuantity: 100,
    confirmedQuantity: 90,
    totalAmount: 900000,
    createdAt: DateTime(2024, 1, 1),
    confirmedAt: DateTime(2024, 1, 2),
  );

  group('ConfirmOrder UseCase', () {
    test('should return confirmed order when repository succeeds', () async {
      // arrange
      const params = ConfirmOrderParams(
        orderId: 'order-1',
        confirmedQuantity: 90,
      );
      when(
        mockRepository.confirmOrder('order-1', 90),
      ).thenAnswer((_) async => Right(tConfirmedOrder));

      // act
      final result = await useCase(params);

      // assert
      expect(result, Right(tConfirmedOrder));
      verify(mockRepository.confirmOrder('order-1', 90));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when order ID is empty', () async {
      // arrange
      const params = ConfirmOrderParams(orderId: '', confirmedQuantity: 90);

      // act
      final result = await useCase(params);

      // assert
      expect(result, Left(ValidationFailure('Order ID cannot be empty')));
      verifyNever(mockRepository.confirmOrder(any, any));
    });

    test(
      'should return ValidationFailure when confirmed quantity is 0',
      () async {
        // arrange
        const params = ConfirmOrderParams(
          orderId: 'order-1',
          confirmedQuantity: 0,
        );

        // act
        final result = await useCase(params);

        // assert
        expect(
          result,
          Left(ValidationFailure('Confirmed quantity must be greater than 0')),
        );
        verifyNever(mockRepository.confirmOrder(any, any));
      },
    );

    test(
      'should return ValidationFailure when confirmed quantity is negative',
      () async {
        // arrange
        const params = ConfirmOrderParams(
          orderId: 'order-1',
          confirmedQuantity: -10,
        );

        // act
        final result = await useCase(params);

        // assert
        expect(
          result,
          Left(ValidationFailure('Confirmed quantity must be greater than 0')),
        );
        verifyNever(mockRepository.confirmOrder(any, any));
      },
    );

    test('should return ServerFailure when repository fails', () async {
      // arrange
      const params = ConfirmOrderParams(
        orderId: 'order-1',
        confirmedQuantity: 90,
      );
      when(
        mockRepository.confirmOrder(any, any),
      ).thenAnswer((_) async => Left(ServerFailure('Server error')));

      // act
      final result = await useCase(params);

      // assert
      expect(result, Left(ServerFailure('Server error')));
      verify(mockRepository.confirmOrder('order-1', 90));
    });
  });
}
