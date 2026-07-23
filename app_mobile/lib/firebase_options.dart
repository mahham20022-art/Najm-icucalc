// GENERATED PLACEHOLDER — replace by running `flutterfire configure`
// against a real Firebase project before this app talks to any backend.
//
// This file exists so the project compiles and Firebase.initializeApp()
// has a valid-shaped (but non-functional) FirebaseOptions to call with.
// Per `MED100_ARCHITECTURE.md` §12, the Editorial Console and consumer
// app live in *separate* Firebase projects — running `flutterfire
// configure` for this app should point at the consumer-app project only.
//
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform. '
          'Run `flutterfire configure` to generate real options.',
        );
    }
  }

  static const web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    appId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    messagingSenderId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    projectId: 'med100-placeholder',
    authDomain: 'med100-placeholder.firebaseapp.com',
    storageBucket: 'med100-placeholder.appspot.com',
  );

  static const android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    appId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    messagingSenderId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    projectId: 'med100-placeholder',
    storageBucket: 'med100-placeholder.appspot.com',
  );

  static const ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    appId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    messagingSenderId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    projectId: 'med100-placeholder',
    storageBucket: 'med100-placeholder.appspot.com',
    iosBundleId: 'com.med100.app',
  );
}
