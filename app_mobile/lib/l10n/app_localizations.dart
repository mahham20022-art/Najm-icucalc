import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The application name, shown on the splash screen.
  ///
  /// In en, this message translates to:
  /// **'Med100'**
  String get appName;

  /// PRD tagline, shown beneath the wordmark on Splash (MED100_UI_UX_SPEC.md §1).
  ///
  /// In en, this message translates to:
  /// **'One Topic. Every Day. Master Your Specialty.'**
  String get tagline;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTopics.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get navTopics;

  /// No description provided for @navBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get navBookmarks;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Placeholder body text for scaffolded routes.
  ///
  /// In en, this message translates to:
  /// **'{screenName} — foundation only, not yet implemented'**
  String screenNotImplemented(String screenName);

  /// Shown when GoRouter can't match a location, e.g. a stale deep link.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that page.'**
  String get routeNotFoundMessage;

  /// No description provided for @goToHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get goToHome;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @goToRegister.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get goToRegister;

  /// No description provided for @goToLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log In'**
  String get goToLogin;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get openSettings;

  /// No description provided for @openSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get openSubscription;

  /// No description provided for @openTeachingMode.
  ///
  /// In en, this message translates to:
  /// **'Teaching Mode'**
  String get openTeachingMode;

  /// No description provided for @challengeTodaysTopic.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Topic'**
  String get challengeTodaysTopic;

  /// No description provided for @challengeMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get challengeMarkDone;

  /// No description provided for @challengeSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get challengeSkip;

  /// No description provided for @challengeRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get challengeRestart;

  /// No description provided for @challengeRestartConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restart your journey?'**
  String get challengeRestartConfirmTitle;

  /// No description provided for @challengeRestartConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This clears all progress, streaks, and bookmarks and starts over from Day 1. This can\'t be undone.'**
  String get challengeRestartConfirmBody;

  /// No description provided for @challengeCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get challengeCancel;

  /// No description provided for @challengeAlreadyDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'See you tomorrow!'**
  String get challengeAlreadyDoneTitle;

  /// No description provided for @challengeAlreadyDoneBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve already completed today\'s step. Come back tomorrow for the next one.'**
  String get challengeAlreadyDoneBody;

  /// No description provided for @challengeJourneyComplete.
  ///
  /// In en, this message translates to:
  /// **'You completed the 100-day journey!'**
  String get challengeJourneyComplete;

  /// No description provided for @challengeCurrentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get challengeCurrentStreak;

  /// No description provided for @challengeStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{day} other{days}}'**
  String challengeStreakDays(num count);

  /// No description provided for @challengeStatisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get challengeStatisticsTitle;

  /// No description provided for @challengeCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get challengeCompletedLabel;

  /// No description provided for @challengeSkippedLabel.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get challengeSkippedLabel;

  /// No description provided for @challengeCompletionRate.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get challengeCompletionRate;

  /// No description provided for @challengeBookmarksEmpty.
  ///
  /// In en, this message translates to:
  /// **'Bookmark a day from Today\'s Topic to find it here later.'**
  String get challengeBookmarksEmpty;

  /// No description provided for @challengeReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get challengeReminderTitle;

  /// No description provided for @challengeReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get a nudge if you haven\'t done today\'s step yet'**
  String get challengeReminderSubtitle;

  /// No description provided for @challengeReminderPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications permission was denied — enable it in system settings to use reminders.'**
  String get challengeReminderPermissionDenied;

  /// No description provided for @challengeSaveReminder.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get challengeSaveReminder;

  /// No description provided for @challengeBatteryOptimizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Improve reminder reliability'**
  String get challengeBatteryOptimizationTitle;

  /// No description provided for @challengeBatteryOptimizationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let Med100 ignore battery optimization so reminders arrive on time'**
  String get challengeBatteryOptimizationSubtitle;

  /// No description provided for @challengeBatteryOptimizationAction.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get challengeBatteryOptimizationAction;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
