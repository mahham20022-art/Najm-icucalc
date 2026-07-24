/// Route names as constants, same convention as `app_mobile`'s
/// `AppRoute` — screens navigate by name, never a hand-built path
/// string.
abstract final class AppRoute {
  static const login = 'login';
  static const notAuthorized = 'not-authorized';

  // "Manage" group.
  static const users = 'users';
  static const topics = 'topics';
  static const learningPaths = 'learning-paths';
  static const notificationsMgmt = 'notifications-mgmt';
  static const subscriptionsMgmt = 'subscriptions-mgmt';

  // "Insights" group.
  static const analytics = 'analytics';
  static const revenue = 'revenue';

  // "Content & Engagement" group.
  static const medicalContent = 'medical-content';
  static const pushNotifications = 'push-notifications';
}
