import 'dart:async' show unawaited;

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../auth_providers.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/restore_session_usecase.dart';

/// Immutable UI state — the View only ever renders this, never a raw
/// [Result] or domain entity directly, per `MED100_ARCHITECTURE.md` §4.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Splash is still resolving whether a persisted session should be
/// honored (`RestoreSessionUseCase`) — the router's redirect guard
/// exempts this state from forcing a Login redirect, since forcing one
/// before the check completes would flash Login before immediately
/// bouncing to Home.
class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthAuthenticating extends AuthState {
  const AuthAuthenticating();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final AuthUser user;

  @override
  List<Object?> get props => [user];
}

/// A Firebase session exists, but the biometric gate hasn't been passed
/// yet (`RestoreSessionUseCase`'s [SessionLocked] outcome). The router
/// treats this the same as unauthenticated for routing purposes — it is
/// *not* enough to enter the app — but Login can use [user] to show a
/// "Welcome back" biometric-retry affordance instead of a blank form.
class AuthLocked extends AuthState {
  const AuthLocked(this.user);
  final AuthUser user;

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  const AuthError(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// MVVM ViewModel, implemented as a Riverpod [Notifier] per
/// `MED100_ARCHITECTURE.md` §4 — holds auth UI state and exposes intent
/// methods; every method below calls a use case, never a repository or a
/// Firebase SDK type directly.
class AuthViewModel extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Reflects a sign-out that happens elsewhere (a revoked token, or
    // another part of the app calling signOut) into the UI immediately.
    // This does *not* drive the initial Home-vs-Login decision on its
    // own — `restoreSession()` (called explicitly from Splash) does
    // that, since it also has to weigh Remember Me and the biometric
    // gate, not just "is anyone signed in".
    ref.listen(authStateChangesProvider, (previous, next) {
      final user = next.value;
      if (user == null && state is AuthAuthenticated) {
        state = const AuthUnauthenticated();
      }
    });
    return const AuthInitial();
  }

  Future<void> restoreSession() async {
    final useCase = ref.read(restoreSessionUseCaseProvider);
    final result = await useCase();
    state = result.when(
      success: (outcome) => switch (outcome) {
        NoSession() => const AuthUnauthenticated(),
        SessionRestored(:final user) => AuthAuthenticated(user),
        SessionLocked(:final user) => AuthLocked(user),
      },
      failure: AuthError.new,
    );
  }

  /// Retries the biometric prompt from [AuthLocked] without re-running
  /// the full restore flow (Remember Me is already known to be true, or
  /// we wouldn't be in this state).
  Future<void> retryBiometric() async {
    final current = state;
    if (current is! AuthLocked) return;

    final result = await ref.read(biometricAuthenticatorProvider).authenticate();
    state = result.when(success: (_) => AuthAuthenticated(current.user), failure: AuthError.new);
  }

  Future<void> signInWithGoogle({bool rememberMe = true}) =>
      _run(() => ref.read(signInWithGoogleUseCaseProvider)(), rememberMe: rememberMe);

  Future<void> signInWithApple({bool rememberMe = true}) =>
      _run(() => ref.read(signInWithAppleUseCaseProvider)(), rememberMe: rememberMe);

  Future<void> signInWithEmail({
    required String email,
    required String password,
    bool rememberMe = true,
  }) => _run(
    () => ref.read(signInWithEmailUseCaseProvider)(email: email, password: password),
    rememberMe: rememberMe,
  );

  Future<void> register({
    required String email,
    required String password,
    required String confirmPassword,
    bool rememberMe = true,
  }) => _run(
    () => ref.read(registerWithEmailUseCaseProvider)(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    ),
    rememberMe: rememberMe,
  );

  /// Guest Mode still runs through the same Remember Me plumbing: a
  /// guest who reopens the app expects to land back in their guest
  /// session, same as any other sign-in method, per the Onboarding guest
  /// flow in `MED100_UI_UX_SPEC.md` §2f.
  Future<void> continueAsGuest({bool rememberMe = true}) =>
      _run(() => ref.read(continueAsGuestUseCaseProvider)(), rememberMe: rememberMe);

  Future<void> signOut() async {
    final result = await ref.read(signOutUseCaseProvider)();
    state = result.when(success: (_) => const AuthUnauthenticated(), failure: AuthError.new);
  }

  Future<void> _run(Future<Result<AuthUser>> Function() action, {required bool rememberMe}) async {
    state = const AuthAuthenticating();
    final result = await action();
    state = result.when(
      success: (user) {
        // Persisted *after* a successful sign-in, not defaulted at rest
        // — see `SecureSessionDataSource`'s note on why an unset flag
        // reads as false. Fire-and-forget: a slow secure-storage write
        // shouldn't delay the transition to Home.
        unawaited(ref.read(sessionRepositoryProvider).setRememberMeEnabled(rememberMe));
        return AuthAuthenticated(user);
      },
      failure: AuthError.new,
    );
  }
}

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(AuthViewModel.new);
