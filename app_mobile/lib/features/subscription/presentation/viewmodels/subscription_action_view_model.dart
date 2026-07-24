import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../subscription_providers.dart';

/// Purchase/restore is a distinct, transient action state from the
/// subscription itself (`subscriptionProvider`, which reflects the
/// persisted entitlement) — this only ever tracks "is a store call
/// in flight right now," not what the user is entitled to.
sealed class SubscriptionActionState extends Equatable {
  const SubscriptionActionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionActionIdle extends SubscriptionActionState {
  const SubscriptionActionIdle();
}

class SubscriptionActionProcessing extends SubscriptionActionState {
  const SubscriptionActionProcessing();
}

class SubscriptionActionFailed extends SubscriptionActionState {
  const SubscriptionActionFailed(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class SubscriptionActionViewModel extends Notifier<SubscriptionActionState> {
  @override
  SubscriptionActionState build() => const SubscriptionActionIdle();

  Future<void> purchase(String productId) async {
    state = const SubscriptionActionProcessing();
    final result = await ref.read(purchaseUseCaseProvider)(productId);
    state = result.when(
      success: (_) => const SubscriptionActionIdle(),
      // A user backing out of the platform sheet isn't an error to
      // surface, same treatment as auth's SignInCancelledFailure.
      failure: (failure) => failure is PurchaseCancelledFailure
          ? const SubscriptionActionIdle()
          : SubscriptionActionFailed(failure),
    );
  }

  Future<void> restore() async {
    state = const SubscriptionActionProcessing();
    final result = await ref.read(restorePurchasesUseCaseProvider)();
    state = result.when(
      success: (_) => const SubscriptionActionIdle(),
      failure: SubscriptionActionFailed.new,
    );
  }

  void dismissError() => state = const SubscriptionActionIdle();
}

final subscriptionActionViewModelProvider =
    NotifierProvider<SubscriptionActionViewModel, SubscriptionActionState>(
      SubscriptionActionViewModel.new,
    );
