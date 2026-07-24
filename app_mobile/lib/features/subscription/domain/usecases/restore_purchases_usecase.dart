import '../../../../core/error/result.dart';
import '../repositories/subscription_repository.dart';

class RestorePurchasesUseCase {
  const RestorePurchasesUseCase(this._repository);
  final SubscriptionRepository _repository;

  Future<Result<void>> call() => _repository.restorePurchases();
}
