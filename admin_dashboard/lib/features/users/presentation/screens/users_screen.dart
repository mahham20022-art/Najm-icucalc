import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../auth/domain/entities/admin_role.dart';
import '../../domain/entities/account_status.dart';
import '../../domain/entities/managed_user.dart';
import '../../domain/entities/subscription_tier.dart';
import '../viewmodels/users_view_model.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(usersViewModelProvider.notifier).load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usersViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          SizedBox(
            width: 280,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search by email prefix…',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) =>
                    ref.read(usersViewModelProvider.notifier).load(searchEmail: value.trim()),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: switch (state) {
        UsersLoading() => const Center(child: CircularProgressIndicator()),
        UsersError(:final failure) => Center(child: Text(failure.message)),
        UsersLoaded() => _UsersTable(state: state),
      },
    );
  }
}

class _UsersTable extends ConsumerWidget {
  const _UsersTable({required this.state});
  final UsersLoaded state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.users.isEmpty) {
      return const Center(child: Text('No users found.'));
    }
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Role')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Plan')),
                DataColumn(label: Text('Joined')),
                DataColumn(label: Text('')),
              ],
              rows: [for (final user in state.users) _rowFor(context, ref, user)],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: state.hasMore
              ? FilledButton(
                  onPressed: state.loadingMore
                      ? null
                      : () => ref.read(usersViewModelProvider.notifier).loadMore(),
                  child: state.loadingMore
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Load More'),
                )
              : Text('${state.users.length} users', style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }

  DataRow _rowFor(BuildContext context, WidgetRef ref, ManagedUser user) {
    return DataRow(
      cells: [
        DataCell(Text(user.displayName.isEmpty ? '—' : user.displayName)),
        DataCell(Text(user.email)),
        DataCell(_RoleChip(role: user.role)),
        DataCell(_StatusChip(status: user.accountStatus)),
        DataCell(_TierChip(tier: user.tier)),
        DataCell(Text(user.createdAt == null ? '—' : DateFormat.yMMMd().format(user.createdAt!))),
        DataCell(
          PopupMenuButton<String>(
            onSelected: (action) => _handleAction(context, ref, user, action),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_status',
                child: Text(
                  user.accountStatus == AccountStatus.suspended
                      ? 'Reactivate account'
                      : 'Suspend account',
                ),
              ),
              const PopupMenuItem(value: 'change_role', child: Text('Change role')),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    ManagedUser user,
    String action,
  ) async {
    switch (action) {
      case 'toggle_status':
        final newStatus = user.accountStatus == AccountStatus.suspended
            ? AccountStatus.active
            : AccountStatus.suspended;
        final failure = await ref
            .read(usersViewModelProvider.notifier)
            .setAccountStatus(user.uid, newStatus);
        if (failure != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
        }
      case 'change_role':
        final selected = await showDialog<AdminRole>(
          context: context,
          builder: (dialogContext) => SimpleDialog(
            title: const Text('Change Role'),
            children: [
              for (final role in AdminRole.values.where((r) => r != AdminRole.none))
                SimpleDialogOption(
                  onPressed: () => Navigator.of(dialogContext).pop(role),
                  child: Text(role.name),
                ),
            ],
          ),
        );
        if (selected == null || !context.mounted) return;
        final firestoreRole = switch (selected) {
          AdminRole.institutionAdmin => 'institution_admin',
          _ => selected.name,
        };
        final failure = await ref
            .read(usersViewModelProvider.notifier)
            .setRole(user.uid, firestoreRole);
        if (failure != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
        }
    }
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.role});
  final AdminRole role;

  @override
  Widget build(BuildContext context) => Chip(label: Text(role.name));
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final AccountStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = switch (status) {
      AccountStatus.active => colors.primary,
      AccountStatus.suspended => colors.error,
      AccountStatus.pendingDeletion => colors.tertiary,
    };
    return Chip(
      label: Text(status.name),
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: TextStyle(color: color),
    );
  }
}

class _TierChip extends StatelessWidget {
  const _TierChip({required this.tier});
  final ManagedUserTier tier;

  @override
  Widget build(BuildContext context) => Chip(label: Text(tier.name));
}
