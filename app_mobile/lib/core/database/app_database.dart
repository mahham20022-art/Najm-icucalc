import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Pending mutations awaiting sync, per `MED100_DATABASE_DESIGN.md` §16.
///
/// This is genuinely cross-cutting infrastructure — every client-writable
/// feature (quiz attempts, flashcard grades, bookmarks, settings) drains
/// through the same outbox — which is why it lives in `core/`, not inside
/// a single feature module.
class Outbox extends Table {
  /// The `clientOpId` (UUID v4) — see `MED100_DATABASE_DESIGN.md` §0 on
  /// idempotency. Using it directly as the primary key means a retried
  /// enqueue is naturally a no-op rather than a duplicate row.
  TextColumn get id => text()();

  /// See §0a (local per-user table scoping) — required on every per-user
  /// local table so a shared/re-logged-in device can't cross-contaminate
  /// two users' pending writes.
  TextColumn get userId => text()();

  /// `quiz_attempt | flashcard_grade | bookmark | settings |
  /// achievement_seen | note | note_folder`
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();

  /// `create | update | delete` — `delete` added for `features/notes`
  /// (the first real drainer of this table, see `NotesSyncWorker`):
  /// unlike every entity type above, a note or folder can actually be
  /// deleted, not just created/edited, so the vocabulary needed a third
  /// value to tell the sync worker to remove the remote document rather
  /// than upsert it.
  TextColumn get operation => text()();
  TextColumn get payloadJson => text()();

  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();

  /// `pending | in_flight | failed | synced`
  TextColumn get status => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Per-entity-type sync watermarks, per `MED100_DATABASE_DESIGN.md` §16 —
/// lets incremental pull-sync resume from where it left off instead of
/// re-pulling an entire collection on every app open.
///
/// `userId` was added in schema v8, alongside `features/notes` becoming
/// the first real consumer of this table (every table added before it
/// went unused by any actual sync worker — see `core/sync/sync_worker.dart`).
/// Without it, a shared/re-logged-in device would carry one user's pull
/// watermark into another user's sync, same class of bug §0a's per-user
/// local-table scoping rule exists to prevent everywhere else — worth
/// fixing now, before any real data depends on the old shape, rather than
/// carrying it forward as a known gap.
class SyncState extends Table {
  TextColumn get userId => text()();

  /// e.g. `topics`, `flashcards`, `mcqs`, `progress`, `notes`.
  TextColumn get entityType => text()();
  DateTimeColumn get lastPulledAt => dateTime().nullable()();
  DateTimeColumn get lastPushedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {userId, entityType};
}

/// Challenge Mode's entire persisted state (100-day journey) — one row
/// per user, per the same per-user local-table scoping rule as every
/// other table here. Day sets are stored as JSON-encoded int arrays
/// since Drift has no native set/array column type; the data layer
/// (`ChallengeLocalDataSource`) owns encoding/decoding, never the domain
/// entity.
///
/// Reminder preferences used to live on this table, but "remind me daily"
/// is a cross-feature concern (the architecture doc's daily-notification
/// fan-out is keyed off a top-level user preference, not Challenge Mode
/// specifically) — see `ReminderPreference` below, owned by
/// `core/notifications`.
class ChallengeProgress extends Table {
  TextColumn get userId => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get lastActionDate => dateTime().nullable()();
  TextColumn get completedDaysJson => text().withDefault(const Constant('[]'))();
  TextColumn get skippedDaysJson => text().withDefault(const Constant('[]'))();
  TextColumn get bookmarkedDaysJson => text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {userId};
}

/// The reminder engine's own persisted schedule — one row per user, per
/// `MED100_DATABASE_DESIGN.md` §0a. Lives in `core/` (not a feature
/// module) since any feature may eventually want to nudge the user via
/// the same daily-reminder slot (`MED100_ARCHITECTURE.md` §7.3 describes
/// this exact mechanism for Today's Topic).
class ReminderPreference extends Table {
  TextColumn get userId => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(false))();
  IntColumn get hour => integer().withDefault(const Constant(19))();
  IntColumn get minute => integer().withDefault(const Constant(0))();

  /// The IANA timezone identifier the daily notification was last
  /// scheduled against — compared to the device's current timezone on
  /// every app resume so travel across timezones triggers a reschedule
  /// instead of silently firing at the wrong local time.
  TextColumn get timezoneId => text().nullable()();

  /// The last calendar date (local, time-of-day stripped) a reminder
  /// notification was actually shown for — local-schedule fire, FCM
  /// fallback, or missed-reminder catch-up alike. Drives both
  /// duplicate-suppression (don't catch-up twice in one day) and
  /// missed-reminder detection (today's slot passed with nothing logged).
  DateTimeColumn get lastNotifiedDate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {userId};
}

