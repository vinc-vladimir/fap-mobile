import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/screen_app_bar.dart';
import '../../../auth/presentation/widgets/glass_card.dart';
import '../../../organization/presentation/providers/organization_providers.dart';
import '../../data/models/registration_plate_model.dart';
import '../providers/registration_plate_providers.dart';

/// Licence Plates area reached from the Account tab.
///
/// The list is resolved server-side (`GET /v1/registration-plates`): fleet
/// plates when the user belongs to an organization, otherwise personal plates.
/// Management is gated by membership — a private user manages their own plates
/// and an `ORG_OWNER` manages the fleet, while an `ORG_MEMBER` sees the fleet
/// read-only.
class RegistrationPlatesScreen extends ConsumerWidget {
  const RegistrationPlatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final plates = ref.watch(registrationPlatesProvider);
    final membership = ref.watch(organizationMembershipProvider).value;
    final hasOrganization = membership?.hasOrganization ?? false;
    final isOwner = membership?.roleValue.isOwner ?? false;
    final canManage = !hasOrganization || isOwner;

    return Scaffold(
      body: Column(
        children: [
          ScreenAppBar(title: l10n.licencePlates, mode: ScreenAppBarMode.sub),
          Expanded(
            child: plates.when(
              data: (list) => _PlatesBody(plates: list, canManage: canManage),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _LoadError(
                message: error.toString(),
                onRetry: () => ref.invalidate(registrationPlatesProvider),
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

class _PlatesBody extends StatelessWidget {
  const _PlatesBody({required this.plates, required this.canManage});

  final List<RegistrationPlateModel> plates;
  final bool canManage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
          Text(
            l10n.licensePlatesSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppDimensions.stackLg),
          if (plates.isEmpty)
            _EmptyState(canManage: canManage)
          else
            for (final plate in plates) ...[
              _PlateCard(plate: plate, canManage: canManage),
              const SizedBox(height: AppDimensions.stackMd),
            ],
          const SizedBox(height: AppDimensions.stackSm),
          const _AnprHint(),
          const SizedBox(height: AppDimensions.stackLg),
          if (canManage) _AddPlateButton() else _MemberReadOnly(l10n: l10n),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.canManage});

  final bool canManage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final accent = _accentColor(theme);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.directions_car_outlined, size: 48, color: accent),
          const SizedBox(height: AppDimensions.stackMd),
          Text(
            l10n.platesEmptyTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.stackSm),
          Text(
            l10n.platesEmptyBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlateCard extends ConsumerWidget {
  const _PlateCard({required this.plate, required this.canManage});

  final RegistrationPlateModel plate;
  final bool canManage;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final id = plate.id;
    if (id == null || id.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deletePlateConfirmTitle),
        content: Text(l10n.deletePlateConfirmBody(plate.number ?? '')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.delete,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(registrationPlateControllerProvider.notifier).delete(id);
    if (!context.mounted) return;
    final state = ref.read(registrationPlateControllerProvider);
    if (state.hasError) {
      showAppSnackBar(
        messenger,
        message: state.error?.toString() ?? l10n.errorSomethingWentWrong,
        isError: true,
      );
      return;
    }
    showAppSnackBar(messenger, message: l10n.plateDeleted);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isBusy = ref.watch(registrationPlateControllerProvider).isLoading;
    final accent = _accentColor(theme);
    final isFleet = plate.isFleet;
    final expiringSoon = plate.isExpiringSoon;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _StatusChip(
                    plate: plate,
                    expiringSoon: expiringSoon,
                    accent: accent,
                  ),
                ),
              ),
              if (canManage) ...[
                IconButton(
                  onPressed: isBusy
                      ? null
                      : () => context.push('/account/plates/${plate.id}/edit'),
                  icon: const Icon(Icons.edit_outlined),
                  iconSize: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                  tooltip: l10n.editPlate,
                ),
                IconButton(
                  onPressed: isBusy ? null : () => _confirmDelete(context, ref),
                  icon: const Icon(Icons.delete_outline),
                  iconSize: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                  tooltip: l10n.deletePlate,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppDimensions.stackSm),
          _PlateBox(plate: plate, isFleet: isFleet, accent: accent),
          const SizedBox(height: AppDimensions.stackSm),
          ..._metadataRows(context, l10n, accent, expiringSoon),
        ],
      ),
    );
  }

  List<Widget> _metadataRows(
    BuildContext context,
    AppLocalizations l10n,
    Color accent,
    bool expiringSoon,
  ) {
    final theme = Theme.of(context);
    final rows = <Widget>[];

    final location = [
      plate.city,
      plate.country,
    ].where((part) => part != null && part.trim().isNotEmpty).join(', ');
    if (location.isNotEmpty) {
      rows.add(
        _MetaRow(
          icon: Icons.location_on_outlined,
          iconColor: accent,
          text: location,
        ),
      );
    }

    final registration = plate.registrationDateValue;
    if (registration != null) {
      rows.add(
        _MetaRow(
          icon: Icons.event_outlined,
          iconColor: theme.colorScheme.outline,
          text: l10n.plateRegisteredOn(
            MaterialLocalizations.of(context).formatMediumDate(registration),
          ),
        ),
      );
    }

    final expires = plate.expiresAtValue;
    if (expires != null) {
      final formatted = MaterialLocalizations.of(
        context,
      ).formatMediumDate(expires);
      rows.add(
        _MetaRow(
          icon: expiringSoon ? Icons.schedule : Icons.calendar_today_outlined,
          iconColor: expiringSoon
              ? theme.colorScheme.error
              : theme.colorScheme.outline,
          text: plate.isFleet
              ? l10n.plateValidUntil(formatted)
              : l10n.plateExpiresOn(formatted),
          textColor: expiringSoon ? theme.colorScheme.error : null,
        ),
      );
    }

    return rows;
  }
}

class _PlateBox extends StatelessWidget {
  const _PlateBox({
    required this.plate,
    required this.isFleet,
    required this.accent,
  });

  final RegistrationPlateModel plate;
  final bool isFleet;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final numberColor = isFleet ? accent : theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.stackMd,
        vertical: AppDimensions.stackSm + 4,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Row(
        children: [
          if ((plate.country ?? '').trim().isNotEmpty) ...[
            _CountryBadge(
              country: plate.country!,
              isFleet: isFleet,
              accent: accent,
            ),
            const SizedBox(width: AppDimensions.stackMd),
          ],
          Expanded(
            child: Text(
              plate.number ?? '—',
              style: theme.textTheme.displayMedium?.copyWith(
                color: numberColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
              ),
            ),
          ),
          Icon(
            isFleet ? Icons.verified_outlined : Icons.nfc_outlined,
            size: 20,
            color: isFleet ? accent : theme.colorScheme.outlineVariant,
          ),
        ],
      ),
    );
  }
}

