import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../auth_providers.dart';
import '../../domain/entities/admin_user.dart';

sealed class AdminAuthState extends Equatable {
  const AdminAuthState();

  @override
  List<Object?> get props => [];
}

/// Still resolving whether a persisted Firebase session exists — the
/// router's redirect guard exempts Login from forcing a redirect while
/// in this state, same reasoning as `app_mobile`'s `AuthInitial`.
class AdminAuthInitial extends AdminAuthState {
  const AdminAuthInitial();
}

class AdminAuthUnauthenticated extends AdminAuthState {
  const AdminAuthUnauthenticated();
}

class AdminAuthAuthenticating extends AdminAuthState {
  const AdminAuthAuthenticating();
}

class AdminAuthAuthenticated extends AdminAuthState {
  const AdminAuthAuthenticated(this.user);
  final AdminUser user;

  @override
  List<Object?> get props => [user];
}

class AdminAuthError extends AdminAuthState {
  const AdminAuthError(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class AdminAuthViewModel extends Notifier<AdminAuthState> {
  StreamSubscription<AdminUser?>? _subscription;

  @override
  AdminAuthState build() {
    _subscription = ref.read(watchAdminAuthStateUseCaseProvider)().listen((user) {
      state = user == null ? const AdminAuthUnauthenticated() : AdminAuthAuthenticated(user);
    });
    ref.onDispose(() => _subscription?.cancel());
    return const AdminAuthInitial();
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AdminAuthAuthenticating();
    final result = await ref.read(adminSignInUseCaseProvider)(email: email, password: password);
    // On success this is redundant with (but harmless alongside) the
    // stream listener above, which will also observe the same sign-in
    // via `idTokenChanges` — setting state here directly avoids waiting
    // an extra event round-trip before the login screen can navigate on.
    state = result.when(success: AdminAuthAuthenticated.new, failure: AdminAuthError.new);
  }

  Future<void> signOut() => ref.read(adminSignOutUseCaseProvider)();
}

final adminAuthViewModelProvider = NotifierProvider<AdminAuthViewModel, AdminAuthState>(
  AdminAuthViewModel.new,
);
