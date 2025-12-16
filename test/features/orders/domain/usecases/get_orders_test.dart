import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:cangkang_sawit_app/core/error/failures.dart';
import 'package:cangkang_sawit_app/features/orders/domain/entities/order.dart';
import 'package:cangkang_sawit_app/features/orders/domain/repositories/order_repository.dart';
import 'package:cangkang_sawit_app/features/orders/domain/usecases/get_orders.dart';

import 'get_orders_test.mocks.dart';

@GenerateMocks([OrderRepository])
void main() {
  late GetOrders useCase;
  late MockOrderRepository mockRepository;

  setUp(() {
    mockRepository = MockOrderRepository();
    useCase = GetOrders(mockRepository);
  });

  final tOrders = [
    Order(
      id: '1',
      orderNumber: 'ORD-001',
      customerId: 'customer-1',
      orderDate: DateTime(2024, 1, 1),
      status: 'pending',
      totalQuantity: 100,
      totalAmount: 1000000,
      createdAt: DateTime(2024, 1, 1),
    ),
    Order(
      id: '2',
      orderNumber: 'ORD-002',
      customerId: 'customer-1',
      orderDate: DateTime(2024, 1, 2),
      status: 'confirmed',
      totalQuantity: 200,
      totalAmount: 2000000,
      createdAt: DateTime(2024, 1, 2),
    ),
  ];

  group('GetOrders UseCase', () {
    test('should return list of orders when repository succeeds', () async {
      // arrange
      when(mockRepository.getOrders()).thenAnswer((_) async => Right(tOrders));

      // act
      final result = await useCase(const GetOrdersParams());

      // assert
      expect(result, Right(tOrders));
      verify(mockRepository.getOrders());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no orders', () async {
      // arrange
      when(mockRepository.getOrders()).thenAnswer((_) async => const Right([]));

      // act
      final result = await useCase(const GetOrdersParams());

      // assert
      result.fold((failure) => fail('Should return empty list'), (orders) {
        expect(orders, isEmpty);
      });
      verify(mockRepository.getOrders());
    });

    test('should return ServerFailure when repository fails', () async {
      // arrange
      when(
        mockRepository.getOrders(),
      ).thenAnswer((_) async => Left(ServerFailure('Server error')));

      // act
      final result = await useCase(const GetOrdersParams());

      // assert
      expect(result, Left(ServerFailure('Server error')));
      verify(mockRepository.getOrders());
    });

    test('should filter by customerId correctly', () async {
      // arrange
      const customerId = 'customer-1';
      when(
        mockRepository.getOrders(customerId: customerId),
      ).thenAnswer((_) async => Right(tOrders));

      // act
      final result = await useCase(
        const GetOrdersParams(customerId: customerId),
      );

      // assert
      expect(result, Right(tOrders));
      verify(mockRepository.getOrders(customerId: customerId));
    });

    test('should filter by status correctly', () async {
      // arrange
      const status = 'pending';
      final pendingOrders = [tOrders[0]];
      when(
        mockRepository.getOrders(status: status),
      ).thenAnswer((_) async => Right(pendingOrders));

      // act
      final result = await useCase(const GetOrdersParams(status: status));

      // assert
      expect(result, Right(pendingOrders));
      verify(mockRepository.getOrders(status: status));
    });

    test('should filter by both customerId and status', () async {
      // arrange
      const customerId = 'customer-1';
      const status = 'confirmed';
      final filteredOrders = [tOrders[1]];
      when(
        mockRepository.getOrders(customerId: customerId, status: status),
      ).thenAnswer((_) async => Right(filteredOrders));

      // act
      final result = await useCase(
        const GetOrdersParams(customerId: customerId, status: status),
      );

      // assert
      expect(result, Right(filteredOrders));
      verify(mockRepository.getOrders(customerId: customerId, status: status));
    });
  });
}
