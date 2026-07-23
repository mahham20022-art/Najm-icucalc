import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/challenge_state.dart';

/// Owns all Drift access for Challenge Mode — the only place `Set<int>`
/// day sets get encoded/decoded to the JSON strings the
/// `ChallengeProgress` table actually stores (`MED100_DATABASE_DESIGN.md`
/// §0a: the row is keyed by `userId`).
class ChallengeLocalDataSource {
  ChallengeLocalDataSource(this._db);
  final AppDatabase _db;

  Stream<ChallengeState> watchState(String userId) {
    final query = _db.select(_db.challengeProgress)..where((t) => t.userId.equals(userId));
    return query.watchSingleOrNull().map((row) => _toEntity(row) ?? ChallengeState.fresh());
  }

  Future<ChallengeState> getState(String userId) async {
    final query = _db.select(_db.challengeProgress)..where((t) => t.userId.equals(userId));
    final row = await query.getSingleOrNull();
    return _toEntity(row) ?? ChallengeState.fresh();
  }

  Future<void> saveState(String userId, ChallengeState state) async {
    await _db
        .into(_db.challengeProgress)
        .insertOnConflictUpdate(
          ChallengeProgressCompanion(
            userId: Value(userId),
            startedAt: Value(state.startedAt),
            lastActionDate: Value(state.lastActionDate),
            completedDaysJson: Value(jsonEncode(state.completedDays.toList())),
            skippedDaysJson: Value(jsonEncode(state.skippedDays.toList())),
            bookmarkedDaysJson: Value(jsonEncode(state.bookmarkedDays.toList())),
          ),
        );
  }

  Future<void> deleteState(String userId) async {
    await (_db.delete(_db.challengeProgress)..where((t) => t.userId.equals(userId))).go();
  }

  ChallengeState? _toEntity(ChallengeProgressData? row) {
    if (row == null) return null;
    return ChallengeState(
      startedAt: row.startedAt,
      lastActionDate: row.lastActionDate,
      completedDays: _decodeSet(row.completedDaysJson),
      skippedDays: _decodeSet(row.skippedDaysJson),
      bookmarkedDays: _decodeSet(row.bookmarkedDaysJson),
    );
  }

  Set<int> _decodeSet(String json) => (jsonDecode(json) as List).cast<int>().toSet();
}
