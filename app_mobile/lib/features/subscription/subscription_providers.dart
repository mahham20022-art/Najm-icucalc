import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap/bootstrap.dart';
import '../../core/session/current_user.dart';
import 'data/datasources/revenue_cat_datasource.dart';
import 'data/datasources/subscription_local_datasource.dart';
import 'data/repositories/subscription_repository_impl.dart';
import 'domain/entities/subscription.dart';
import 'domain/repositories/subscription_repository.dart';
import 'domain/usecases/get_available_products_usecase.dart';
import 'domain/usecases/purchase_usecase.dart';
import 'domain/usecases/restore_purchases_usecase.dart';
import 'domain/usecases/sign_out_of_subscription_usecase.dart';
import 'domain/usecases/watch_subscription_usecase.dart';

final revenueCatDataSourceProvider = Provider<RevenueCatDataSource>((ref) {
  return RevenueCatDataSource();
});

final subscriptionLocalDataSourceProvider = Provider<SubscriptionLocalDataSource>((ref) {
  return SubscriptionLocalDataSource(ref.watch(appDatabaseProvider));
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final repository = SubscriptionRepositoryImpl(
    revenueCat: ref.watch(revenueCatDataSourceProvider),
    localDataSource: ref.watch(subscriptionLocalDataSourceProvider),
    currentUser: ref.watch(currentUserProvider),
  );
  ref.onDispose(repository.dispose);
  return repository;
});

final watchSubscriptionUseCaseProvider = Provider<WatchSubscriptionUseCase>((ref) {
  return WatchSubscriptionUseCase(ref.watch(subscriptionRepositoryProvider));
});

final getAvailableProductsUseCaseProvider = Provider<GetAvailableProductsUseCase>((ref) {
  return GetAvailableProductsUseCase(ref.watch(subscriptionRepositoryProvider));
});

final purchaseUseCaseProvider = Provider<PurchaseUseCase>((ref) {
  return PurchaseUseCase(ref.watch(subscriptionRepositoryProvider));
});

final restorePurchasesUseCaseProvider = Provider<RestorePurchasesUseCase>((ref) {
  return RestorePurchasesUseCase(ref.watch(subscriptionRepositoryProvider));
});

final signOutOfSubscriptionUseCaseProvider = Provider<SignOutOfSubscriptionUseCase>((ref) {
  return SignOutOfSubscriptionUseCase(ref.watch(subscriptionRepositoryProvider));
});

/// The app-wide "is this signed-in user premium?" read — every
/// entitlement check (Mastery Mode's paywall gate, etc.) watches this
/// rather than reaching into `SubscriptionRepository` directly.
final subscriptionProvider = StreamProvider<Subscription>((ref) {
  return ref.watch(watchSubscriptionUseCaseProvider)();
});
