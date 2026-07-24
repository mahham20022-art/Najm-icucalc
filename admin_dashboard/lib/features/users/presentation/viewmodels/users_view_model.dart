import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/account_status.dart';
import '../../domain/entities/managed_user.dart';
import '../../users_providers.dart';

sealed class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object?> get props => [];
}

class UsersLoading extends UsersState {
  const UsersLoading();
}

class UsersError extends UsersState {
  const UsersError(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class UsersLoaded extends UsersState {
  const UsersLoaded({
    required this.users,
    required this.cursor,
    required this.hasMore,
    required this.loadingMore,
    required this.searchEmail,
  });

  final List<ManagedUser> users;
  final Object? cursor;
  final bool hasMore;
  final bool loadingMore;
  final String searchEmail;

  UsersLoaded copyWith({
    List<ManagedUser>? users,
    Object? cursor,
    bool? hasMore,
    bool? loadingMore,
    String? searchEmail,
  }) => UsersLoaded(
    users: users ?? this.users,
    cursor: cursor ?? this.cursor,
    hasMore: hasMore ?? this.hasMore,
    loadingMore: loadingMore ?? this.loadingMore,
    searchEmail: searchEmail ?? this.searchEmail,
  );

  @override
  List<Object?> get props => [users, cursor, hasMore, loadingMore, searchEmail];
}

class UsersViewModel extends Notifier<UsersState> {
  @override
  UsersState build() {
    // `load()` is triggered by the screen's `initState`, not here — a
    // `Notifier.build()` firing its own async side effect is the same
    // implicit-side-effect smell this codebase's mobile app avoids
    // elsewhere (e.g. `ExamViewModel`'s explicit `start()`).
    return const UsersLoading();
  }

  Future<void> load({String searchEmail = ''}) async {
    state = const UsersLoading();
    final result = await ref.read(fetchUsersUseCaseProvider)(
      searchEmail: searchEmail.isEmpty ? null : searchEmail,
    );
    state = result.when(
      success: (page) => UsersLoaded(
        users: page.users,
        cursor: page.cursor,
        hasMore: page.hasMore,
        loadingMore: false,
        searchEmail: searchEmail,
      ),
      failure: UsersError.new,
    );
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! UsersLoaded || !current.hasMore || current.loadingMore) return;
    state = current.copyWith(loadingMore: true);
    final result = await ref.read(fetchUsersUseCaseProvider)(
      searchEmail: current.searchEmail.isEmpty ? null : current.searchEmail,
      cursor: current.cursor,
    );
    state = result.when(
      success: (page) => current.copyWith(
        users: [...current.users, ...page.users],
        cursor: page.cursor,
        hasMore: page.hasMore,
        loadingMore: false,
      ),
      // Keep the existing page visible — only the "load more" affordance
      // needs to recover, not the whole screen.
      failure: (_) => current.copyWith(loadingMore: false),
    );
  }

  String get _currentSearchEmail {
    final current = state;
    return current is UsersLoaded ? current.searchEmail : '';
  }

  Future<Failure?> setAccountStatus(String uid, AccountStatus status) async {
    final result = await ref.read(setAccountStatusUseCaseProvider)(uid: uid, status: status);
    return result.when(
      success: (_) {
        unawaited(load(searchEmail: _currentSearchEmail));
        return null;
      },
      failure: (failure) => failure,
    );
  }

  Future<Failure?> setRole(String uid, String role) async {
    final result = await ref.read(setUserRoleUseCaseProvider)(uid: uid, role: role);
    return result.when(
      success: (_) {
        unawaited(load(searchEmail: _currentSearchEmail));
        return null;
      },
      failure: (failure) => failure,
    );
  }
}

final usersViewModelProvider = NotifierProvider<UsersViewModel, UsersState>(UsersViewModel.new);
