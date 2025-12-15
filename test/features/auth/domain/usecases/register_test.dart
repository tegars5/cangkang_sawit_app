import 'package:cangkang_sawit_app/core/error/failures.dart';
import 'package:cangkang_sawit_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:cangkang_sawit_app/features/auth/domain/usecases/register.dart';
import 'package:cangkang_sawit_app/shared/models/user_profile.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'register_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late Register usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = Register(mockAuthRepository);
  });

  const testEmail = 'test@example.com';
  const testPassword = 'password123';
  const testName = 'Test User';
  const testRole = 'Mitra Bisnis';

  final testUserProfile = UserProfile(
    id: '123',
    email: testEmail,
    fullName: testName,
    roleId: 2,
    isActive: true,
    createdAt: DateTime.now(),
  );

  group('Register UseCase', () {
    test('should return UserProfile when registration is successful', () async {
      // arrange
      when(
        mockAuthRepository.register(
          email: anyNamed('email'),
          password: anyNamed('password'),
          name: anyNamed('name'),
          role: anyNamed('role'),
          additionalData: anyNamed('additionalData'),
        ),
      ).thenAnswer((_) async => Right(testUserProfile));

      // act
      final result = await usecase(
        RegisterParams(
          email: testEmail,
          password: testPassword,
          name: testName,
          role: testRole,
        ),
      );

      // assert
      expect(result, Right(testUserProfile));
      verify(
        mockAuthRepository.register(
          email: testEmail,
          password: testPassword,
          name: testName,
          role: testRole,
          additionalData: null,
        ),
      );
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return ValidationFailure when email is empty', () async {
      // act
      final result = await usecase(
        RegisterParams(
          email: '',
          password: testPassword,
          name: testName,
          role: testRole,
        ),
      );

      // assert
      expect(result, const Left(ValidationFailure('Email cannot be empty')));
      verifyZeroInteractions(mockAuthRepository);
    });

    test('should return ValidationFailure when password is empty', () async {
      // act
      final result = await usecase(
        RegisterParams(
          email: testEmail,
          password: '',
          name: testName,
          role: testRole,
        ),
      );

      // assert
      expect(result, const Left(ValidationFailure('Password cannot be empty')));
      verifyZeroInteractions(mockAuthRepository);
    });

    test(
      'should return ValidationFailure when password is too short',
      () async {
        // act
        final result = await usecase(
          RegisterParams(
            email: testEmail,
            password: '12345',
            name: testName,
            role: testRole,
          ),
        );

        // assert
        expect(
          result,
          const Left(
            ValidationFailure('Password must be at least 6 characters'),
          ),
        );
        verifyZeroInteractions(mockAuthRepository);
      },
    );

    test('should return ValidationFailure when name is empty', () async {
      // act
      final result = await usecase(
        RegisterParams(
          email: testEmail,
          password: testPassword,
          name: '',
          role: testRole,
        ),
      );

      // assert
      expect(result, const Left(ValidationFailure('Name cannot be empty')));
      verifyZeroInteractions(mockAuthRepository);
    });

    test(
      'should return ValidationFailure when email format is invalid',
      () async {
        // act
        final result = await usecase(
          RegisterParams(
            email: 'invalid-email',
            password: testPassword,
            name: testName,
            role: testRole,
          ),
        );

        // assert
        expect(result, const Left(ValidationFailure('Invalid email format')));
        verifyZeroInteractions(mockAuthRepository);
      },
    );

    test('should pass additional data to repository', () async {
      // arrange
      final additionalData = {'phone': '08123456789'};
      when(
        mockAuthRepository.register(
          email: anyNamed('email'),
          password: anyNamed('password'),
          name: anyNamed('name'),
          role: anyNamed('role'),
          additionalData: anyNamed('additionalData'),
        ),
      ).thenAnswer((_) async => Right(testUserProfile));

      // act
      final result = await usecase(
        RegisterParams(
          email: testEmail,
          password: testPassword,
          name: testName,
          role: testRole,
          additionalData: additionalData,
        ),
      );

      // assert
      expect(result, Right(testUserProfile));
      verify(
        mockAuthRepository.register(
          email: testEmail,
          password: testPassword,
          name: testName,
          role: testRole,
          additionalData: additionalData,
        ),
      );
    });

    test('should return AuthFailure when registration fails', () async {
      // arrange
      when(
        mockAuthRepository.register(
          email: anyNamed('email'),
          password: anyNamed('password'),
          name: anyNamed('name'),
          role: anyNamed('role'),
          additionalData: anyNamed('additionalData'),
        ),
      ).thenAnswer(
        (_) async => const Left(AuthFailure('Email already exists')),
      );

      // act
      final result = await usecase(
        RegisterParams(
          email: testEmail,
          password: testPassword,
          name: testName,
          role: testRole,
        ),
      );

      // assert
      expect(result, const Left(AuthFailure('Email already exists')));
    });
  });
}
