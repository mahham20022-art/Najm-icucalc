import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/notifications/domain/entities/notification_permission_status.dart';
import '../../../../core/notifications/notification_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/challenge_content.dart';
import '../../domain/entities/challenge_state.dart';
import '../viewmodels/challenge_view_model.dart';
import '../widgets/challenge_done_celebration.dart';
import '../widgets/challenge_progress_circle.dart';

/// The Home tab once a user is signed in — the 100-day journey's main
/// surface: progress ring, Today's Topic, and the Done/Skip actions that
/// enforce Daily Unlock.
class ChallengeHomeScreen extends ConsumerStatefulWidget {
  const ChallengeHomeScreen({super.key});

  @override
  ConsumerState<ChallengeHomeScreen> createState() => _ChallengeHomeScreenState();
}

class _ChallengeHomeScreenState extends ConsumerState<ChallengeHomeScreen> {
  bool _showCelebration = false;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(challengeViewModelProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: l10n.challengeReminderTitle,
            onPressed: () => _openReminderSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: l10n.challengeRestart,
            onPressed: () => _confirmRestart(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          switch (uiState) {
            ChallengeLoading() => const Center(child: CircularProgressIndicator()),
            ChallengeError(:final failure) => Center(child: Text(failure.message)),
            ChallengeLoaded(:final state) => _ChallengeBody(
              state: state,
              busy: _busy,
              onDone: () => _markDone(context),
              onSkip: () => _skip(context),
              onToggleBookmark: () {
                unawaited(HapticFeedback.selectionClick());
                ref.read(challengeViewModelProvider.notifier).toggleBookmark(state.currentDay);
              },
            ),
          },
          if (_showCelebration)
            ChallengeDoneCelebration(
              onCompleted: () {
                if (mounted) setState(() => _showCelebration = false);
              },
            ),
        ],
      ),
    );
  }

  Future<void> _markDone(BuildContext context) async {
    setState(() => _busy = true);
    final failure = await ref.read(challengeViewModelProvider.notifier).markDone();
    if (!context.mounted) return;
    if (failure != null) {
      _showFailure(context, failure);
    } else {
      unawaited(HapticFeedback.mediumImpact());
      setState(() => _showCelebration = true);
    }
    setState(() => _busy = false);
  }

  Future<void> _skip(BuildContext context) async {
    setState(() => _busy = true);
    final failure = await ref.read(challengeViewModelProvider.notifier).skip();
    if (!context.mounted) return;
    if (failure != null) _showFailure(context, failure);
    setState(() => _busy = false);
  }

  void _showFailure(BuildContext context, Failure failure) {
    final l10n = AppLocalizations.of(context);
    if (failure is AlreadyActionedTodayFailure) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.challengeAlreadyDoneTitle),
          content: Text(l10n.challengeAlreadyDoneBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.challengeCancel),
            ),
          ],
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
  }

  Future<void> _confirmRestart(BuildContext context) async {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.challengeRestartConfirmTitle),
        content: Text(l10n.challengeRestartConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.challengeCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: colors.danger),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.challengeRestart),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      if (!context.mounted) return;
      await ref.read(challengeViewModelProvider.notifier).restart();
    }
  }

  Future<void> _openReminderSheet(BuildContext context) async {
    final reminderRepository = ref.read(reminderRepositoryProvider);
    final current = await reminderRepository.getSettings();
    final ignoringBatteryOptimizations = await reminderRepository.isIgnoringBatteryOptimizations();
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _ReminderSheet(
        initialEnabled: current.enabled,
        initialHour: current.hour,
        initialMinute: current.minute,
        initialIgnoringBatteryOptimizations: ignoringBatteryOptimizations,
        onRequestIgnoreBatteryOptimizations: reminderRepository.requestIgnoreBatteryOptimizations,
        onSave: (enabled, hour, minute) async {
          if (enabled) {
            final status = await reminderRepository.requestPermission();
            if (status == NotificationPermissionStatus.denied) {
              if (!sheetContext.mounted) return;
              ScaffoldMessenger.of(sheetContext).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(sheetContext).challengeReminderPermissionDenied,
                  ),
                ),
              );
              return;
            }
          }
          await reminderRepository.setSchedule(enabled: enabled, hour: hour, minute: minute);
        },
      ),
    );
  }
}

