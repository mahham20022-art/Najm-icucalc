import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med100/app/app.dart';
import 'package:med100/app/bootstrap/bootstrap.dart';
import 'package:med100/core/database/app_database.dart';

void main() {
  testWidgets('Med100App boots to the Splash placeholder without throwing', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const Med100App(),
      ),
    );

    // GoRouter's initial location is /splash (app/router/app_router.dart);
    // this is the whole assertion this foundation-stage test makes — that
    // the DI graph, theme, localization, and router all wire together
    // without a runtime error, not that Splash behaves any particular way.
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Splash'), findsOneWidget);
  });

  testWidgets('Material 3 dark theme applies without error', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const MediaQuery(
          data: MediaQueryData(platformBrightness: Brightness.dark),
          child: Med100App(),
        ),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
