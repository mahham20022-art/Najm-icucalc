// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'ميد١٠٠';

  @override
  String get tagline => 'موضوع واحد. كل يوم. أتقن تخصصك.';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navTopics => 'المواضيع';

  @override
  String get navBookmarks => 'المحفوظات';

  @override
  String get navProgress => 'التقدم';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String screenNotImplemented(String screenName) {
    return '$screenName — الأساس فقط، لم يُنفَّذ بعد';
  }

  @override
  String get routeNotFoundMessage => 'تعذّر العثور على هذه الصفحة.';

  @override
  String get goToHome => 'الذهاب إلى الرئيسية';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get logIn => 'تسجيل الدخول';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get goToRegister => 'ليس لديك حساب؟ أنشئ حسابًا';

  @override
  String get goToLogin => 'لديك حساب بالفعل؟ سجّل الدخول';

  @override
  String get openSettings => 'الإعدادات';

  @override
  String get openSubscription => 'الاشتراك';

  @override
  String get openTeachingMode => 'وضع التدريس';

  @override
  String get challengeTodaysTopic => 'موضوع اليوم';

  @override
  String get challengeMarkDone => 'تم';

  @override
  String get challengeSkip => 'تخطٍّ';

  @override
  String get challengeRestart => 'إعادة البدء';

  @override
  String get challengeRestartConfirmTitle => 'إعادة بدء رحلتك؟';

  @override
  String get challengeRestartConfirmBody =>
      'سيؤدي هذا إلى مسح كل التقدم والسلاسل والمحفوظات والبدء من جديد من اليوم الأول. لا يمكن التراجع عن هذا.';

  @override
  String get challengeCancel => 'إلغاء';

  @override
  String get challengeAlreadyDoneTitle => 'أراك غدًا!';

  @override
  String get challengeAlreadyDoneBody =>
      'لقد أكملت خطوة اليوم بالفعل. عد غدًا للخطوة التالية.';

  @override
  String get challengeJourneyComplete => 'لقد أكملت رحلة المئة يوم!';

  @override
  String get challengeCurrentStreak => 'السلسلة الحالية';

  @override
  String challengeStreakDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أيام',
      one: 'يوم',
    );
    return '$count $_temp0';
  }

  @override
  String get challengeStatisticsTitle => 'الإحصائيات';

  @override
  String get challengeCompletedLabel => 'مكتمل';

  @override
  String get challengeSkippedLabel => 'متخطّى';

  @override
  String get challengeCompletionRate => 'نسبة الإنجاز';

  @override
  String get challengeBookmarksEmpty =>
      'احفظ يومًا من موضوع اليوم لتجده هنا لاحقًا.';

  @override
  String get challengeReminderTitle => 'تذكير يومي';

  @override
  String get challengeReminderSubtitle =>
      'احصل على تنبيه إذا لم تكمل خطوة اليوم بعد';

  @override
  String get challengeReminderPermissionDenied =>
      'تم رفض إذن الإشعارات — فعّله من إعدادات النظام لاستخدام التذكيرات.';

  @override
  String get challengeSaveReminder => 'حفظ';
}
