# Med100 — Flutter App (Foundation)

This is the project foundation only — architecture scaffolding and DI wiring,
no feature implementation. It follows `docs/MED100_ARCHITECTURE.md`,
`docs/MED100_DATABASE_DESIGN.md`, and `docs/MED100_DESIGN_SYSTEM.md` from the
repository root.

## Stack

- Flutter (latest stable) · Material 3
- Riverpod (`flutter_riverpod`) for state management and dependency injection
- GoRouter, with an adaptive phone/tablet navigation shell
- Firebase (Auth, Firestore, Storage, Messaging, Remote Config, App Check,
  Crashlytics, Analytics, Performance)
- Drift (SQLite) for the offline-first local database
- `flutter_localizations` + `intl`, English and Arabic (RTL) at foundation stage

## Architecture

Clean Architecture + MVVM + Repository Pattern, per `MED100_ARCHITECTURE.md`
§2–6:

- `lib/core/` — cross-cutting infrastructure shared by every feature:
  error/`Result` types, the offline-first `Outbox`/`SyncState` Drift tables,
  connectivity (seeded with the current state, not just future changes),
  responsive breakpoints, the analytics facade, and a provider-agnostic
  `CurrentUser` session contract that per-user repository caching should key
  off of (see `core/session/current_user.dart`) so a shared/re-logged-in
  device can't leak one user's cached data into another's session.
- `lib/app/` — the composition root: theme (built from
  `MED100_DESIGN_SYSTEM.md`'s tokens), router, and bootstrap.
- `lib/features/<feature>/{data,domain,presentation}` — one folder per
  domain module from `MED100_ARCHITECTURE.md` §2. `daily_topic` is fully
  wired end-to-end (entity → repository → use case → ViewModel) using
  in-memory/sample data as a reference for the pattern; every other feature
  folder is scaffolded but empty — building them out is feature work, not
  foundation work.

## Navigation

Every screen is a [`PlaceholderScreen`](lib/shared/widgets/placeholder_screen.dart)
— no business logic, no data, no auth — but the graph between them is real and
tappable, not just routes that exist in isolation:

- `Splash → Onboarding → Login ⇄ Register → Home` (`PlaceholderAction` buttons
  drive each step; none of them do anything but navigate).
- A 5-tab shell (`Home`, `Topics`, `Progress`, `Bookmarks`, `Profile`) — bottom
  `NavigationBar` on phone, side `NavigationRail` on tablet
  (`shared/widgets/app_shell.dart`). Five tabs is one more than the four-tab
  cap `MED100_UI_UX_SPEC.md` §4 recommends; that's this app's explicit
  navigation list, not an oversight.
- `Profile → Settings` / `Profile → Subscription` are pushed routes, reachable
  from buttons on the Profile placeholder itself, not just addressable by URL.
- A themed `RouteErrorScreen` (not go_router's generic default) handles any
  path that doesn't match, per `shared/widgets/route_error_screen.dart`.

## Getting started

```bash
flutter pub get
flutter gen-l10n            # regenerates lib/l10n/app_localizations*.dart
dart run build_runner build --delete-conflicting-outputs   # regenerates lib/core/database/app_database.g.dart
```

### Firebase

`lib/firebase_options.dart` is a **placeholder** with dummy credentials so the
project compiles before a real Firebase project exists. Before running
against a backend:

```bash
flutterfire configure
```

Per `MED100_ARCHITECTURE.md` §12, the Editorial Console uses a **separate**
Firebase project from this consumer app — make sure `flutterfire configure`
points at the consumer-app project.

Crashlytics error reporting and App Check activation are already wired in
`app/bootstrap/bootstrap.dart` (both guarded — they no-op safely against the
placeholder config), so both start working the moment real credentials are in
place. App Check's web provider still needs a real reCAPTCHA site key
(`REPLACE_WITH_RECAPTCHA_SITE_KEY` in `bootstrap.dart`) even after
`flutterfire configure`, since that value isn't part of `flutterfire`'s output.

### Flavors

```bash
flutter run --dart-define=FLAVOR=dev      # default
flutter run --dart-define=FLAVOR=staging
flutter run --dart-define=FLAVOR=prod
```

## Tests

`test/widget/app_smoke_test.dart` boots the app against an in-memory Drift
database and asserts it renders without throwing, in both themes. Native
sqlite3 test binaries are fetched by Dart's native-assets build step the
first time you run `flutter test`, which needs full network access.
