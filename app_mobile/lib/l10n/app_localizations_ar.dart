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
}
