import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap/bootstrap.dart';
import '../session/current_user.dart';
import 'data/datasources/battery_optimization_datasource.dart';
import 'data/datasources/fcm_datasource.dart';
import 'data/datasources/local_notification_datasource.dart';
import 'data/datasources/notification_log_datasource.dart';
import 'data/datasources/reminder_settings_datasource.dart';
import 'data/repositories/reminder_repository_impl.dart';
import 'domain/repositories/reminder_repository.dart';

/// The reminder engine's DI graph. All five datasources are singletons
/// for the app's lifetime — each owns some native/plugin-level state
/// (the local-notifications plugin's init flag, the Drift connection)
/// that shouldn't be recreated per rebuild.
final localNotificationDataSourceProvider = Provider<LocalNotificationDataSource>((ref) {
  return LocalNotificationDataSource();
});

final fcmDataSourceProvider = Provider<FcmDataSource>((ref) {
  return FcmDataSource();
});

final batteryOptimizationDataSourceProvider = Provider<BatteryOptimizationDataSource>((ref) {
  return BatteryOptimizationDataSource();
});

final reminderSettingsDataSourceProvider = Provider<ReminderSettingsDataSource>((ref) {
  return ReminderSettingsDataSource(ref.watch(appDatabaseProvider));
});

final notificationLogDataSourceProvider = Provider<NotificationLogDataSource>((ref) {
  return NotificationLogDataSource(ref.watch(appDatabaseProvider));
});

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepositoryImpl(
    settingsDataSource: ref.watch(reminderSettingsDataSourceProvider),
    localNotifications: ref.watch(localNotificationDataSourceProvider),
    fcm: ref.watch(fcmDataSourceProvider),
    batteryOptimization: ref.watch(batteryOptimizationDataSourceProvider),
    notificationLog: ref.watch(notificationLogDataSourceProvider),
    currentUser: ref.watch(currentUserProvider),
  );
});
