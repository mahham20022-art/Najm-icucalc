import '../entities/subscription.dart';
import '../repositories/subscription_repository.dart';

class WatchSubscriptionUseCase {
  const WatchSubscriptionUseCase(this._repository);
  final SubscriptionRepository _repository;

  Stream<Subscription> call() => _repository.watchSubscription();
}
