import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:cangkang_sawit_app/core/error/failures.dart';
import 'package:cangkang_sawit_app/features/orders/domain/entities/order.dart';
import 'package:cangkang_sawit_app/features/orders/domain/repositories/order_repository.dart';
import 'package:cangkang_sawit_app/features/orders/domain/usecases/create_order.dart';

import 'create_order_test.mocks.dart';

@GenerateMocks([OrderRepository])
void main() {
  late CreateOrder useCase;
  late MockOrderRepository mockRepository;

  setUp(() {
    mockRepository = MockOrderRepository();
    useCase = CreateOrder(mockRepository);
  });

  final tOrder = Order(
    id: '',
    orderNumber: '',
    customerId: 'customer-1',
    orderDate: DateTime(2024, 1, 1),
    status: 'pending',
    totalQuantity: 100,
    totalAmount: 1000000,
    createdAt: DateTime(2024, 1, 1),
  );

  final tCreatedOrder = Order(
    id: 'order-1',
    orderNumber: 'ORD-001',
    customerId: 'customer-1',
    orderDate: DateTime(2024, 1, 1),
    status: 'pending',
    totalQuantity: 100,
    totalAmount: 1000000,
    createdAt: DateTime(2024, 1, 1),
  );

  group('CreateOrder UseCase', () {
    test('should return created order when repository succeeds', () async {
      // arrange
      when(
        mockRepository.createOrder(any),
      ).thenAnswer((_) async => Right(tCreatedOrder));

      // act
      final result = await useCase(tOrder);

      // assert
      expect(result, Right(tCreatedOrder));
      verify(mockRepository.createOrder(tOrder));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when total quantity is 0', () async {
      // arrange
      final invalidOrder = tOrder.copyWith(totalQuantity: 0);

      // act
      final result = await useCase(invalidOrder);

      // assert
      expect(
        result,
        Left(ValidationFailure('Total quantity must be greater than 0')),
      );
      verifyNever(mockRepository.createOrder(any));
    });

    test(
      'should return ValidationFailure when total quantity is negative',
      () async {
        // arrange
        final invalidOrder = tOrder.copyWith(totalQuantity: -10);

        // act
        final result = await useCase(invalidOrder);

        // assert
        expect(
          result,
          Left(ValidationFailure('Total quantity must be greater than 0')),
        );
        verifyNever(mockRepository.createOrder(any));
      },
    );

    test('should return ValidationFailure when total amount is 0', () async {
      // arrange
      final invalidOrder = tOrder.copyWith(totalAmount: 0);

      // act
      final result = await useCase(invalidOrder);

      // assert
      expect(
        result,
        Left(ValidationFailure('Total amount must be greater than 0')),
      );
      verifyNever(mockRepository.createOrder(any));
    });

    test(
      'should return ValidationFailure when total amount is negative',
      () async {
        // arrange
        final invalidOrder = tOrder.copyWith(totalAmount: -1000);

        // act
        final result = await useCase(invalidOrder);

        // assert
        expect(
          result,
          Left(ValidationFailure('Total amount must be greater than 0')),
        );
        verifyNever(mockRepository.createOrder(any));
      },
    );

    test('should return ServerFailure when repository fails', () async {
      // arrange
      when(
        mockRepository.createOrder(any),
      ).thenAnswer((_) async => Left(ServerFailure('Server error')));

      // act
      final result = await useCase(tOrder);

      // assert
      expect(result, Left(ServerFailure('Server error')));
      verify(mockRepository.createOrder(tOrder));
    });
  });
}
