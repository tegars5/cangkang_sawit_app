import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cangkang_sawit_app/features/auth/domain/entities/user.dart';
import 'package:cangkang_sawit_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:cangkang_sawit_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:cangkang_sawit_app/core/error/failures.dart';
import 'package:cangkang_sawit_app/core/usecases/usecase.dart';

import 'get_current_user_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late GetCurrentUser useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = GetCurrentUser(mockRepository);
  });

  group('GetCurrentUser', () {
    final tUser = User(
      id: '1',
      email: 'test@example.com',
      fullName: 'Test User',
      roleId: 1,
      roleName: 'mitra',
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
    );

    test('should get current user successfully', () async {
      // Arrange
      when(
        mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => Right(tUser));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, Right(tUser));
      verify(mockRepository.getCurrentUser());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when no user is logged in', () async {
      // Arrange
      const tFailure = ServerFailure('Not authenticated');
      when(
        mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, Left(tFailure));
      verify(mockRepository.getCurrentUser());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return null when session expired', () async {
      // Arrange
      const tFailure = ServerFailure('Session expired');
      when(
        mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, Left(tFailure));
      verify(mockRepository.getCurrentUser());
    });
  });
}
