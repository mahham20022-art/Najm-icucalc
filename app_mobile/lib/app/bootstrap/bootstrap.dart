import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../firebase_options.dart';
import 'app_flavor.dart';

/// Shared, uninitialized instance provider — overridden with the real,
/// already-opened database in [bootstrap] before the app widget tree is
/// built (see `main.dart`). Per `MED100_ARCHITECTURE.md` §6, this is the
/// composition-root seam that also lets widget tests override it with an
/// in-memory database.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('appDatabaseProvider must be overridden in bootstrap()');
});

/// Runs everything that has to happen before [runApp] — Firebase
/// initialization and opening the local database — and returns the
/// opened database for `main.dart` to build the `ProviderScope` overrides
/// from. (Riverpod's `Override` type isn't part of its public export
/// surface, so the overrides list is assembled inline in `main.dart`
/// where it can be inferred contextually, rather than named here.)
///
/// Firebase initialization is deliberately non-fatal: this is a
/// foundation-stage `firebase_options.dart` with placeholder credentials
/// (see that file's header), so failing to reach a real project must not
/// crash local development or CI. A production build points
/// `flutterfire configure` at a real project, at which point this
/// still behaves identically — the guard only matters while options
/// are placeholders.
Future<AppDatabase> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('Med100 starting in ${AppEnvironment.flavor.name} flavor');

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (error, stackTrace) {
    debugPrint(
      'Firebase initialization skipped/failed (expected until '
      '`flutterfire configure` is run against a real project): $error',
    );
    debugPrintStack(stackTrace: stackTrace);
  }

  return AppDatabase();
}
