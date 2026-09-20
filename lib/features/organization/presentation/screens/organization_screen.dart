import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/screen_app_bar.dart';
import '../../../auth/presentation/widgets/glass_card.dart';
import '../../data/models/organization_membership_model.dart';
import '../../data/models/organization_model.dart';
import '../providers/organization_providers.dart';

/// Organization area reached from the Account tab.
///
/// Shows the user's organization profile when they belong to one, or an empty
/// state offering to create one. Owner-only actions (edit, deactivate) are
/// hidden for members.
class OrganizationScreen extends ConsumerWidget {
  const OrganizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final organization = ref.watch(organizationProvider);

    return Scaffold(
      body: Column(
        children: [
          ScreenAppBar(title: l10n.organization, mode: ScreenAppBarMode.sub),
          Expanded(
            child: organization.when(
              data: (organization) => organization == null
                  ? const _EmptyState()
                  : _OrganizationDetails(organization: organization),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _LoadError(
                message: error.toString(),
                onRetry: () => ref.invalidate(organizationMembershipProvider),
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
    final accent = _accentColor(theme);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.marginMain,
        AppDimensions.stackLg,
        AppDimensions.marginMain,
        AppDimensions.stackLg + MediaQuery.of(context).padding.bottom,
      ),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.corporate_fare_outlined, size: 48, color: accent),
            const SizedBox(height: AppDimensions.stackMd),
            Text(
              l10n.organizationEmptyTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.stackSm),
            Text(
              l10n.organizationEmptyBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppDimensions.stackLg),
            ElevatedButton(
              onPressed: () => context.push('/account/organization/create'),
              style: ElevatedButton.styleFrom(
                backgroundColor: vibrantCyan,
                foregroundColor: brandPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                ),
                elevation: 0,
              ),
              child: Text(
                l10n.createOrganization,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: brandPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrganizationDetails extends ConsumerWidget {
  const _OrganizationDetails({required this.organization});

  final OrganizationModel organization;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final membership = ref.watch(organizationMembershipProvider).value;
    final isOwner = membership?.roleValue.isOwner ?? false;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.marginMain,
        AppDimensions.stackLg,
        AppDimensions.marginMain,
        AppDimensions.stackLg + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileCard(
            organization: organization,
            membership: membership,
            isOwner: isOwner,
          ),
          const SizedBox(height: AppDimensions.stackLg),
          if (isOwner) ...[
            _EditButton(
              onPressed: () => context.push('/account/organization/edit'),
            ),
            const SizedBox(height: AppDimensions.stackMd),
            _DeactivateButton(organization: organization),
          ] else
            Text(
              l10n.organizationMemberReadOnly,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.organization,
    required this.membership,
    required this.isOwner,
  });

  final OrganizationModel organization;
  final OrganizationMembershipModel? membership;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final active = organization.active ?? true;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  organization.name?.trim().isNotEmpty == true
                      ? organization.name!
                      : l10n.organization,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              _StatusChip(active: active),
            ],
          ),
          const SizedBox(height: AppDimensions.stackSm),
          _RoleChip(isOwner: isOwner),
          const SizedBox(height: AppDimensions.stackLg),
          _DetailRow(label: l10n.crn, value: organization.crn),
          _DetailRow(label: l10n.vat, value: organization.vat),
          _DetailRow(label: l10n.phoneNumber, value: organization.phone),
          _DetailRow(label: l10n.companyEmail, value: organization.email),
          _DetailRow(label: l10n.address, value: organization.address),
          _DetailRow(label: l10n.city, value: organization.city),
          _DetailRow(label: l10n.zipCode, value: organization.zip),
          _DetailRow(label: l10n.country, value: organization.country),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = (value == null || value!.trim().isEmpty) ? '—' : value!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.stackSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.stackMd),
          Expanded(
            flex: 2,
            child: Text(
              display,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final color = active
        ? _accentColor(theme)
        : theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.stackMd,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        (active ? l10n.activeStatus : l10n.inactiveStatus).toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(color: color),
      ),
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
    final color = _accentColor(theme);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.stackMd,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOwner
                    ? Icons.admin_panel_settings_outlined
                    : Icons.person_outline,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                (isOwner ? l10n.roleOwner : l10n.roleMember).toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: vibrantCyan,
        foregroundColor: brandPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        elevation: 0,
      ),
      child: Text(
        l10n.editOrganization,
        style: theme.textTheme.displaySmall?.copyWith(color: brandPrimary),
      ),
    );
  }
}

class _DeactivateButton extends ConsumerWidget {
  const _DeactivateButton({required this.organization});

  final OrganizationModel organization;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isLoading = ref
        .watch(organizationLifecycleControllerProvider)
        .isLoading;

    Future<void> confirm() async {
      final id = organization.id;
      if (id == null || id.isEmpty) return;

      final messenger = ScaffoldMessenger.of(context);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.deactivateOrganizationConfirmTitle),
          content: Text(l10n.deactivateOrganizationConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                l10n.deactivate,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      await ref
          .read(organizationLifecycleControllerProvider.notifier)
          .deactivate(id);
      if (!context.mounted) return;
      final state = ref.read(organizationLifecycleControllerProvider);
      if (state.hasError) {
        showAppSnackBar(
          messenger,
          message: state.error?.toString() ?? l10n.errorSomethingWentWrong,
          isError: true,
        );
        return;
      }
      showAppSnackBar(messenger, message: l10n.organizationDeactivated);
    }

    return OutlinedButton(
      onPressed: isLoading ? null : confirm,
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.error,
        side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.3)),
        backgroundColor: theme.colorScheme.error.withValues(alpha: 0.05),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: theme.colorScheme.error,
              ),
            )
          : Text(
              l10n.deactivateOrganization,
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
    );
  }
}

Color _accentColor(ThemeData theme) =>
    theme.brightness == Brightness.dark ? vibrantCyan : brandPrimary;
