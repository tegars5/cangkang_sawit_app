import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cangkang_sawit_app/features/auth/domain/entities/user.dart';
import 'package:cangkang_sawit_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:cangkang_sawit_app/features/auth/domain/usecases/login.dart';
import 'package:cangkang_sawit_app/core/error/failures.dart';

import 'login_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late Login useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = Login(mockRepository);
  });

  group('Login', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    final tUser = User(
      id: '1',
      email: tEmail,
      fullName: 'Test User',
      roleId: 1,
      roleName: 'mitra',
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
    );

    test('should login user successfully', () async {
      // Arrange
      when(
        mockRepository.login(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => Right(tUser));

      // Act
      final result = await useCase(
        const LoginParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, Right(tUser));
      verify(mockRepository.login(email: tEmail, password: tPassword));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when login fails', () async {
      // Arrange
      const tFailure = ServerFailure('Invalid credentials');
      when(
        mockRepository.login(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(
        const LoginParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, const Left(tFailure));
      verify(mockRepository.login(email: tEmail, password: tPassword));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure for invalid email format', () async {
      // Arrange
      const tInvalidEmail = 'invalid-email';

      // Act
      final result = await useCase(
        const LoginParams(email: tInvalidEmail, password: tPassword),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (r) => fail('Should be Left'),
      );
    });
  });
}
