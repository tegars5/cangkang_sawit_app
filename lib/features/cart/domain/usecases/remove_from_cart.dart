import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cart_repository.dart';

/// Remove From Cart Use Case
/// Removes a product from the cart
class RemoveFromCart extends UseCase<void, RemoveFromCartParams> {
  final CartRepository repository;

  RemoveFromCart(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveFromCartParams params) async {
    if (params.productId.isEmpty) {
      return Left(ValidationFailure('Product ID cannot be empty'));
    }

    return await repository.removeFromCart(params.productId);
  }
}

class RemoveFromCartParams extends Equatable {
  final String productId;

  const RemoveFromCartParams({required this.productId});

  @override
  List<Object?> get props => [productId];
}
