import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med100/app/app.dart';
import 'package:med100/app/bootstrap/bootstrap.dart';
import 'package:med100/core/database/app_database.dart';
import 'package:med100/core/error/result.dart';
import 'package:med100/features/auth_onboarding/auth_providers.dart';
import 'package:med100/features/auth_onboarding/domain/entities/auth_user.dart';
import 'package:med100/features/auth_onboarding/domain/repositories/auth_repository.dart';

/// Firebase is never initialized in this test process (no real
/// `bootstrap()` call — only `appDatabaseProvider` is overridden), so
/// `AuthRepositoryImpl`'s real `FirebaseAuth.instance` access would throw
/// `[core/no-app]` the moment Splash's session-restore check runs. This
/// fake keeps the widget test hermetic, the same way `appDatabaseProvider`
/// is overridden instead of opening a real database file.
class _FakeAuthRepository implements AuthRepository {
  @override
  AuthUser? get currentUser => null;

  @override
  Stream<AuthUser?> get authStateChanges => Stream.value(null);

  @override
  Future<Result<AuthUser>> continueAsGuest() async => throw UnimplementedError();

  @override
  Future<Result<AuthUser>> registerWithEmail({
    required String email,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<Result<AuthUser>> signInWithApple() async => throw UnimplementedError();

  @override
  Future<Result<AuthUser>> signInWithEmail({
    required String email,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<Result<AuthUser>> signInWithGoogle() async => throw UnimplementedError();

  @override
  Future<Result<void>> signOut() async => const Result.success(null);
}

void main() {
  testWidgets('Med100App boots to Splash and resolves to Login without throwing', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        ],
        child: const Med100App(),
      ),
    );

    // GoRouter's initial location is /splash (app/router/app_router.dart);
    // Splash runs the session-restore check against the fake repository
    // above (no user, so it resolves to Login) and the router redirects
    // there. The assertion is that the whole DI graph, theme,
    // localization, router, and auth flow wire together without a
    // runtime error — not that any particular screen's content renders.
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Material 3 dark theme applies without error', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        ],
        child: const MediaQuery(
          data: MediaQueryData(platformBrightness: Brightness.dark),
          child: Med100App(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
