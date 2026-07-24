import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/challenge_content.dart';
import '../viewmodels/challenge_view_model.dart';

/// Replaces the Bookmarks tab's placeholder — lists every day the user
/// has bookmarked from Today's Topic, most recently unlocked day first.
class ChallengeBookmarksScreen extends ConsumerWidget {
  const ChallengeBookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uiState = ref.watch(challengeViewModelProvider);
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navBookmarks)),
      body: switch (uiState) {
        ChallengeLoading() => const Center(child: CircularProgressIndicator()),
        ChallengeError(:final failure) => Center(child: Text(failure.message)),
        ChallengeLoaded(:final state) => () {
          final bookmarkedDays = state.bookmarkedDays.toList()..sort((a, b) => b.compareTo(a));
          if (bookmarkedDays.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bookmark_outline, size: 40, color: colors.labelTertiary),
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      l10n.challengeBookmarksEmpty,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.space4),
            itemCount: bookmarkedDays.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final day = bookmarkedDays[index];
              final content = ChallengeContent.forDay(day);
              return ListTile(
                leading: Icon(Icons.bookmark, color: colors.accentFill),
                title: Text(content.title),
                subtitle: Text(content.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                  icon: const Icon(Icons.bookmark_remove_outlined),
                  tooltip: 'Remove bookmark',
                  onPressed: () {
                    unawaited(HapticFeedback.selectionClick());
                    ref.read(challengeViewModelProvider.notifier).toggleBookmark(day);
                  },
                ),
              );
            },
          );
        }(),
      },
    );
  }
}
