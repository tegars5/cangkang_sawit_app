import 'package:cangkang_sawit_app/core/error/exceptions.dart';
import 'package:cangkang_sawit_app/core/error/failures.dart';
import 'package:cangkang_sawit_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cangkang_sawit_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cangkang_sawit_app/shared/models/user_profile.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_repository_impl_test.mocks.dart';

@GenerateMocks([AuthRemoteDataSource])
void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remoteDataSource: mockRemoteDataSource);
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

  group('login', () {
    test(
      'should return UserProfile when remote data source succeeds',
      () async {
        // arrange
        when(
          mockRemoteDataSource.login(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => testUserProfile);

        // act
        final result = await repository.login(
          email: testEmail,
          password: testPassword,
        );

        // assert
        expect(result, Right(testUserProfile));
        verify(
          mockRemoteDataSource.login(email: testEmail, password: testPassword),
        );
        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );

    test(
      'should return AuthFailure when remote data source throws AuthException',
      () async {
        // arrange
        when(
          mockRemoteDataSource.login(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenThrow(const AppAuthException('Invalid credentials'));

        // act
        final result = await repository.login(
          email: testEmail,
          password: testPassword,
        );

        // assert
        expect(result, const Left(AuthFailure('Invalid credentials')));
      },
    );

    test(
      'should return ServerFailure when remote data source throws ServerException',
      () async {
        // arrange
        when(
          mockRemoteDataSource.login(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenThrow(const ServerException('Server error'));

        // act
        final result = await repository.login(
          email: testEmail,
          password: testPassword,
        );

        // assert
        expect(result, const Left(ServerFailure('Server error')));
      },
    );

    test('should return AuthFailure when unexpected error occurs', () async {
      // arrange
      when(
        mockRemoteDataSource.login(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(Exception('Unexpected error'));

      // act
      final result = await repository.login(
        email: testEmail,
        password: testPassword,
      );

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('register', () {
    test(
      'should return UserProfile when remote data source succeeds',
      () async {
        // arrange
        when(
          mockRemoteDataSource.register(
            email: anyNamed('email'),
            password: anyNamed('password'),
            name: anyNamed('name'),
            role: anyNamed('role'),
            additionalData: anyNamed('additionalData'),
          ),
        ).thenAnswer((_) async => testUserProfile);

        // act
        final result = await repository.register(
          email: testEmail,
          password: testPassword,
          name: testName,
          role: testRole,
        );

        // assert
        expect(result, Right(testUserProfile));
        verify(
          mockRemoteDataSource.register(
            email: testEmail,
            password: testPassword,
            name: testName,
            role: testRole,
            additionalData: null,
          ),
        );
      },
    );

    test('should return AuthFailure when email already exists', () async {
      // arrange
      when(
        mockRemoteDataSource.register(
          email: anyNamed('email'),
          password: anyNamed('password'),
          name: anyNamed('name'),
          role: anyNamed('role'),
          additionalData: anyNamed('additionalData'),
        ),
      ).thenThrow(const AppAuthException('Email already exists'));

      // act
      final result = await repository.register(
        email: testEmail,
        password: testPassword,
        name: testName,
        role: testRole,
      );

      // assert
      expect(result, const Left(AuthFailure('Email already exists')));
    });

    test('should pass additional data to remote data source', () async {
      // arrange
      final additionalData = {'phone': '08123456789'};
      when(
        mockRemoteDataSource.register(
          email: anyNamed('email'),
          password: anyNamed('password'),
          name: anyNamed('name'),
          role: anyNamed('role'),
          additionalData: anyNamed('additionalData'),
        ),
      ).thenAnswer((_) async => testUserProfile);

      // act
      final result = await repository.register(
        email: testEmail,
        password: testPassword,
        name: testName,
        role: testRole,
        additionalData: additionalData,
      );

      // assert
      expect(result, Right(testUserProfile));
      verify(
        mockRemoteDataSource.register(
          email: testEmail,
          password: testPassword,
          name: testName,
          role: testRole,
          additionalData: additionalData,
        ),
      );
    });
  });

  group('logout', () {
    test('should return Right(null) when logout succeeds', () async {
      // arrange
      when(mockRemoteDataSource.logout()).thenAnswer((_) async => {});

      // act
      final result = await repository.logout();

      // assert
      expect(result, const Right(null));
      verify(mockRemoteDataSource.logout());
    });

    test('should return AuthFailure when logout fails', () async {
      // arrange
      when(
        mockRemoteDataSource.logout(),
      ).thenThrow(const AppAuthException('Logout failed'));

      // act
      final result = await repository.logout();

      // assert
      expect(result, const Left(AuthFailure('Logout failed')));
    });
  });

  group('getCurrentUser', () {
    test('should return UserProfile when user is logged in', () async {
      // arrange
      when(
        mockRemoteDataSource.getCurrentUser(),
      ).thenAnswer((_) async => testUserProfile);

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result, Right(testUserProfile));
      verify(mockRemoteDataSource.getCurrentUser());
    });

    test('should return null when no user is logged in', () async {
      // arrange
      when(mockRemoteDataSource.getCurrentUser()).thenAnswer((_) async => null);

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result, const Right(null));
    });

    test('should return ServerFailure when error occurs', () async {
      // arrange
      when(
        mockRemoteDataSource.getCurrentUser(),
      ).thenThrow(const ServerException('Failed to get user'));

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result, const Left(ServerFailure('Failed to get user')));
    });
  });

  group('updateProfile', () {
    test('should return updated UserProfile when update succeeds', () async {
      // arrange
      final updates = {'fullName': 'Updated Name'};
      when(
        mockRemoteDataSource.updateProfile(
          userId: anyNamed('userId'),
          updates: anyNamed('updates'),
        ),
      ).thenAnswer((_) async => testUserProfile);

      // act
      final result = await repository.updateProfile(
        userId: '123',
        updates: updates,
      );

      // assert
      expect(result, Right(testUserProfile));
      verify(
        mockRemoteDataSource.updateProfile(userId: '123', updates: updates),
      );
    });

    test('should return ServerFailure when update fails', () async {
      // arrange
      final updates = {'fullName': 'Updated Name'};
      when(
        mockRemoteDataSource.updateProfile(
          userId: anyNamed('userId'),
          updates: anyNamed('updates'),
        ),
      ).thenThrow(const ServerException('Update failed'));

      // act
      final result = await repository.updateProfile(
        userId: '123',
        updates: updates,
      );

      // assert
      expect(result, const Left(ServerFailure('Update failed')));
    });
  });
}
