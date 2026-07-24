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

  /// `quiz_attempt | flashcard_grade | bookmark | settings | achievement_seen`
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();

  /// `create | update`
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
class SyncState extends Table {
  /// e.g. `topics`, `flashcards`, `mcqs`, `progress`.
  TextColumn get entityType => text()();
  DateTimeColumn get lastPulledAt => dateTime().nullable()();
  DateTimeColumn get lastPushedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {entityType};
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

  @override
  Set<Column> get primaryKey => {userId};
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
  int get schemaVersion => 6;

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
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'med100');
  }
}
