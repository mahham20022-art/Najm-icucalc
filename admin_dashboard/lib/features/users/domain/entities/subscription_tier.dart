/// Mirrors `MED100_DATABASE_DESIGN.md` §12's `subscriptions/{userId}.tier`
/// — a small local copy rather than a shared dependency on `app_mobile`'s
/// own subscription feature, since these are two independent Flutter
/// projects (see `core/error/failure.dart`'s doc comment for the same
/// reasoning applied to `Result`/`Failure`).
enum ManagedUserTier { free, premium, unknown }
