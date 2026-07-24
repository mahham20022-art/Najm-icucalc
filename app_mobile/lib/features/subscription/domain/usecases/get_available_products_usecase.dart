import '../entities/subscription_product.dart';
import '../repositories/subscription_repository.dart';

class GetAvailableProductsUseCase {
  const GetAvailableProductsUseCase(this._repository);
  final SubscriptionRepository _repository;

  Future<List<SubscriptionProduct>> call() => _repository.getAvailableProducts();
}
