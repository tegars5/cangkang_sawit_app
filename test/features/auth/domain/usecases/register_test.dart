import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cangkang_sawit_app/features/auth/domain/entities/user.dart';
import 'package:cangkang_sawit_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:cangkang_sawit_app/features/auth/domain/usecases/register.dart';
import 'package:cangkang_sawit_app/core/error/failures.dart';

import 'register_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late Register useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = Register(mockRepository);
  });

  group('Register', () {
    const tEmail = 'newuser@example.com';
    const tPassword = 'password123';
    const tName = 'New User';
    const tRole = 'mitra';
    final tUser = User(
      id: '1',
      email: tEmail,
      fullName: tName,
      roleId: 1,
      roleName: 'mitra',
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
    );

    test('should register user successfully', () async {
      // Arrange
      when(
        mockRepository.register(
          email: anyNamed('email'),
          password: anyNamed('password'),
          name: anyNamed('name'),
          role: anyNamed('role'),
        ),
      ).thenAnswer((_) async => Right(tUser));

      // Act
      final result = await useCase(
        RegisterParams(
          email: tEmail,
          password: tPassword,
          name: tName,
          role: tRole,
        ),
      );

      // Assert
      expect(result, Right(tUser));
      verify(
        mockRepository.register(
          email: tEmail,
          password: tPassword,
          name: tName,
          role: tRole,
        ),
      );
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when email already exists', () async {
      // Arrange
      const tFailure = ServerFailure('Email already exists');
      when(
        mockRepository.register(
          email: anyNamed('email'),
          password: anyNamed('password'),
          name: anyNamed('name'),
          role: anyNamed('role'),
        ),
      ).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(
        RegisterParams(
          email: tEmail,
          password: tPassword,
          name: tName,
          role: tRole,
        ),
      );

      // Assert
      expect(result, Left(tFailure));
      verify(
        mockRepository.register(
          email: tEmail,
          password: tPassword,
          name: tName,
          role: tRole,
        ),
      );
    });

    test('should return failure for weak password', () async {
      // Arrange
      const tWeakPassword = '123';

      // Act
      final result = await useCase(
        const RegisterParams(
          email: tEmail,
          password: tWeakPassword,
          name: tName,
          role: tRole,
        ),
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