/// Mirrors `MED100_DATABASE_DESIGN.md` §11's `notifications_local` table
/// — the log target for both server-delivered (FCM) and on-device
/// fallback notifications, so the notification history doesn't need to
/// distinguish the two sources.
class NotificationLog extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();

  /// `daily_reminder | streak_risk | achievement | billing` — only
  /// `daily_reminder` is actually produced by this codebase today.
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get payloadJson => text().withDefault(const Constant('{}'))();
  TextColumn get deepLink => text().nullable()();
  DateTimeColumn get receivedAt => dateTime()();
  DateTimeColumn get readAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Mirrors `MED100_DATABASE_DESIGN.md` §10's `ai_cache_local` table — the
/// AI Engine's on-device cache of generated content (topic summaries,
/// MCQ explanations). Deliberately *not* per-user scoped: unlike
/// Challenge Progress or Reminder Preferences, an AI summary for a given
/// topic/model/prompt combination is identical for every user, so the
/// cache key (`core/ai`'s `sha256(promptType + inputHash + modelVersion)`,
/// same formula as the server-side `aiCache` collection) is the whole
/// identity — there is nothing to scope per user.
class AiCacheLocal extends Table {
  TextColumn get cacheKey => text()();

  /// `mcq | topic | flashcard` — mirrors the docs' `itemType`.
  TextColumn get itemType => text()();
  TextColumn get itemId => text()();
  TextColumn get content => text()();
  DateTimeColumn get fetchedAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime()();

  @override
  Set<Column> get primaryKey => {cacheKey};
}

/// A completed Teaching Mode session — Med100's signature "teach it back"
/// feature. Per-user (unlike `AiCacheLocal`): a teach-back explanation
/// and its evaluation are personal progress, not shared content, per
/// `MED100_DATABASE_DESIGN.md` §0a's per-user local-table scoping rule.
///
/// `@DataClassName` avoids Drift's default row-class name colliding with
/// `features/teaching_mode/domain/entities/teaching_session.dart`'s
/// `TeachingSession` domain entity — Drift would otherwise strip the
/// table name's trailing "s" and generate a class of that exact name.
@DataClassName('TeachingSessionRow')
class TeachingSessions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get topicId => text()();
  TextColumn get topicTitle => text()();

  /// `voice | written`.
  TextColumn get mode => text()();
  TextColumn get explanationText => text()();

  IntColumn get accuracyScore => integer()();
  IntColumn get clinicalReasoningScore => integer()();
  IntColumn get completenessScore => integer()();
  IntColumn get confidenceScore => integer()();
  TextColumn get missingConceptsJson => text().withDefault(const Constant('[]'))();
  TextColumn get hallucinationsJson => text().withDefault(const Constant('[]'))();
  TextColumn get feedback => text()();

  /// Stored rather than only re-derived, so history queries (e.g. "best
  /// score for this topic") don't need to load and recompute every row.
  IntColumn get masteryScore => integer()();

  DateTimeColumn get completedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Mirrors `MED100_DATABASE_DESIGN.md` §12's `subscription_cache` — a
/// read-only local mirror of server-computed entitlement (see
/// `Subscription`'s and `SubscriptionRepositoryImpl`'s doc comments for
/// how this foundation-stage client stands in for the real
/// billing-webhook write path).
class SubscriptionCache extends Table {
  TextColumn get userId => text()();
  TextColumn get tier => text()();
  TextColumn get status => text()();
  DateTimeColumn get currentPeriodEnd => dateTime().nullable()();
  BoolColumn get autoRenew => boolean().withDefault(const Constant(false))();
  TextColumn get source => text()();
  DateTimeColumn get lastSyncedAt => dateTime()();

  /// `monthly | annual | lifetime` — `null` for the free tier. Added in
  /// schema v9 alongside RevenueCat's Lifetime plan, so the UI can show
  /// "Lifetime access" (no expiry/renewal) instead of misreading a
  /// lifetime entitlement's null `currentPeriodEnd` as an error.
  TextColumn get activePlan => text().nullable()();

  @override
  Set<Column> get primaryKey => {userId};
}

