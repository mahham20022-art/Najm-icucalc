import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../auth_providers.dart';
import '../viewmodels/auth_view_model.dart';

/// Minimal, auth-relevant Profile screen: the navigation buttons already
/// scaffolded for Settings/Subscription/Teaching Mode, plus what this
/// task actually asked for — a Biometric Login toggle and Logout with a
/// confirmation dialog. The rest of Profile's content is still out of
/// scope ("Nothing else" / not part of this feature).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final biometricEnabled = ref.watch(_biometricEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(l10n.openSettings),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.goNamed(AppRoute.settings),
          ),
          ListTile(
            title: Text(l10n.openSubscription),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.goNamed(AppRoute.subscription),
          ),
          ListTile(
            title: Text(l10n.openTeachingMode),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.goNamed(AppRoute.teachingMode),
          ),
          ListTile(
            title: const Text('Notes'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.goNamed(AppRoute.notes),
          ),
          const Divider(height: 32),
          biometricEnabled.when(
            data: (enabled) => SwitchListTile(
              title: const Text('Biometric Login'),
              subtitle: const Text('Use Face ID / Touch ID to unlock a remembered session'),
              value: enabled,
              onChanged: (value) async {
                await ref.read(sessionRepositoryProvider).setBiometricEnabled(value);
                ref.invalidate(_biometricEnabledProvider);
              },
            ),
            loading: () => const ListTile(
              title: Text('Biometric Login'),
              trailing: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, _) => const ListTile(title: Text('Biometric Login unavailable')),
          ),
          const Divider(height: 32),
          ListTile(
            title: Text('Log Out', style: TextStyle(color: colors.danger)),
            leading: Icon(Icons.logout, color: colors.danger),
            onTap: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final colors = AppColors.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: colors.danger),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authViewModelProvider.notifier).signOut();
      if (context.mounted) context.goNamed(AppRoute.login);
    }
  }
}

final _biometricEnabledProvider = FutureProvider.autoDispose<bool>((ref) {
  return ref.watch(sessionRepositoryProvider).isBiometricEnabled();
});
