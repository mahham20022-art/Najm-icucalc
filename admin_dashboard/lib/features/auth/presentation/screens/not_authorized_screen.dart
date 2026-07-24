import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/admin_auth_view_model.dart';

/// Reached whenever `AdminAuthAuthenticated.user.role.canAccessDashboard`
/// is false — a real Firebase account, just not staff. Deliberately the
/// *same* path for a fresh sign-in with an insufficient role and an
/// already-persisted session that no longer qualifies (e.g. an admin
/// demoted since their last sign-in): the router's redirect guard
/// checks this uniformly for both, rather than the repository trying to
/// special-case "just signed in" — see
/// `AdminAuthRepositoryImpl.signInWithEmail`'s doc comment for the race
/// that special-casing used to cause.
class NotAuthorizedScreen extends ConsumerWidget {
  const NotAuthorizedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text('Not Authorized', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text(
                'This account does not have admin or editor access.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => ref.read(adminAuthViewModelProvider.notifier).signOut(),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
