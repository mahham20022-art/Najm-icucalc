import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/connectivity_provider.dart';
import '../../core/notifications/notification_providers.dart';
import '../../core/session/current_user.dart';
import '../../features/challenge_mode/challenge_providers.dart';
import '../../features/notes/notes_providers.dart';
import '../../features/spaced_repetition/spaced_repetition_providers.dart';
import '../../features/teaching_mode/teaching_providers.dart';

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
    // Notes' cloud sync is opportunistic, not just resume-driven — a note
    // written while offline should reach Firestore the moment
    // connectivity comes back, not wait for the user to background and
    // reopen the app.
    ref.listenManual(isOnlineProvider, (previous, isOnline) {
      if (isOnline && previous != true) {
        unawaited(triggerNotesSync(ref));
        unawaited(triggerChallengeSync(ref));
        unawaited(triggerTeachingSync(ref));
        unawaited(triggerSpacedRepetitionSync(ref));
      }
    });
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
    await _checkSpacedRepetitionDue();
    // Fire-and-forget: a potentially slow multi-request Firestore sync
    // pass shouldn't delay the notification checks above it.
    unawaited(triggerNotesSync(ref));
    unawaited(triggerChallengeSync(ref));
    unawaited(triggerTeachingSync(ref));
    unawaited(triggerSpacedRepetitionSync(ref));
  }

  /// Mirrors Challenge Mode's missed-reminder catch-up above: same
  /// once-per-day dedup via `NotificationLogDataSource.hasLoggedOn`, its
  /// own notification `type` so the two checks never suppress each
  /// other, distinct from the daily-reminder's fixed notification id so
  /// they never overwrite each other's platform notification either.
  static const _srsDueNotificationId = 1002;
  static const _srsDueType = 'srs_due';

  Future<void> _checkSpacedRepetitionDue() async {
    final userId = ref.read(currentUserProvider).userId ?? guestScopeId;
    final notificationLog = ref.read(notificationLogDataSourceProvider);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    if (await notificationLog.hasLoggedOn(userId: userId, type: _srsDueType, date: todayDate)) {
      return;
    }

    final dueCount = await ref.read(getDueCountUseCaseProvider)();
    if (dueCount == 0) return;

    final title = 'Flashcards are due for review';
    final body = dueCount == 1
        ? '1 flashcard is due for review.'
        : '$dueCount flashcards are due for review.';
    await ref
        .read(localNotificationDataSourceProvider)
        .showNow(id: _srsDueNotificationId, title: title, body: body);
    await notificationLog.record(userId: userId, type: _srsDueType, title: title, body: body);
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
