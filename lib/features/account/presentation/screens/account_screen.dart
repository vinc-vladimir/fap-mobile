import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/screens/sign_in_screen.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _loggingOut = false;

  Future<void> _onSignOut() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);

    await ref.read(loginControllerProvider.notifier).logout();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context, theme, l10n),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.marginMain,
                vertical: AppDimensions.stackLg,
              ),
              child: Column(
                children: [
                  _AccountActionTile(
                    icon: Icons.lock_outline,
                    title: l10n.changePassword,
                    subtitle: l10n.changePasswordSubtitle,
                    theme: theme,
                    isDark: isDark,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppDimensions.stackSm),
                  _AccountActionTile(
                    icon: Icons.logout,
                    title: l10n.signOut,
                    subtitle: l10n.signOutSubtitle,
                    theme: theme,
                    isDark: isDark,
                    isLoading: _loggingOut,
                    onTap: _onSignOut,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 16,
        left: AppDimensions.marginMain + 4,
        right: AppDimensions.marginMain,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Text(
        l10n.accountTitle,
        style: theme.textTheme.headlineSmall?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _AccountActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ThemeData theme;
  final bool isDark;
  final VoidCallback onTap;
  final bool isLoading;

  const _AccountActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.theme,
    required this.isDark,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.containerPadding + 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xB31A2130) : surfaceGlassLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
          border: Border.all(
            color: isDark ? const Color(0x14FFFFFF) : glassBorderLight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF273647)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              child: Icon(
                icon,
                color: isDark ? const Color(0xFF00DCE5) : vibrantCyan,
              ),
            ),
            const SizedBox(width: AppDimensions.stackMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            else
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}
