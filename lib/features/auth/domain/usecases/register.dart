import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/user_profile.dart';
import '../repositories/auth_repository.dart';

/// Use case for user registration
class Register implements UseCase<UserProfile, RegisterParams> {
  final AuthRepository repository;

  Register(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(RegisterParams params) async {
    // Business validation
    if (params.email.isEmpty) {
      return const Left(ValidationFailure('Email cannot be empty'));
    }

    if (params.password.isEmpty) {
      return const Left(ValidationFailure('Password cannot be empty'));
    }

    if (params.password.length < 6) {
      return const Left(
        ValidationFailure('Password must be at least 6 characters'),
      );
    }

    if (params.name.isEmpty) {
      return const Left(ValidationFailure('Name cannot be empty'));
    }

    if (!_isValidEmail(params.email)) {
      return const Left(ValidationFailure('Invalid email format'));
    }

    return await repository.register(
      email: params.email,
      password: params.password,
      name: params.name,
      role: params.role,
      additionalData: params.additionalData,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

class RegisterParams {
  final String email;
  final String password;
  final String name;
  final String role;
  final Map<String, dynamic>? additionalData;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
    this.additionalData,
  });
}