/// A single flashcard's spaced-repetition schedule state —
/// `features/spaced_repetition`'s persisted ladder position for one
/// `Flashcard.id` (see that entity's doc comment for how the id is
/// derived). Per-user, per `MED100_DATABASE_DESIGN.md` §0a.
///
/// Deliberately a simpler fixed 7/30/90-day Leitner-style ladder rather
/// than `MED100_DATABASE_DESIGN.md`'s documented full SM-2 scheme
/// (ease factor, repetition count, 4-way grading) — this feature's
/// concrete build instructions asked specifically for "review after 7
/// days / 30 days / 90 days," so that's what's implemented; see
/// `RepetitionStage` for the stage/interval table.
///
/// `@DataClassName` avoids Drift's default row-class name colliding with
/// `features/spaced_repetition/domain/entities/flashcard_schedule.dart`'s
/// `FlashcardSchedule` domain entity — Drift would otherwise strip the
/// table name's trailing "s" and generate a class of that exact name.
@DataClassName('FlashcardScheduleRow')
class FlashcardSchedules extends Table {
  /// `'<userId>_<flashcardId>'` — composite identity as a single text
  /// primary key, since Drift's `primaryKey` set doesn't compose cleanly
  /// with the per-user scoping queries this table needs (watch/count by
  /// `userId` alone, look up by `userId` + `flashcardId` together).
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get flashcardId => text()();
  TextColumn get topicId => text()();

  /// `newCard | day7 | day30 | day90 | mastered` — see `RepetitionStage`.
  TextColumn get stage => text()();
  DateTimeColumn get dueDate => dateTime()();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();
  IntColumn get timesReviewed => integer().withDefault(const Constant(0))();
  IntColumn get timesLapsed => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A user-created folder for organizing Notes — deliberately flat (no
/// nesting): this feature's scope is folders as a single-level
/// organizational tool, not a full nested-directory tree.
///
/// `@DataClassName` avoids Drift's default row-class name colliding with
/// `features/notes/domain/entities/note_folder.dart`'s `NoteFolder`
/// domain entity.
@DataClassName('NoteFolderRow')
class NoteFolders extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A user's note — Markdown body (with a `==highlight==` inline
/// extension, see `HighlightSyntax`), optionally filed into a
/// [NoteFolders] folder, optionally bookmarked. `imagesJson` is a
/// JSON-encoded array of `{id, localPath, remoteUrl}` maps — same
/// JSON-array-column convention as `ChallengeProgress`'s day lists and
/// `TeachingSessions`'s concept lists — resolved to `NoteImage` domain
/// values by `NotesLocalDataSource`, never decoded outside the data
/// layer. A note's Markdown references an image by stable id
/// (`![alt](med100-image:<id>)`), never by raw device path, since a raw
/// local path is meaningless once the note syncs to another device.
///
/// `@DataClassName` avoids Drift's default row-class name colliding with
/// `features/notes/domain/entities/note.dart`'s `Note` domain entity.
@DataClassName('NoteRow')
class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get folderId => text().nullable()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get bodyMarkdown => text().withDefault(const Constant(''))();
  TextColumn get imagesJson => text().withDefault(const Constant('[]'))();
  BoolColumn get isBookmarked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Outbox,
    SyncState,
    ChallengeProgress,
    ReminderPreference,
    NotificationLog,
    AiCacheLocal,
    TeachingSessions,
    SubscriptionCache,
    FlashcardSchedules,
    NoteFolders,
    Notes,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Used by widget/unit tests to inject an in-memory executor instead of
  /// opening a real file on disk — see `test/widget/app_smoke_test.dart`.
  AppDatabase.forTesting(super.executor);

  /// Bumped whenever a table shape changes; see
  /// `MED100_DATABASE_DESIGN.md` §0 for the schema-versioning convention
  /// this project follows on both the Firestore and Drift sides.
  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(challengeProgress);
      }
      if (from < 3) {
        // Drops ChallengeProgress's old reminderEnabled/reminderHour/
        // reminderMinute columns (no longer part of the class above) by
        // recreating the table from the current schema, and adds the two
        // new engine-owned tables. Pre-launch, no real user data at risk.
        await m.alterTable(TableMigration(challengeProgress));
        await m.createTable(reminderPreference);
        await m.createTable(notificationLog);
      }
      if (from < 4) {
        await m.createTable(aiCacheLocal);
      }
      if (from < 5) {
        await m.createTable(teachingSessions);
      }
      if (from < 6) {
        await m.createTable(subscriptionCache);
      }
      if (from < 7) {
        await m.createTable(flashcardSchedules);
      }
      if (from < 8) {
        // SyncState has had no real reader/writer until features/notes
        // (see that table's doc comment) — safe to reshape its primary
        // key wholesale rather than needing a data-preserving column
        // add, since no installation has ever written a row to it.
        await m.alterTable(TableMigration(syncState));
        await m.createTable(noteFolders);
        await m.createTable(notes);
      }
      if (from < 9) {
        await m.addColumn(subscriptionCache, subscriptionCache.activePlan);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'med100');
  }
}