class _CountryBadge extends StatelessWidget {
  const _CountryBadge({
    required this.country,
    required this.isFleet,
    required this.accent,
  });

  final String country;
  final bool isFleet;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final code = country.trim().length > 3
        ? country.trim().substring(0, 3).toUpperCase()
        : country.trim().toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.stackSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Text(
        code,
        style: theme.textTheme.labelSmall?.copyWith(
          color: isFleet ? accent : theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.plate,
    required this.expiringSoon,
    required this.accent,
  });

  final RegistrationPlateModel plate;
  final bool expiringSoon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final Color background;
    final Color foreground;
    final IconData icon;
    final String label;

    if (plate.isFleet) {
      background = accent.withValues(alpha: 0.18);
      foreground = accent;
      icon = Icons.star;
      label = l10n.corporateFleet;
    } else if (expiringSoon) {
      background = theme.colorScheme.errorContainer;
      foreground = theme.colorScheme.onErrorContainer;
      icon = Icons.warning_amber_rounded;
      label = l10n.plateStatusExpiringSoon;
    } else {
      background = theme.colorScheme.outlineVariant.withValues(alpha: 0.3);
      foreground = theme.colorScheme.onSurface;
      icon = Icons.check_circle_outline;
      label = l10n.plateStatusActive;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.stackSm + 2,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: foreground),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.iconColor,
    required this.text,
    this.textColor,
  });

  final IconData icon;
  final Color iconColor;
  final String text;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 17, color: iconColor),
          const SizedBox(width: AppDimensions.stackSm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColor ?? theme.colorScheme.onSurfaceVariant,
                fontWeight: textColor != null ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnprHint extends StatelessWidget {
  const _AnprHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final accent = _accentColor(theme);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.stackMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.camera_alt_outlined, size: 18, color: accent),
          ),
          const SizedBox(width: AppDimensions.stackMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.anprTitle,
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.anprBody,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPlateButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return ElevatedButton(
      onPressed: () => context.push('/account/plates/add'),
      style: ElevatedButton.styleFrom(
        backgroundColor: vibrantCyan,
        foregroundColor: brandPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add, color: brandPrimary),
          const SizedBox(width: AppDimensions.stackSm),
          Text(
            l10n.addLicensePlate,
            style: theme.textTheme.displaySmall?.copyWith(
              color: brandPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberReadOnly extends StatelessWidget {
  const _MemberReadOnly({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppDimensions.stackSm),
        Expanded(
          child: Text(
            l10n.plateMemberReadOnly,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

Color _accentColor(ThemeData theme) =>
    theme.brightness == Brightness.dark ? vibrantCyan : brandPrimary;
