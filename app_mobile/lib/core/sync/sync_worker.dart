import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';

/// Contract for the background process that drains [Outbox] entries to
/// Cloud Functions and pulls remote changes into the local database.
///
/// This is a foundation-level interface only — per `MED100_ARCHITECTURE.md`
/// §9 (Cloud Sync), the actual drain loop, exponential backoff, and
/// Firestore listener wiring are feature-level work for each domain
/// module (daily_topic, spaced_repetition, etc.) to implement against
/// this contract, not something to build out before any feature exists.
abstract interface class SyncWorker {
  /// Attempts to drain all pending [Outbox] rows for [userId]. Safe to
  /// call opportunistically (app foreground, connectivity restored) —
  /// implementations must be idempotent and non-blocking.
  Future<void> drainOutbox(String userId);

  /// Pulls remote changes for [entityType] since its `sync_state`
  /// watermark and upserts them into the local database.
  Future<void> pullIncremental(String entityType);
}

/// Placeholder provider — overridden with a real implementation once a
/// feature module needs it. Left unimplemented deliberately: a fake
/// concrete class here would misrepresent working sync behavior that
/// doesn't exist yet.
final syncWorkerProvider = Provider<SyncWorker>((ref) {
  throw UnimplementedError('Provide a concrete SyncWorker once a feature module wires up sync.');
});
