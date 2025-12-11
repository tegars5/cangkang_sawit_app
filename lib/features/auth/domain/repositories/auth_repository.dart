import 'package:dartz/dartz.dart' as dartz;
import '../../../core/error/failures.dart';
import '../../../shared/models/models.dart';

/// Repository interface for Authentication operations
abstract class AuthRepository {
  /// Login with email and password
  Future<dartz.Either<Failure, UserProfile>> login({
    required String email,
    required String password,
  });

  /// Register new user
  Future<dartz.Either<Failure, UserProfile>> register({
    required String email,
    required String password,
    required String name,
    required String role,
    Map<String, dynamic>? additionalData,
  });

  /// Logout current user
  Future<dartz.Either<Failure, void>> logout();

  /// Get current user profile
  Future<dartz.Either<Failure, UserProfile?>> getCurrentUser();

  /// Update user profile
  Future<dartz.Either<Failure, UserProfile>> updateProfile({
    required String userId,
    required Map<String, dynamic> updates,
  });
}
