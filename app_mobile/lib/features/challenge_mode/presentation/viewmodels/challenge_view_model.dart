import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/session/current_user.dart';
import '../../challenge_providers.dart';
import '../../domain/entities/challenge_state.dart';

/// Immutable UI state — the View only ever renders this, never a raw
/// [ChallengeState] straight from the stream, per
/// `MED100_ARCHITECTURE.md` §4.
sealed class ChallengeUiState extends Equatable {
  const ChallengeUiState();

  @override
  List<Object?> get props => [];
}

class ChallengeLoading extends ChallengeUiState {
  const ChallengeLoading();
}

class ChallengeLoaded extends ChallengeUiState {
  const ChallengeLoaded(this.state);
  final ChallengeState state;

  @override
  List<Object?> get props => [state];
}

class ChallengeError extends ChallengeUiState {
  const ChallengeError(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Drift's `watchState()` is already the single source of truth for
/// Challenge Mode's data — this just lifts it into Riverpod so the
/// ViewModel (and anything that watches it) rebuilds the moment a row
/// changes, without a manual refetch after every mutation.
final _challengeStateStreamProvider = StreamProvider<ChallengeState>((ref) {
  return ref.watch(challengeRepositoryProvider).watchState();
});

/// MVVM ViewModel, implemented as a Riverpod [Notifier]. Mutating methods
/// call use cases and return the resulting [Failure] (or `null` on
/// success) so the widget can react once — e.g. a snackbar for
/// `AlreadyActionedTodayFailure` — without the ViewModel owning any
/// transient "last error" field that could go stale.
class ChallengeViewModel extends Notifier<ChallengeUiState> {
  @override
  ChallengeUiState build() {
    final asyncState = ref.watch(_challengeStateStreamProvider);
    return asyncState.when(
      data: ChallengeLoaded.new,
      loading: () => const ChallengeLoading(),
      error: (error, _) => ChallengeError(CacheFailure(error.toString())),
    );
  }

  Future<Failure?> markDone() async {
    final result = await ref.read(markDayDoneUseCaseProvider)();
    return result.failureOrNull;
  }

  Future<Failure?> skip() async {
    final result = await ref.read(skipDayUseCaseProvider)();
    return result.failureOrNull;
  }

  Future<Failure?> restart() async {
    final result = await ref.read(restartChallengeUseCaseProvider)();
    return result.failureOrNull;
  }

  Future<Failure?> toggleBookmark(int day) async {
    final result = await ref.read(toggleBookmarkUseCaseProvider)(day);
    return result.failureOrNull;
  }

  String get _userId => ref.read(currentUserProvider).userId ?? guestScopeId;

  Future<({bool enabled, int hour, int minute})> reminderSettings() {
    return ref.read(challengeLocalDataSourceProvider).getReminderSettings(_userId);
  }

  /// Requests OS notification permission, then schedules or cancels the
  /// daily reminder to match [enabled] — the permission prompt only ever
  /// fires from this direct user interaction, never proactively.
  Future<bool> setReminder({required bool enabled, required int hour, required int minute}) async {
    final scheduler = ref.read(challengeReminderSchedulerProvider);
    if (enabled) {
      final granted = await scheduler.requestPermission();
      if (!granted) return false;
      await scheduler.scheduleDaily(hour: hour, minute: minute);
    } else {
      await scheduler.cancel();
    }
    await ref
        .read(challengeLocalDataSourceProvider)
        .setReminderSettings(_userId, enabled: enabled, hour: hour, minute: minute);
    return true;
  }
}

final challengeViewModelProvider = NotifierProvider<ChallengeViewModel, ChallengeUiState>(
  ChallengeViewModel.new,
);
