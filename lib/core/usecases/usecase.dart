import 'package:dartz/dartz.dart' as dartz;
import '../error/failures.dart';

/// Base class for all use cases
///
/// A use case represents a single business action
/// Example: CreateOrder, GetOrders, ConfirmOrder
abstract class UseCase<Type, Params> {
  Future<dartz.Either<Failure, Type>> call(Params params);
}

/// Use case with no parameters
abstract class UseCaseNoParams<Type> {
  Future<dartz.Either<Failure, Type>> call();
}

/// Class representing no parameters for use cases
class NoParams {
  const NoParams();
}
