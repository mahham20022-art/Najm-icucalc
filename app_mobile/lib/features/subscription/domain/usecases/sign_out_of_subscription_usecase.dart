import '../repositories/subscription_repository.dart';

class SignOutOfSubscriptionUseCase {
  const SignOutOfSubscriptionUseCase(this._repository);
  final SubscriptionRepository _repository;

  Future<void> call() => _repository.handleSignOut();
}
