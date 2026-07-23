import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notifications/notification_providers.dart';
import '../../features/challenge_mode/challenge_providers.dart';

/// Wraps the authenticated app shell to drive the reminder engine's two
/// time-based checks — rescheduling and the missed-reminder catch-up —
/// on every app resume (not just cold start, since a changed timezone or
/// a missed slot can just as easily be discovered mid-session), and to
/// surface FCM pushes that arrive while the app is in the foreground
/// (which no platform auto-displays as a system notification).
///
/// Composing the reminder engine (feature-agnostic, lives in `core/`)
/// with Challenge Mode's "is today done?" question belongs here, at the
/// `app/` layer, rather than in either module directly — `core` can't
/// depend on a feature, and the reminder engine has no business knowing
/// what Challenge Mode's daily task is.
class ReminderLifecycleGate extends ConsumerStatefulWidget {
  const ReminderLifecycleGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ReminderLifecycleGate> createState() => _ReminderLifecycleGateState();
}

class _ReminderLifecycleGateState extends ConsumerState<ReminderLifecycleGate>
    with WidgetsBindingObserver {
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_runTimeBasedChecks());
    _foregroundMessageSubscription = ref
        .read(fcmDataSourceProvider)
        .onForegroundMessage
        .listen(_showForegroundMessage);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_foregroundMessageSubscription?.cancel());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_runTimeBasedChecks());
    }
  }

  Future<void> _runTimeBasedChecks() async {
    final reminderRepository = ref.read(reminderRepositoryProvider);
    await reminderRepository.rescheduleIfNeeded();
    await reminderRepository.checkMissedReminder(isTodayDone: _isChallengeTodayDone);
  }

  /// Awaits the repository's stream directly rather than reading
  /// `challengeViewModelProvider`'s synchronous state — that provider may
  /// not have been watched by any screen yet (e.g. right at cold start,
  /// before `ChallengeHomeScreen` has built), in which case a bare
  /// `ref.read` would observe its not-yet-settled `ChallengeLoading`
  /// state and wrongly conclude "not done today," risking a false
  /// missed-reminder notification for a day the user already completed.
  Future<bool> _isChallengeTodayDone() async {
    final state = await ref.read(challengeRepositoryProvider).watchState().first;
    return state.isActionedToday();
  }

  Future<void> _showForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    await ref
        .read(localNotificationDataSourceProvider)
        .showNow(
          id: DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
          title: notification.title ?? 'Med100',
          body: notification.body ?? '',
        );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
