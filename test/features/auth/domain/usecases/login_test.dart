import 'package:cangkang_sawit_app/core/error/failures.dart';
import 'package:cangkang_sawit_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:cangkang_sawit_app/features/auth/domain/usecases/login.dart';
import 'package:cangkang_sawit_app/shared/models/user_profile.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late Login usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = Login(mockAuthRepository);
  });

  const testEmail = 'test@example.com';
  const testPassword = 'password123';

  final testUserProfile = UserProfile(
    id: '123',
    email: testEmail,
    fullName: 'Test User',
    roleId: 2,
    isActive: true,
    createdAt: DateTime.now(),
  );

  group('Login UseCase', () {
    test('should return UserProfile when login is successful', () async {
      // arrange
      when(
        mockAuthRepository.login(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => Right(testUserProfile));

      // act
      final result = await usecase(
        LoginParams(email: testEmail, password: testPassword),
      );

      // assert
      expect(result, Right(testUserProfile));
      verify(
        mockAuthRepository.login(email: testEmail, password: testPassword),
      );
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return ValidationFailure when email is empty', () async {
      // act
      final result = await usecase(
        LoginParams(email: '', password: testPassword),
      );

      // assert
      expect(result, const Left(ValidationFailure('Email cannot be empty')));
      verifyZeroInteractions(mockAuthRepository);
    });

    test('should return ValidationFailure when password is empty', () async {
      // act
      final result = await usecase(LoginParams(email: testEmail, password: ''));

      // assert
      expect(result, const Left(ValidationFailure('Password cannot be empty')));
      verifyZeroInteractions(mockAuthRepository);
    });

    test(
      'should return ValidationFailure when email format is invalid',
      () async {
        // act
        final result = await usecase(
          LoginParams(email: 'invalid-email', password: testPassword),
        );

        // assert
        expect(result, const Left(ValidationFailure('Invalid email format')));
        verifyZeroInteractions(mockAuthRepository);
      },
    );

    test('should return AuthFailure when login fails', () async {
      // arrange
      when(
        mockAuthRepository.login(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => const Left(AuthFailure('Invalid credentials')));

      // act
      final result = await usecase(
        LoginParams(email: testEmail, password: testPassword),
      );

      // assert
      expect(result, const Left(AuthFailure('Invalid credentials')));
      verify(
        mockAuthRepository.login(email: testEmail, password: testPassword),
      );
    });

    test('should return ServerFailure when server error occurs', () async {
      // arrange
      when(
        mockAuthRepository.login(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure('Server error')));

      // act
      final result = await usecase(
        LoginParams(email: testEmail, password: testPassword),
      );

      // assert
      expect(result, const Left(ServerFailure('Server error')));
    });
  });
}
