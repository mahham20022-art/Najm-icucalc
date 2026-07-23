/// Unified permission outcome across the local-notification plugin and
/// Firebase Messaging — the two report status slightly differently per
/// platform, so the repository collapses both into this one result
/// rather than leaking either SDK's type into the domain layer.
enum NotificationPermissionStatus {
  granted,
  denied,

  /// iOS "provisional" authorization — notifications are delivered
  /// quietly (no prompt shown) until the user interacts with one.
  provisional,
}
