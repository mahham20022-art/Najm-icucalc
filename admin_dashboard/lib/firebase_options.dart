// GENERATED PLACEHOLDER — replace by running `flutterfire configure`
// against a real Firebase project before this app talks to any backend.
//
// **Read before shipping — this deliberately deviates from
// `MED100_ARCHITECTURE.md` §12.** That document made a firm decision
// (its own words: "a firm decision rather than 'considered'") that
// internal admin/editorial tooling should run as a Next.js app in its
// own dedicated Firebase project with its own Auth tenant, specifically
// so a compromise of the higher-exposure consumer app can never cascade
// into content-publishing/admin access. This app was built instead as a
// Flutter Web app sharing the *same* Firebase project as `app_mobile`,
// per this feature's explicit build instruction. That trade-off is real
// and should be revisited before this dashboard is used for anything
// beyond internal, VPN/trusted-network-style access: at minimum, the
// `admin`/`editor` custom-claim check in `core/session/admin_session.dart`
// is a UX convenience only (same caveat the architecture doc makes about
// client-side RBAC in general) — Firestore Security Rules on the shared
// project must independently enforce that only admin/editor-claimed
// tokens can read/write the collections this dashboard touches, or this
// app's login gate is not a real security boundary.
//
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => web;

  static const web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    appId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    messagingSenderId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    projectId: 'med100-placeholder',
    authDomain: 'med100-placeholder.firebaseapp.com',
    storageBucket: 'med100-placeholder.appspot.com',
  );
}
