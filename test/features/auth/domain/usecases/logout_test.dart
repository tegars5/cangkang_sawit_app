import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cangkang_sawit_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:cangkang_sawit_app/features/auth/domain/usecases/logout.dart';
import 'package:cangkang_sawit_app/core/error/failures.dart';
import 'package:cangkang_sawit_app/core/usecases/usecase.dart';

import 'logout_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late Logout useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = Logout(mockRepository);
  });

  group('Logout', () {
    test('should logout user successfully', () async {
      // Arrange
      when(mockRepository.logout()).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, const Right(null));
      verify(mockRepository.logout());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when logout fails', () async {
      // Arrange
      const tFailure = ServerFailure('Logout failed');
      when(
        mockRepository.logout(),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, const Left(tFailure));
      verify(mockRepository.logout());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should clear local session on logout', () async {
      // Arrange
      when(mockRepository.logout()).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, const Right(null));
      verify(mockRepository.logout());
    });
  });
}
