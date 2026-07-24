import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

import '../../firebase_options.dart';

const _placeholderProjectId = 'med100-placeholder';

/// Mirrors `app_mobile`'s `bootstrap()` — Firebase initialization is
/// non-fatal here for the same reason: `firebase_options.dart` is a
/// placeholder until `flutterfire configure` runs against a real
/// project (see that file's doc comment for the additional
/// architecture-deviation note specific to this admin app).
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (error, stackTrace) {
    debugPrint(
      'Firebase initialization skipped/failed (expected until '
      '`flutterfire configure` is run against a real project): $error',
    );
    debugPrintStack(stackTrace: stackTrace);
    return;
  }

  if (DefaultFirebaseOptions.currentPlatform.projectId == _placeholderProjectId) {
    debugPrint(
      '⚠️  Firebase is initialized against PLACEHOLDER credentials. '
      'Auth/Firestore/Functions calls are no-ops until `flutterfire '
      'configure` points this app at a real project — do not use this '
      'dashboard against production data in this state.',
    );
  }
}
