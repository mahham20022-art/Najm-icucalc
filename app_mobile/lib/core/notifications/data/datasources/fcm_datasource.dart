import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// Must be a top-level (or static) function — the platform spawns a
/// separate isolate to run it when a data message arrives while the app
/// is backgrounded/terminated, so it can't close over any app state.
/// Registered once in `bootstrap()`, guarded the same way every other
/// Firebase product is (`MED100_ARCHITECTURE.md`: non-fatal until
/// `flutterfire configure` points this app at a real project).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM background message received: ${message.messageId}');
}

/// Thin wrapper over `firebase_messaging` — the server-push half of the
/// reminder engine. Per `MED100_ARCHITECTURE.md` §11, FCM is the primary
/// delivery path for the daily reminder; [LocalNotificationDataSource]'s
/// scheduled alarm is the fallback for when delivery can't be confirmed
/// (e.g. no connectivity), not the other way around.
class FcmDataSource {
  FcmDataSource({
    FirebaseMessaging? messaging,
    FirebaseFirestore? firestore,
    FlutterSecureStorage? secureStorage,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final FlutterSecureStorage _secureStorage;

  static const _deviceIdKey = 'notifications.device_id';

  /// `null` if Firebase isn't reachable (placeholder credentials) or the
  /// user hasn't granted permission — every caller must treat a missing
  /// token as "FCM is unavailable right now, rely on the local fallback"
  /// rather than an error.
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (error, stackTrace) {
      debugPrint('FCM getToken failed (expected without a real Firebase project): $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  Future<AuthorizationStatus> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(alert: true, badge: true, sound: true);
      return settings.authorizationStatus;
    } catch (error, stackTrace) {
      debugPrint('FCM requestPermission failed (expected without a real Firebase project): $error');
      debugPrintStack(stackTrace: stackTrace);
      return AuthorizationStatus.denied;
    }
  }

  /// Messages that arrive while the app is in the foreground — FCM does
  /// not auto-display these as a system notification on any platform, so
  /// the caller is expected to hand them to
  /// `LocalNotificationDataSource.showNow`.
  Stream<RemoteMessage> get onForegroundMessage => FirebaseMessaging.onMessage;

  /// Fired when the user taps a notification that brought the app from
  /// background to foreground.
  Stream<RemoteMessage> get onMessageOpenedApp => FirebaseMessaging.onMessageOpenedApp;

  /// The message that launched the app from a fully terminated state, if
  /// any — checked once at startup since `onMessageOpenedApp` only fires
  /// for background-to-foreground transitions, not cold starts.
  Future<RemoteMessage?> getInitialMessage() => _messaging.getInitialMessage();

  /// Registers this device's current FCM token to
  /// `users/{userId}/notificationTokens/{deviceId}`
  /// (`MED100_DATABASE_DESIGN.md` §11) so the (not-yet-built) server-side
  /// fan-out job has somewhere to deliver the daily reminder push to.
  /// Best-effort and entirely non-fatal: with placeholder Firebase
  /// credentials this simply fails silently, same as every other
  /// Firestore write in this foundation-stage app.
  Future<void> registerToken(String userId) async {
    final token = await getToken();
    if (token == null) return;

    try {
      final deviceId = await _getOrCreateDeviceId();
      final now = DateTime.now();
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notificationTokens')
          .doc(deviceId)
          .set({
            'fcmToken': token,
            'deviceId': deviceId,
            'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
            'registeredAt': now,
            'lastSeenAt': now,
          }, SetOptions(merge: true));
    } catch (error, stackTrace) {
      debugPrint('FCM token registration skipped/failed (expected without a real project): $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<String> _getOrCreateDeviceId() async {
    final existing = await _secureStorage.read(key: _deviceIdKey);
    if (existing != null) return existing;

    final generated = const Uuid().v4();
    await _secureStorage.write(key: _deviceIdKey, value: generated);
    return generated;
  }
}
