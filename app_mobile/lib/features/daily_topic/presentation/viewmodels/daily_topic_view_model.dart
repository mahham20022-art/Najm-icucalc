import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/topic.dart';
import '../../daily_topic_providers.dart';

/// Immutable UI state — the View only ever renders this, never a raw
/// [Result] or domain entity directly, per `MED100_ARCHITECTURE.md` §4.
sealed class DailyTopicState extends Equatable {
  const DailyTopicState();

  @override
  List<Object?> get props => [];
}

class DailyTopicLoading extends DailyTopicState {
  const DailyTopicLoading();
}

class DailyTopicLoaded extends DailyTopicState {
  const DailyTopicLoaded(this.topic);
  final Topic topic;

  @override
  List<Object?> get props => [topic];
}

class DailyTopicError extends DailyTopicState {
  const DailyTopicError(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// MVVM ViewModel, implemented as a Riverpod [Notifier] per
/// `MED100_ARCHITECTURE.md` §4 — holds UI state, exposes intent methods,
/// and calls use cases only. It never reaches for a repository or a
/// Firebase SDK type directly.
class DailyTopicViewModel extends Notifier<DailyTopicState> {
  @override
  DailyTopicState build() {
    _load();
    return const DailyTopicLoading();
  }

  Future<void> _load() async {
    final useCase = ref.read(getTodaysTopicUseCaseProvider);
    final result = await useCase();
    state = result.when(success: DailyTopicLoaded.new, failure: DailyTopicError.new);
  }

  Future<void> retry() async {
    state = const DailyTopicLoading();
    await _load();
  }
}

final dailyTopicViewModelProvider = NotifierProvider<DailyTopicViewModel, DailyTopicState>(
  DailyTopicViewModel.new,
);
