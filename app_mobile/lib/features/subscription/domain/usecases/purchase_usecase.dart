import '../../../../core/error/result.dart';
import '../repositories/subscription_repository.dart';

class PurchaseUseCase {
  const PurchaseUseCase(this._repository);
  final SubscriptionRepository _repository;

  Future<Result<void>> call(String productId) => _repository.purchase(productId);
}
