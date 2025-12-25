import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cart_repository.dart';

/// Update Cart Quantity Use Case
/// Updates the quantity of a product in the cart
class UpdateCartQuantity extends UseCase<void, UpdateCartQuantityParams> {
  final CartRepository repository;

  UpdateCartQuantity(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateCartQuantityParams params) async {
    if (params.productId.isEmpty) {
      return Left(ValidationFailure('Product ID cannot be empty'));
    }

    if (params.quantity <= 0) {
      return Left(ValidationFailure('Quantity must be greater than 0'));
    }

    return await repository.updateQuantity(params.productId, params.quantity);
  }
}

class UpdateCartQuantityParams extends Equatable {
  final String productId;
  final int quantity;

  const UpdateCartQuantityParams({
    required this.productId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, quantity];
}
