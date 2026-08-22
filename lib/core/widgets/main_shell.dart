import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// Scaffold that hosts the unified bottom navigation bar and renders the
/// active tab via go_router's [StatefulNavigationShell].
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  /// Indices for the tabs that are not yet implemented (MAP / WALLET /
  /// ACTIVITY). They render in the bar but are disabled.
  static const _disabledTabs = <int>{1, 2, 3};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: _MainBottomNav(
        currentIndex: shell.currentIndex,
        onSelected: (index) {
          if (_disabledTabs.contains(index)) return;
          shell.goBranch(index, initialLocation: index == shell.currentIndex);
        },
      ),
    );
  }
}

class _MainBottomNav extends StatelessWidget {
  const _MainBottomNav({required this.currentIndex, required this.onSelected});

  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFF00DCE5) : vibrantCyan;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : glassBorderLight,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.stackSm,
            vertical: AppDimensions.stackSm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home,
                label: l10n.bottomNavHome,
                isActive: currentIndex == 0,
                enabled: true,
                accentColor: accentColor,
                theme: theme,
                onTap: () => onSelected(0),
              ),
              _NavItem(
                icon: Icons.map_outlined,
                label: 'MAP',
                isActive: false,
                enabled: false,
                accentColor: accentColor,
                theme: theme,
              ),
              _NavItem(
                icon: Icons.account_balance_wallet_outlined,
                label: 'WALLET',
                isActive: false,
                enabled: false,
                accentColor: accentColor,
                theme: theme,
              ),
              _NavItem(
                icon: Icons.history,
                label: l10n.bottomNavActivity,
                isActive: false,
                enabled: false,
                accentColor: accentColor,
                theme: theme,
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: l10n.bottomNavAccount,
                isActive: currentIndex == 4,
                enabled: true,
                accentColor: accentColor,
                theme: theme,
                onTap: () => onSelected(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.enabled,
    required this.accentColor,
    required this.theme,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final bool enabled;
  final Color accentColor;
  final ThemeData theme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = !enabled
        ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.35)
        : (isActive ? accentColor : theme.colorScheme.onSurfaceVariant);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.stackMd,
          vertical: AppDimensions.stackSm,
        ),
        decoration: BoxDecoration(
          color: isActive ? accentColor.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: 10,
                color: color,
                letterSpacing: 0.08,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
