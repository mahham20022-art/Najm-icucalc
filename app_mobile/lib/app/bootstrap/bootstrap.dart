import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
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

/// Matches `firebase_options.dart`'s placeholder `projectId` — used only
/// to detect and loudly warn about the placeholder still being active,
/// never as a real config value.
const _placeholderProjectId = 'med100-placeholder';

/// Runs everything that has to happen before [runApp] — Firebase
/// initialization (including Crashlytics error reporting and App Check
/// activation) and opening the local database — and returns the opened
/// database for `main.dart` to build the `ProviderScope` overrides from.
/// (Riverpod's `Override` type isn't part of its public export surface,
/// so the overrides list is assembled inline in `main.dart` where it can
/// be inferred contextually, rather than named here.)
Future<AppDatabase> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('Med100 starting in ${AppEnvironment.flavor.name} flavor');

  await _initializeFirebase();

  return AppDatabase();
}

/// Firebase initialization is deliberately non-fatal at every step: this
/// is a foundation-stage `firebase_options.dart` with placeholder
/// credentials (see that file's header), so failing to reach a real
/// project must not crash local development or CI. Each guarded step
/// below still runs — and is still worth having wired up now — because a
/// production build only has to swap in real `flutterfire configure`
/// output and a real reCAPTCHA site key for all of it to start working;
/// none of this is feature-specific, so it doesn't belong on hold until
/// the first feature is built.
Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (error, stackTrace) {
    debugPrint(
      'Firebase initialization skipped/failed (expected until '
      '`flutterfire configure` is run against a real project): $error',
    );
    debugPrintStack(stackTrace: stackTrace);
    return; // Nothing below this line can do anything useful without a real app.
  }

  if (DefaultFirebaseOptions.currentPlatform.projectId == _placeholderProjectId) {
    debugPrint(
      '⚠️  Firebase is initialized against PLACEHOLDER credentials. '
      'Crashlytics, App Check, and every other Firebase-backed service is '
      'a no-op until `flutterfire configure` points this app at a real '
      'project — do not ship a release build in this state.',
    );
  }

  // Crash reporting, per `MED100_ARCHITECTURE.md` §7.5: a production app
  // with no crash visibility is not something to knowingly ship, so this
  // is wired at foundation stage rather than left as an inert dependency.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);

  // App Check, per `MED100_ARCHITECTURE.md` §7.5/§12: described there as
  // "mandatory on every Function/Firestore path" — a dependency that's
  // never activated doesn't provide that guarantee, so this activates it
  // with debug-safe providers now and a clearly-labeled placeholder
  // reCAPTCHA site key for web, which must be replaced alongside
  // `flutterfire configure`.
  try {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      providerApple: kDebugMode ? const AppleDebugProvider() : const AppleAppAttestProvider(),
      providerWeb: ReCaptchaV3Provider('REPLACE_WITH_RECAPTCHA_SITE_KEY'),
    );
  } catch (error, stackTrace) {
    debugPrint(
      'App Check activation skipped/failed (expected until a real '
      'reCAPTCHA site key / attestation setup exists): $error',
    );
    debugPrintStack(stackTrace: stackTrace);
  }
}
