import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

/// Get Cart Items Use Case
/// Retrieves all items currently in the cart
class GetCartItems extends UseCase<List<CartItem>, NoParams> {
  final CartRepository repository;

  GetCartItems(this.repository);

  @override
  Future<Either<Failure, List<CartItem>>> call(NoParams params) async {
    return await repository.getCartItems();
  }
}
