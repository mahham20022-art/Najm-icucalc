// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Med100';

  @override
  String get tagline => 'One Topic. Every Day. Master Your Specialty.';

  @override
  String get navHome => 'Home';

  @override
  String get navTopics => 'Topics';

  @override
  String get navBookmarks => 'Bookmarks';

  @override
  String get navProgress => 'Progress';

  @override
  String get navProfile => 'Profile';

  @override
  String screenNotImplemented(String screenName) {
    return '$screenName — foundation only, not yet implemented';
  }

  @override
  String get routeNotFoundMessage => 'We couldn\'t find that page.';

  @override
  String get goToHome => 'Go to Home';

  @override
  String get continueLabel => 'Continue';

  @override
  String get logIn => 'Log In';

  @override
  String get register => 'Register';

  @override
  String get goToRegister => 'Don\'t have an account? Register';

  @override
  String get goToLogin => 'Already have an account? Log In';

  @override
  String get openSettings => 'Settings';

  @override
  String get openSubscription => 'Subscription';

  @override
  String get openTeachingMode => 'Teaching Mode';
}
