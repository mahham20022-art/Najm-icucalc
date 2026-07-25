# Najm ICUCalc — Flutter app

Native Android + iOS build of the ICU/CCU bedside assistant. Same eight modules
as the web version, wired to Firebase for analytics, crash reporting, and
optional over-the-air drug-database updates via Remote Config.

## Prerequisites

- Flutter SDK ≥ 3.19 (`flutter --version`)
- JDK 17 (Android build)
- Xcode 15+ (iOS build — macOS only)
- A Firebase project (free tier works)
- Node + `firebase-tools` for `firebase login`
- FlutterFire CLI: `dart pub global activate flutterfire_cli`

## First-time setup

```bash
cd flutter_app
flutter pub get

# Connect Firebase — creates lib/firebase_options.dart and drops
# android/app/google-services.json + iOS GoogleService-Info.plist.
firebase login
flutterfire configure --project=<your-firebase-project-id>

# Generate launcher icons (uses pubspec's flutter_launcher_icons block)
dart run flutter_launcher_icons

# Run on a connected Android device
flutter run
```

The app runs fine **without** Firebase — the init call is wrapped in
try/catch, and analytics/crashlytics are silently disabled if
`firebase_options.dart` is missing. Skip `flutterfire configure` for a
quick local build.

## Signing (release only)

Create `android/key.properties` (git-ignored — see `.gitignore`):

```
storePassword=<...>
keyPassword=<...>
keyAlias=upload
storeFile=/absolute/path/to/najm-upload-keystore.jks
```

Generate the keystore once:

```bash
keytool -genkey -v -keystore najm-upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Keep the keystore file and passwords safe** — losing them means you can
never publish another update under the same Play listing.

## Build

```bash
# App bundle for Play Store (recommended)
flutter build appbundle --release

# Signed APK (side-load / testing)
flutter build apk --release --split-per-abi
```

Outputs land in `build/app/outputs/bundle/release/` (`.aab`) and
`build/app/outputs/flutter-apk/` (`.apk`).

## Firebase modules used

| Module               | What it does                                         |
|----------------------|------------------------------------------------------|
| `firebase_core`      | Init                                                 |
| `firebase_analytics` | Screen-view logs per tab (opt-in, no PII)            |
| `firebase_crashlytics` | Uncaught Flutter + platform errors                 |
| `firebase_remote_config` | (reserved) push drug-range corrections without a store release |

Every Firebase call is wrapped so the app runs correctly even when
Firebase isn't reachable or configured.

## Privacy

- No PHI is sent anywhere. Patient values live only in `SharedPreferences`
  on the device.
- Analytics events are limited to screen-view names (`infusions`, `abg`,
  etc.) and non-PII usage counters. See `lib/services/analytics.dart`.
- Data-extraction is disabled in `AndroidManifest.xml` (no auto-backup
  of local state to Google account).

## Disclaimer

Reference aid only — not a medical device. See `../privacy-policy.html`
for the full policy.
