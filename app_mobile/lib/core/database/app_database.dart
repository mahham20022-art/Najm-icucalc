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
class ChallengeProgress extends Table {
  TextColumn get userId => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get lastActionDate => dateTime().nullable()();
  TextColumn get completedDaysJson => text().withDefault(const Constant('[]'))();
  TextColumn get skippedDaysJson => text().withDefault(const Constant('[]'))();
  TextColumn get bookmarkedDaysJson => text().withDefault(const Constant('[]'))();

  /// Daily reminder preference — stored alongside progress rather than a
  /// separate prefs mechanism, since it's per-user Challenge Mode state
  /// like everything else in this row.
  BoolColumn get reminderEnabled => boolean().withDefault(const Constant(false))();
  IntColumn get reminderHour => integer().withDefault(const Constant(19))();
  IntColumn get reminderMinute => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {userId};
}

@DriftDatabase(tables: [Outbox, SyncState, ChallengeProgress])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Used by widget/unit tests to inject an in-memory executor instead of
  /// opening a real file on disk — see `test/widget/app_smoke_test.dart`.
  AppDatabase.forTesting(super.executor);

  /// Bumped whenever a table shape changes; see
  /// `MED100_DATABASE_DESIGN.md` §0 for the schema-versioning convention
  /// this project follows on both the Firestore and Drift sides.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(challengeProgress);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'med100');
  }
}
