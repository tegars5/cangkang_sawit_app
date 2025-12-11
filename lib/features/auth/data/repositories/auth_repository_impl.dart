import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/models/models.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<dartz.Either<Failure, UserProfile>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      return dartz.Right(user);
    } on AuthException catch (e) {
      return dartz.Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(AuthFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, UserProfile>> register({
    required String email,
    required String password,
    required String name,
    required String role,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = await _remoteDataSource.register(
        email: email,
        password: password,
        name: name,
        role: role,
        additionalData: additionalData,
      );
      return dartz.Right(user);
    } on AuthException catch (e) {
      return dartz.Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(AuthFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      return const dartz.Right(null);
    } on AuthException catch (e) {
      return dartz.Left(AuthFailure(e.message));
    } catch (e) {
      return dartz.Left(AuthFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, UserProfile?>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return dartz.Right(user);
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, UserProfile>> updateProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final user = await _remoteDataSource.updateProfile(
        userId: userId,
        updates: updates,
      );
      return dartz.Right(user);
    } on ServerException catch (e) {
      return dartz.Left(ServerFailure(e.message));
    } catch (e) {
      return dartz.Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
