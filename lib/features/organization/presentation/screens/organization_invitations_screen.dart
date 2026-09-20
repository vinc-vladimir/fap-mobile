import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/screen_app_bar.dart';
import '../../../auth/presentation/widgets/glass_card.dart';
import '../../data/models/organization_invitation_model.dart';
import '../../data/models/organization_invitation_status.dart';
import '../providers/organization_providers.dart';

/// Lists the organization's invitations (owner-only on the backend) and lets
/// the owner revoke pending ones.
class OrganizationInvitationsScreen extends ConsumerWidget {
  const OrganizationInvitationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final invitations = ref.watch(organizationInvitationsProvider);

    return Scaffold(
      body: Column(
        children: [
          ScreenAppBar(title: l10n.invitations, mode: ScreenAppBarMode.sub),
          Expanded(
            child: invitations.when(
              data: (list) => list.isEmpty
                  ? const _EmptyState()
                  : _InvitationsList(invitations: list),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _LoadError(
                message: error.toString(),
                onRetry: () => ref.invalidate(organizationInvitationsProvider),
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
          l10n.invitationsEmpty,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _InvitationsList extends ConsumerWidget {
  const _InvitationsList({required this.invitations});

  final List<OrganizationInvitationModel> invitations;

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
      itemCount: invitations.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.stackMd),
      itemBuilder: (context, index) => _InvitationRow(
        invitation: invitations[index],
        organizationId: organizationId,
        canRevoke: isOwner,
      ),
    );
  }
}

class _InvitationRow extends ConsumerWidget {
  const _InvitationRow({
    required this.invitation,
    required this.organizationId,
    required this.canRevoke,
  });

  final OrganizationInvitationModel invitation;
  final String? organizationId;
  final bool canRevoke;

  Future<void> _revoke(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final id = organizationId;
    final invitationId = invitation.id;
    if (id == null ||
        id.isEmpty ||
        invitationId == null ||
        invitationId.isEmpty) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.revokeInvitationConfirmTitle),
        content: Text(l10n.revokeInvitationConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.revokeInvitation,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref
        .read(organizationInvitationControllerProvider.notifier)
        .revoke(id, invitationId);

    if (!context.mounted) return;
    final state = ref.read(organizationInvitationControllerProvider);
    if (state.hasError) {
      showAppSnackBar(
        messenger,
        message: state.error?.toString() ?? l10n.errorSomethingWentWrong,
        isError: true,
      );
      return;
    }
    showAppSnackBar(messenger, message: l10n.invitationRevoked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isBusy = ref
        .watch(organizationInvitationControllerProvider)
        .isLoading;
    final expiresAt = invitation.expiresAt;

    return GlassCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invitation.email ?? '—',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (expiresAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    l10n.invitationExpiresOn(
                      MaterialLocalizations.of(
                        context,
                      ).formatMediumDate(expiresAt),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: AppDimensions.stackSm),
                _StatusChip(status: invitation.statusValue),
              ],
            ),
          ),
          if (canRevoke && invitation.isPending)
            TextButton(
              onPressed: isBusy ? null : () => _revoke(context, ref),
              child: Text(
                l10n.revokeInvitation,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final OrganizationInvitationStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final String label = switch (status) {
      OrganizationInvitationStatus.pending => l10n.invitationStatusPending,
      OrganizationInvitationStatus.accepted => l10n.invitationStatusAccepted,
      OrganizationInvitationStatus.revoked => l10n.invitationStatusRevoked,
      OrganizationInvitationStatus.expired => l10n.invitationStatusExpired,
      OrganizationInvitationStatus.unknown => l10n.invitationStatusUnknown,
    };

    final accent = theme.brightness == Brightness.dark
        ? vibrantCyan
        : brandPrimary;
    final color = status.isPending
        ? accent
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
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
