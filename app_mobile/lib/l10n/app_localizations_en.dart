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

  @override
  String get challengeTodaysTopic => 'Today\'s Topic';

  @override
  String get challengeMarkDone => 'Done';

  @override
  String get challengeSkip => 'Skip';

  @override
  String get challengeRestart => 'Restart';

  @override
  String get challengeRestartConfirmTitle => 'Restart your journey?';

  @override
  String get challengeRestartConfirmBody =>
      'This clears all progress, streaks, and bookmarks and starts over from Day 1. This can\'t be undone.';

  @override
  String get challengeCancel => 'Cancel';

  @override
  String get challengeAlreadyDoneTitle => 'See you tomorrow!';

  @override
  String get challengeAlreadyDoneBody =>
      'You\'ve already completed today\'s step. Come back tomorrow for the next one.';

  @override
  String get challengeJourneyComplete => 'You completed the 100-day journey!';

  @override
  String get challengeCurrentStreak => 'Current Streak';

  @override
  String challengeStreakDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '$count $_temp0';
  }

  @override
  String get challengeStatisticsTitle => 'Statistics';

  @override
  String get challengeCompletedLabel => 'Completed';

  @override
  String get challengeSkippedLabel => 'Skipped';

  @override
  String get challengeCompletionRate => 'Completion';

  @override
  String get challengeBookmarksEmpty =>
      'Bookmark a day from Today\'s Topic to find it here later.';

  @override
  String get challengeReminderTitle => 'Daily Reminder';

  @override
  String get challengeReminderSubtitle =>
      'Get a nudge if you haven\'t done today\'s step yet';

  @override
  String get challengeReminderPermissionDenied =>
      'Notifications permission was denied — enable it in system settings to use reminders.';

  @override
  String get challengeSaveReminder => 'Save';
}
