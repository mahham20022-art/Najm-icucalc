// ignore_for_file: prefer_initializing_formals
// The constructor's named parameters intentionally use public names
// (`localDataSource`) distinct from their private backing fields
// (`_localDataSource`) for a readable call site — an initializing
// formal would force the parameter name itself to be private.

import 'package:drift/drift.dart';

import '../../../../core/session/current_user.dart';
import '../../../../core/sync/data/outbox_local_datasource.dart';
import '../../domain/entities/flashcard_schedule.dart';
import '../../domain/entities/repetition_stage.dart';
import '../../domain/entities/review_grade.dart';
import '../../domain/entities/spaced_repetition_statistics.dart';
import '../../domain/repositories/spaced_repetition_repository.dart';
import '../datasources/flashcard_schedules_local_datasource.dart';
import '../spaced_repetition_sync_worker.dart' show SpacedRepetitionSyncWorker;

/// The 7/30/90-day Leitner-style ladder: a `good` grade advances a card
/// to the next stage and pushes its due date out by that stage's
/// interval; an `again` grade resets it all the way back to `newCard`
/// (immediately due again) rather than SM-2's more forgiving
/// ease-factor decay — see `RepetitionStage`'s doc comment for why this
/// simpler scheme was chosen over the architecture docs' SM-2 design.
class SpacedRepetitionRepositoryImpl implements SpacedRepetitionRepository {
  SpacedRepetitionRepositoryImpl({
    required FlashcardSchedulesLocalDataSource localDataSource,
    required OutboxLocalDataSource outbox,
    required CurrentUser currentUser,
  }) : _localDataSource = localDataSource,
       _outbox = outbox,
       _currentUser = currentUser;

  final FlashcardSchedulesLocalDataSource _localDataSource;
  final OutboxLocalDataSource _outbox;
  final CurrentUser _currentUser;

  String get _userId => _currentUser.userId ?? guestScopeId;

  @override
  Future<void> ensureScheduled({required String flashcardId, required String topicId}) async {
    final inserted = await _localDataSource.insertIfAbsent(
      userId: _userId,
      flashcardId: flashcardId,
      topicId: topicId,
    );
    if (inserted) {
      await _enqueueSync(flashcardId);
    }
  }

  @override
  Stream<List<FlashcardSchedule>> watchDueQueue() => _localDataSource.watchDueQueue(_userId);

  @override
  Future<int> getDueCount() => _localDataSource.getDueCount(_userId);

  @override
  Future<void> recordReview({required String flashcardId, required ReviewGrade grade}) async {
    final row = await _localDataSource.getByFlashcardId(_userId, flashcardId);
    if (row == null) return;

    final currentStage = RepetitionStage.values.byName(row.stage);
    final now = DateTime.now();

    final RepetitionStage nextStage;
    final DateTime nextDueDate;
    if (grade == ReviewGrade.again) {
      nextStage = RepetitionStage.newCard;
      nextDueDate = now;
    } else {
      nextStage = currentStage.nextOnGood;
      final interval = currentStage.intervalToNext;
      nextDueDate = interval == null ? now : now.add(interval);
    }

    await _localDataSource.update(
      row.copyWith(
        stage: nextStage.name,
        dueDate: nextDueDate,
        lastReviewedAt: Value(now),
        timesReviewed: row.timesReviewed + 1,
        timesLapsed: grade == ReviewGrade.again ? row.timesLapsed + 1 : row.timesLapsed,
      ),
    );
    await _enqueueSync(flashcardId);
  }

  Future<void> _enqueueSync(String flashcardId) => _outbox.enqueue(
    userId: _userId,
    entityType: SpacedRepetitionSyncWorker.entityType,
    entityId: flashcardId,
    operation: 'update',
  );

  @override
  Stream<SpacedRepetitionStatistics> watchStatistics() {
    return _localDataSource.watchAll(_userId).map((rows) {
      final totalReviews = rows.fold<int>(0, (sum, r) => sum + r.timesReviewed);
      final totalLapses = rows.fold<int>(0, (sum, r) => sum + r.timesLapsed);
      final masteredCount = rows.where((r) => r.stage == RepetitionStage.mastered.name).length;
      final now = DateTime.now();
      final dueToday = rows
          .where((r) => r.stage != RepetitionStage.mastered.name && !r.dueDate.isAfter(now))
          .length;
      return SpacedRepetitionStatistics(
        totalScheduled: rows.length,
        dueToday: dueToday,
        masteredCount: masteredCount,
        totalReviews: totalReviews,
        totalLapses: totalLapses,
      );
    });
  }
}
