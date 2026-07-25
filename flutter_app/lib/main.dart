import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'screens/home.dart';
import 'services/analytics.dart';
import 'services/storage.dart';
import 'state/app_state.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait — clinical use, avoid accidental rotation on trays.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Firebase — safe if google-services.json isn't attached yet.
  try {
    await Firebase.initializeApp();
    Analytics.enable();

    // Route uncaught Flutter and platform errors to Crashlytics.
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (_) {
    // Firebase not configured — analytics and crashlytics silently disabled.
  }

  final storage = await Storage.open();

  runZonedGuarded(
    () => runApp(NajmApp(storage: storage)),
    (error, stack) {
      try { FirebaseCrashlytics.instance.recordError(error, stack); } catch (_) {}
    },
  );
}

class NajmApp extends StatelessWidget {
  final Storage storage;
  const NajmApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(storage),
      child: MaterialApp(
        title: 'Najm ICUCalc',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}
