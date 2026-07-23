import 'package:drift/drift.dart';

import '../../../database/app_database.dart';

/// Owns all Drift access for `AiCacheLocal` — the AI Engine's caching
/// layer (`MED100_DATABASE_DESIGN.md` §10). Not per-user; see the table
/// definition's doc comment in `core/database/app_database.dart`.
class AiCacheLocalDataSource {
  AiCacheLocalDataSource(this._db);
  final AppDatabase _db;

  /// `null` if there's no entry, or it exists but has expired — either
  /// way, the caller should treat it as a cache miss.
  Future<String?> getIfFresh(String cacheKey) async {
    final query = _db.select(_db.aiCacheLocal)..where((t) => t.cacheKey.equals(cacheKey));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    if (row.expiresAt.isBefore(DateTime.now())) return null;
    return row.content;
  }

  Future<void> save({
    required String cacheKey,
    required String itemType,
    required String itemId,
    required String content,
    required DateTime expiresAt,
  }) async {
    await _db
        .into(_db.aiCacheLocal)
        .insertOnConflictUpdate(
          AiCacheLocalCompanion(
            cacheKey: Value(cacheKey),
            itemType: Value(itemType),
            itemId: Value(itemId),
            content: Value(content),
            fetchedAt: Value(DateTime.now()),
            expiresAt: Value(expiresAt),
          ),
        );
  }

  /// Deletes rows past their [AiCacheLocal.expiresAt] — opportunistic
  /// housekeeping, not a full storage-budget/LRU eviction policy (that
  /// belongs to the broader offline-content storage system described in
  /// `MED100_ARCHITECTURE.md` §11, which doesn't exist yet for any
  /// content type in this codebase).
  Future<void> pruneExpired() async {
    await (_db.delete(
      _db.aiCacheLocal,
    )..where((t) => t.expiresAt.isSmallerThanValue(DateTime.now()))).go();
  }
}
