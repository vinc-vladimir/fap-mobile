import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/screen_app_bar.dart';
import '../../../auth/presentation/widgets/glass_card.dart';
import '../../data/models/organization_member_model.dart';
import '../providers/organization_providers.dart';

/// Lists the organization's members.
///
/// Both owners and members can read the list; owner-only actions (remove a
/// member, transfer ownership) are hidden for members. Inviting new members is
/// a later phase.
class OrganizationMembersScreen extends ConsumerWidget {
  const OrganizationMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final members = ref.watch(organizationMembersProvider);

    return Scaffold(
      body: Column(
        children: [
          ScreenAppBar(
            title: l10n.organizationMembers,
            mode: ScreenAppBarMode.sub,
          ),
          Expanded(
            child: members.when(
              data: (list) => list.isEmpty
                  ? const _EmptyState()
                  : _MembersList(members: list),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _LoadError(
                message: error.toString(),
                onRetry: () => ref.invalidate(organizationMembersProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.marginMain),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: theme.colorScheme.error),
            const SizedBox(height: AppDimensions.stackMd),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.stackLg),
            OutlinedButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.marginMain),
        child: Text(
          l10n.organizationMembersEmpty,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _MembersList extends ConsumerWidget {
  const _MembersList({required this.members});

  final List<OrganizationMemberModel> members;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membership = ref.watch(organizationMembershipProvider).value;
    final isOwner = membership?.roleValue.isOwner ?? false;
    final organizationId = membership?.organizationId;

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.marginMain,
        AppDimensions.stackLg,
        AppDimensions.marginMain,
        AppDimensions.stackLg + MediaQuery.of(context).padding.bottom,
      ),
      itemCount: members.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.stackMd),
      itemBuilder: (context, index) {
        final member = members[index];
        return _MemberRow(
          member: member,
          organizationId: organizationId,
          canManage: isOwner && !member.isOwner,
        );
      },
    );
  }
}

enum _MemberAction { transferOwnership, remove }

class _MemberRow extends ConsumerWidget {
  const _MemberRow({
    required this.member,
    required this.organizationId,
    required this.canManage,
  });

  final OrganizationMemberModel member;
  final String? organizationId;
  final bool canManage;

  Future<void> _confirmAndRun(
    BuildContext context,
    WidgetRef ref,
    _MemberAction action,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final id = organizationId;
    final memberId = member.id;
    if (id == null || id.isEmpty || memberId == null || memberId.isEmpty) {
      return;
    }

    final isTransfer = action == _MemberAction.transferOwnership;
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isTransfer
              ? l10n.transferOwnershipConfirmTitle
              : l10n.removeMemberConfirmTitle,
        ),
        content: Text(
          isTransfer
              ? l10n.transferOwnershipConfirmBody(member.displayName)
              : l10n.removeMemberConfirmBody(member.displayName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              isTransfer ? l10n.transferOwnership : l10n.remove,
              style: TextStyle(
                color: isTransfer ? null : theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final controller = ref.read(organizationMemberControllerProvider.notifier);
    if (isTransfer) {
      await controller.transferOwnership(id, memberId);
    } else {
      await controller.remove(id, memberId);
    }

    if (!context.mounted) return;
    final state = ref.read(organizationMemberControllerProvider);
    if (state.hasError) {
      showAppSnackBar(
        messenger,
        message: state.error?.toString() ?? l10n.errorSomethingWentWrong,
        isError: true,
      );
      return;
    }
    showAppSnackBar(
      messenger,
      message: isTransfer ? l10n.ownershipTransferred : l10n.memberRemoved,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isBusy = ref.watch(organizationMemberControllerProvider).isLoading;

    return GlassCard(
      child: Row(
        children: [
          _MemberAvatar(theme: theme),
          const SizedBox(width: AppDimensions.stackMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (member.email != null &&
                    member.email!.isNotEmpty &&
                    member.displayName != member.email) ...[
                  const SizedBox(height: 2),
                  Text(
                    member.email!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: AppDimensions.stackSm),
                _RoleChip(isOwner: member.isOwner),
              ],
            ),
          ),
          if (canManage)
            PopupMenuButton<_MemberAction>(
              enabled: !isBusy,
              icon: Icon(Icons.more_vert, color: theme.colorScheme.outline),
              tooltip: l10n.memberActions,
              onSelected: (action) => _confirmAndRun(context, ref, action),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _MemberAction.transferOwnership,
                  child: Text(l10n.transferOwnership),
                ),
                PopupMenuItem(
                  value: _MemberAction.remove,
                  child: Text(
                    l10n.removeMember,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final accent = theme.brightness == Brightness.dark
        ? vibrantCyan
        : brandPrimary;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? iconTileBackgroundDark
            : iconTileBackgroundLight,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person_outline, color: accent, size: 22),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.isOwner});

  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final color = isOwner
        ? (theme.brightness == Brightness.dark ? vibrantCyan : brandPrimary)
        : theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.stackSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        (isOwner ? l10n.roleOwner : l10n.roleMember).toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
