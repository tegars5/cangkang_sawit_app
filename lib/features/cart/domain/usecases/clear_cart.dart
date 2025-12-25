import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cart_repository.dart';

/// Clear Cart Use Case
/// Removes all items from the cart
class ClearCart extends UseCase<void, NoParams> {
  final CartRepository repository;

  ClearCart(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.clearCart();
  }
}
