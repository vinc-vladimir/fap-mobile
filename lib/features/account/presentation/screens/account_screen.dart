import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/screen_app_bar.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/glass_card.dart';
import '../providers/app_version_provider.dart';

/// Account tab — the entry point for the logged-in user's profile, fleet
/// management menu, sign out and app version.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          ScreenAppBar(title: l10n.accountTitle, mode: ScreenAppBarMode.main),
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppDimensions.marginMain,
                  AppDimensions.stackLg,
                  AppDimensions.marginMain,
                  AppDimensions.stackLg + MediaQuery.of(context).padding.bottom,
                ),
                children: [
                  _ProfileCard(theme: theme),
                  const SizedBox(height: AppDimensions.stackLg),
                  _AddPlateButton(theme: theme, l10n: l10n),
                  const SizedBox(height: AppDimensions.stackLg),
                  _ManagementMenu(theme: theme),
                  const SizedBox(height: AppDimensions.stackLg),
                  _LogoutSection(theme: theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.containerPadding + 8),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? surfaceGlassDark
            : surfaceGlassLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? glassBorderDark
              : glassBorderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: vibrantCyan.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _Avatar(),
          const SizedBox(height: AppDimensions.stackMd),
          Text(
            l10n.profileName,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.profileEmail,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: AppDimensions.stackMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RoleChip(
                icon: Icons.military_tech,
                label: l10n.premiumMember,
                highlight: true,
                theme: theme,
              ),
              const SizedBox(width: AppDimensions.stackSm),
              _RoleChip(
                icon: Icons.admin_panel_settings_outlined,
                label: l10n.fleetAdmin,
                highlight: false,
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: vibrantCyan.withValues(alpha: 0.5),
              width: 4,
            ),
          ),
          child: const CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Icon(Icons.person, size: 48, color: Colors.white70),
          ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: vibrantCyan,
              border: Border.all(
                color: theme.colorScheme.surfaceContainerLowest,
                width: 4,
              ),
            ),
            child: const Icon(Icons.verified, size: 16, color: brandPrimary),
          ),
        ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.icon,
    required this.label,
    required this.highlight,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final bool highlight;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.stackMd,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: highlight
            ? vibrantCyan.withValues(alpha: 0.1)
            : theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(
          color: highlight
              ? vibrantCyan.withValues(alpha: 0.2)
              : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: highlight
                ? vibrantCyan
                : theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: highlight
                  ? vibrantCyan
                  : theme.colorScheme.onSecondaryContainer,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPlateButton extends StatelessWidget {
  const _AddPlateButton({required this.theme, required this.l10n});

  final ThemeData theme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: vibrantCyan,
        foregroundColor: brandPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline, color: brandPrimary),
          const SizedBox(width: AppDimensions.stackSm),
          Text(
            l10n.addNewPlate,
            style: theme.textTheme.displaySmall?.copyWith(color: brandPrimary),
          ),
        ],
      ),
    );
  }
}

class _ManagementMenu extends ConsumerWidget {
  const _ManagementMenu({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.stackSm,
          ),
          child: Text(
            l10n.managementSection.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.outline,
              letterSpacing: 0.1,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.stackSm),
        GlassCard(
          child: Padding(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _MenuRow(
                  icon: Icons.person_outline,
                  label: l10n.personalDetails,
                  theme: theme,
                ),
                const _MenuDivider(theme: null),
                _MenuRow(
                  icon: Icons.corporate_fare_outlined,
                  label: l10n.organization,
                  theme: theme,
                ),
                const _MenuDivider(theme: null),
                _MenuRow(
                  icon: Icons.directions_car_outlined,
                  label: l10n.licencePlates,
                  theme: theme,
                ),
                const _MenuDivider(theme: null),
                _MenuRow(
                  icon: Icons.payment_outlined,
                  label: l10n.paymentMethods,
                  theme: theme,
                ),
                const _MenuDivider(theme: null),
                _MenuRow(
                  icon: Icons.settings_outlined,
                  label: l10n.settings,
                  theme: theme,
                  onTap: () => context.push('/account/settings'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider({required this.theme});

  final ThemeData? theme;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: 0.15),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.theme,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final ThemeData theme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = theme.brightness == Brightness.dark
        ? const Color(0xFF00DCE5)
        : vibrantCyan;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.containerPadding),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF273647)
                    : theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              child: Icon(icon, color: accentColor),
            ),
            const SizedBox(width: AppDimensions.stackMd),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }
}

class _LogoutSection extends ConsumerWidget {
  const _LogoutSection({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final version = ref.watch(appVersionProvider);

    Future<void> signOut() async {
      await ref.read(loginControllerProvider.notifier).logout();
      if (!context.mounted) return;
      context.go('/sign-in');
    }

    return Column(
      children: [
        OutlinedButton(
          onPressed: signOut,
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            side: BorderSide(
              color: theme.colorScheme.error.withValues(alpha: 0.3),
            ),
            backgroundColor: theme.colorScheme.error.withValues(alpha: 0.05),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: theme.colorScheme.error),
              const SizedBox(width: AppDimensions.stackSm),
              Text(
                l10n.signOut,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.stackMd),
        version.when(
          data: (v) => Text(
            l10n.appVersion(v ?? '—'),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline.withValues(alpha: 0.6),
            ),
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
