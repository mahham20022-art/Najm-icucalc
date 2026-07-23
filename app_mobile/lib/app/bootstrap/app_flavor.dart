/// Build-flavor, per `MED100_ARCHITECTURE.md` §6 — selects which
/// Firebase project/environment the composition root points at.
/// Passed in via `--dart-define=FLAVOR=dev|staging|prod` at build/run
/// time; defaults to [dev] so a plain `flutter run` works out of the box.
enum AppFlavor { dev, staging, prod }

class AppEnvironment {
  const AppEnvironment._();

  static AppFlavor get flavor {
    const raw = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    return AppFlavor.values.firstWhere((f) => f.name == raw, orElse: () => AppFlavor.dev);
  }

  static bool get isProduction => flavor == AppFlavor.prod;
}
