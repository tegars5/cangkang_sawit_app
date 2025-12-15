import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/user_profile.dart';
import '../repositories/auth_repository.dart';

/// Use case to get current authenticated user
class GetCurrentUser implements UseCase<UserProfile?, NoParams> {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  @override
  Future<Either<Failure, UserProfile?>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}