class _ChallengeBody extends StatelessWidget {
  const _ChallengeBody({
    required this.state,
    required this.busy,
    required this.onDone,
    required this.onSkip,
    required this.onToggleBookmark,
  });

  final ChallengeState state;
  final bool busy;
  final VoidCallback onDone;
  final VoidCallback onSkip;
  final VoidCallback onToggleBookmark;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final isComplete = state.isComplete;
    final actionedToday = state.isActionedToday();
    final content = ChallengeContent.forDay(state.currentDay);
    final isBookmarked = state.bookmarkedDays.contains(state.currentDay);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.space5),
        children: [
          Center(
            child: ChallengeProgressCircle(
              progress: state.progressFraction,
              currentDay: state.currentDay,
              totalDays: ChallengeContent.totalDays,
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          if (state.currentStreak > 0)
            Center(
              child: Chip(
                avatar: Icon(Icons.local_fire_department, color: colors.warning, size: 18),
                label: Text(
                  '${l10n.challengeCurrentStreak}: ${l10n.challengeStreakDays(state.currentStreak)}',
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.space5),
          if (isComplete)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space5),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events, color: colors.success, size: 32),
                    const SizedBox(width: AppSpacing.space4),
                    Expanded(
                      child: Text(l10n.challengeJourneyComplete, style: textTheme.titleMedium),
                    ),
                  ],
                ),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(l10n.challengeTodaysTopic, style: textTheme.labelMedium),
                        ),
                        IconButton(
                          icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_outline),
                          color: isBookmarked ? colors.accentFill : colors.labelSecondary,
                          tooltip: isBookmarked ? 'Remove bookmark' : 'Add bookmark',
                          onPressed: onToggleBookmark,
                        ),
                      ],
                    ),
                    Text(content.title, style: textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.space3),
                    Text(content.body, style: textTheme.bodyLarge),
                    const SizedBox(height: AppSpacing.space5),
                    if (actionedToday)
                      Text(
                        l10n.challengeAlreadyDoneBody,
                        style: textTheme.bodyMedium?.copyWith(color: colors.labelSecondary),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: busy ? null : onSkip,
                              child: Text(l10n.challengeSkip),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.space3),
                          Expanded(
                            child: FilledButton(
                              onPressed: busy ? null : onDone,
                              child: Text(l10n.challengeMarkDone),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReminderSheet extends StatefulWidget {
  const _ReminderSheet({
    required this.initialEnabled,
    required this.initialHour,
    required this.initialMinute,
    required this.initialIgnoringBatteryOptimizations,
    required this.onRequestIgnoreBatteryOptimizations,
    required this.onSave,
  });

  final bool initialEnabled;
  final int initialHour;
  final int initialMinute;
  final bool initialIgnoringBatteryOptimizations;
  final Future<bool> Function() onRequestIgnoreBatteryOptimizations;
  final void Function(bool enabled, int hour, int minute) onSave;

  @override
  State<_ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<_ReminderSheet> {
  late bool _enabled = widget.initialEnabled;
  late TimeOfDay _time = TimeOfDay(hour: widget.initialHour, minute: widget.initialMinute);
  late bool _ignoringBatteryOptimizations = widget.initialIgnoringBatteryOptimizations;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.space5,
        right: AppSpacing.space5,
        top: AppSpacing.space5,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.space5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.challengeReminderTitle),
            subtitle: Text(l10n.challengeReminderSubtitle),
            value: _enabled,
            onChanged: (value) => setState(() => _enabled = value),
          ),
          if (_enabled)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: Text(_time.format(context)),
              onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: _time);
                if (picked != null) setState(() => _time = picked);
              },
            ),
          if (_enabled && !_ignoringBatteryOptimizations)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.battery_alert_outlined),
              title: Text(l10n.challengeBatteryOptimizationTitle),
              subtitle: Text(l10n.challengeBatteryOptimizationSubtitle),
              trailing: TextButton(
                onPressed: () async {
                  final granted = await widget.onRequestIgnoreBatteryOptimizations();
                  if (mounted) setState(() => _ignoringBatteryOptimizations = granted);
                },
                child: Text(l10n.challengeBatteryOptimizationAction),
              ),
            ),
          const SizedBox(height: AppSpacing.space4),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                widget.onSave(_enabled, _time.hour, _time.minute);
                Navigator.of(context).pop();
              },
              child: Text(l10n.challengeSaveReminder),
            ),
          ),
        ],
      ),
    );
  }
}
