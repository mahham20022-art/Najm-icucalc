import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Thin wrapper around `connectivity_plus`, exposed as a Riverpod stream
/// provider so any ViewModel can watch connectivity without depending on
/// the package directly — the offline-first sync worker (`core/sync`)
/// and the UI's non-intrusive sync-status indicator
/// (`MED100_UI_UX_SPEC.md` §11 Offline Strategy) both consume this.
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();

  // `onConnectivityChanged` only emits on a *future* change — it does not
  // push the connectivity state that already holds at subscription time.
  // Without seeding an initial value here, `isOnlineProvider` below would
  // sit in `AsyncLoading` (and fall back to its optimistic default)
  // indefinitely on any device whose connection doesn't happen to change
  // state after launch, which defeats the point of an offline-aware UI.
  yield !(await connectivity.checkConnectivity()).contains(ConnectivityResult.none);

  yield* connectivity.onConnectivityChanged.map(
    (results) => !results.contains(ConnectivityResult.none),
  );
});

/// Synchronous best-effort snapshot for call sites that can't await a
/// stream (e.g. deciding whether to attempt an immediate outbox drain).
final isOnlineProvider = Provider<bool>((ref) {
  final connectivityState = ref.watch(connectivityProvider);
  return connectivityState.value ?? true;
});
