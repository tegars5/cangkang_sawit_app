import 'package:dartz/dartz.dart' as dartz;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/models.dart';
import '../repositories/auth_repository.dart';

/// Use case for user login
class Login implements UseCase<UserProfile, LoginParams> {
  final AuthRepository repository;

  Login(this.repository);

  @override
  Future<dartz.Either<Failure, UserProfile>> call(LoginParams params) async {
    // Business validation
    if (params.email.isEmpty) {
      return const dartz.Left(ValidationFailure('Email cannot be empty'));
    }

    if (params.password.isEmpty) {
      return const dartz.Left(ValidationFailure('Password cannot be empty'));
    }

    if (!_isValidEmail(params.email)) {
      return const dartz.Left(ValidationFailure('Invalid email format'));
    }

    return await repository.login(
      email: params.email,
      password: params.password,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

class LoginParams {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});
}
