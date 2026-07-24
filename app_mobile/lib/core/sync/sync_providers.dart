import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap/bootstrap.dart';
import 'data/outbox_local_datasource.dart';
import 'data/sync_state_local_datasource.dart';

/// DI for the shared `core/sync` infrastructure (`Outbox`/`SyncState`) —
/// kept here rather than inside whichever feature happens to use it
/// first, since both tables are explicitly cross-cutting (see their doc
/// comments in `app_database.dart`).
final outboxLocalDataSourceProvider = Provider<OutboxLocalDataSource>((ref) {
  return OutboxLocalDataSource(ref.watch(appDatabaseProvider));
});

final syncStateLocalDataSourceProvider = Provider<SyncStateLocalDataSource>((ref) {
  return SyncStateLocalDataSource(ref.watch(appDatabaseProvider));
});
