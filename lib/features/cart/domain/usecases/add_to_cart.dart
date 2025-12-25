import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

/// Add To Cart Use Case
/// Adds a product to the cart or updates quantity if already exists
class AddToCart extends UseCase<void, AddToCartParams> {
  final CartRepository repository;

  AddToCart(this.repository);

  @override
  Future<Either<Failure, void>> call(AddToCartParams params) async {
    // Validate the cart item before adding
    final errors = params.item.validate();
    if (errors.isNotEmpty) {
      return Left(ValidationFailure(errors.first));
    }

    return await repository.addToCart(params.item);
  }
}

class AddToCartParams extends Equatable {
  final CartItem item;

  const AddToCartParams({required this.item});

  @override
  List<Object?> get props => [item];
}
