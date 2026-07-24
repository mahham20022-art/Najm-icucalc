import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/flashcard_schedule.dart';
import '../../domain/entities/repetition_stage.dart';

/// Owns all Drift access for `FlashcardSchedules`.
class FlashcardSchedulesLocalDataSource {
  FlashcardSchedulesLocalDataSource(this._db);
  final AppDatabase _db;

  String _rowId(String userId, String flashcardId) => '${userId}_$flashcardId';

  Future<FlashcardScheduleRow?> getByFlashcardId(String userId, String flashcardId) {
    final query = _db.select(_db.flashcardSchedules)
      ..where((t) => t.id.equals(_rowId(userId, flashcardId)));
    return query.getSingleOrNull();
  }

  /// Used only by [SpacedRepetitionSyncWorker]'s drain path, which pushes
  /// the domain entity rather than the raw Drift row.
  Future<FlashcardSchedule?> getEntityByFlashcardId(String userId, String flashcardId) async {
    final row = await getByFlashcardId(userId, flashcardId);
    return row == null ? null : _toEntity(row);
  }

  /// Returns whether a row was actually inserted — `false` when one
  /// already existed for this flashcard, so the repository knows not to
  /// enqueue a redundant sync (this is called as a side effect every time
  /// a topic's flashcards are fetched, so most calls are no-ops).
  Future<bool> insertIfAbsent({
    required String userId,
    required String flashcardId,
    required String topicId,
  }) async {
    final existing = await getByFlashcardId(userId, flashcardId);
    if (existing != null) return false;

    final now = DateTime.now();
    await _db
        .into(_db.flashcardSchedules)
        .insert(
          FlashcardSchedulesCompanion.insert(
            id: _rowId(userId, flashcardId),
            userId: userId,
            flashcardId: flashcardId,
            topicId: topicId,
            stage: RepetitionStage.newCard.name,
            dueDate: now,
            createdAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
    return true;
  }

  /// The "is it due" cutoff is deliberately *not* passed in and baked
  /// into the SQL `WHERE` clause — a `StreamProvider` built on this query
  /// lives far longer than a single call, and Drift's `.watch()` only
  /// re-runs a query in response to a table write, never on a timer.
  /// A fixed cutoff captured once at subscription time would silently
  /// exclude every card scheduled *after* that moment forever (their
  /// `dueDate` is later than the frozen cutoff), even though the schedule
  /// row itself is due right now. Filtering by a freshly computed
  /// `DateTime.now()` inside `.map()` instead means every table write
  /// (including a brand-new `insertIfAbsent`) re-evaluates "due" against
  /// the actual current time.
  Stream<List<FlashcardSchedule>> watchDueQueue(String userId) {
    final query = _db.select(_db.flashcardSchedules)
      ..where((t) => t.userId.equals(userId) & t.stage.isNotValue(RepetitionStage.mastered.name));
    return query.watch().map((rows) {
      final now = DateTime.now();
      final due = rows.where((r) => !r.dueDate.isAfter(now)).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return due.map(_toEntity).toList();
    });
  }

  Future<int> getDueCount(String userId) async {
    final query = _db.select(_db.flashcardSchedules)
      ..where((t) => t.userId.equals(userId) & t.stage.isNotValue(RepetitionStage.mastered.name));
    final rows = await query.get();
    final now = DateTime.now();
    return rows.where((r) => !r.dueDate.isAfter(now)).length;
  }

  Future<void> update(FlashcardScheduleRow row) async {
    await _db.update(_db.flashcardSchedules).replace(row);
  }

  /// Used only by [SpacedRepetitionSyncWorker]'s pull path — blindly
  /// overwrites this device's row with the remote copy, same
  /// last-writer-wins simplicity as `NotesSyncWorker.pullIncremental`.
  Future<void> upsertFromRemote(String userId, FlashcardSchedule schedule) async {
    await _db
        .into(_db.flashcardSchedules)
        .insertOnConflictUpdate(
          FlashcardSchedulesCompanion.insert(
            id: _rowId(userId, schedule.flashcardId),
            userId: userId,
            flashcardId: schedule.flashcardId,
            topicId: schedule.topicId,
            stage: schedule.stage.name,
            dueDate: schedule.dueDate,
            lastReviewedAt: Value(schedule.lastReviewedAt),
            timesReviewed: Value(schedule.timesReviewed),
            timesLapsed: Value(schedule.timesLapsed),
            createdAt: schedule.createdAt,
          ),
        );
  }

  Stream<List<FlashcardScheduleRow>> watchAll(String userId) {
    final query = _db.select(_db.flashcardSchedules)..where((t) => t.userId.equals(userId));
    return query.watch();
  }

  FlashcardSchedule _toEntity(FlashcardScheduleRow row) => FlashcardSchedule(
    flashcardId: row.flashcardId,
    topicId: row.topicId,
    stage: RepetitionStage.values.byName(row.stage),
    dueDate: row.dueDate,
    lastReviewedAt: row.lastReviewedAt,
    timesReviewed: row.timesReviewed,
    timesLapsed: row.timesLapsed,
    createdAt: row.createdAt,
  );
}
