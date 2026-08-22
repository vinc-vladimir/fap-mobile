import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/screen_app_bar.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/glass_card.dart';
import '../providers/settings_providers.dart';

/// Settings sub-screen pushed from the Account tab.
///
/// Integrated: Language (client-side locale), Change Password, Delete Account.
/// Drawn only (no logic): Dark Mode, Change Email.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> _showChangePasswordDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(
            l10n.changePasswordDialogTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.newPassword),
                ),
                const SizedBox(height: AppDimensions.stackSm),
                TextFormField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.confirmPassword),
                  validator: (value) =>
                      value != passwordController.text ? l10n.matchError : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                }
              },
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(changePasswordControllerProvider.notifier);
    await notifier.changePassword(
      password: passwordController.text,
      confirmedPassword: confirmController.text,
    );

    if (!mounted) return;
    final state = ref.read(changePasswordControllerProvider);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          state.hasError
              ? (state.error?.toString() ?? l10n.errorSomethingWentWrong)
              : l10n.passwordChangedSuccess,
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(
            l10n.deleteAccountDialogTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          content: Text(
            l10n.deleteAccountDialogBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    await ref.read(deleteAccountControllerProvider.notifier).deleteAccount();

    if (!mounted) return;
    final state = ref.read(deleteAccountControllerProvider);
    if (state.hasError) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            state.error?.toString() ?? l10n.errorSomethingWentWrong,
          ),
        ),
      );
      return;
    }

    await ref.read(loginControllerProvider.notifier).logout();
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(l10n.accountDeletedSuccess)));
    context.go('/sign-in');
  }

  void _showLanguageSheet() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.check),
                title: Text(l10n.english),
                onTap: () {
                  ref
                      .read(localeProvider.notifier)
                      .setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(l10n.serbian),
                onTap: () {
                  ref
                      .read(localeProvider.notifier)
                      .setLocale(const Locale('sr'));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: AppDimensions.stackSm),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFF00DCE5) : vibrantCyan;

    return Scaffold(
      body: Column(
        children: [
          ScreenAppBar(title: l10n.settingsTitle, mode: ScreenAppBarMode.sub),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.marginMain,
                AppDimensions.stackLg,
                AppDimensions.marginMain,
                AppDimensions.stackLg + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionLabel(theme, l10n.preferencesSection),
                  const SizedBox(height: AppDimensions.stackSm),
                  GlassCard(
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _SettingsRow(
                            icon: Icons.language,
                            title: l10n.language,
                            trailing: _LanguageTrailing(
                              accentColor: accentColor,
                              onTap: _showLanguageSheet,
                            ),
                          ),
                          const _RowDivider(),
                          _SettingsRow(
                            icon: Icons.dark_mode_outlined,
                            title: l10n.darkMode,
                            trailing: _DummyDarkModeSwitch(isDark: isDark),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.stackLg),
                  _sectionLabel(theme, l10n.securitySection),
                  const SizedBox(height: AppDimensions.stackSm),
                  GlassCard(
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _SettingsRow(
                            icon: Icons.mail_outline,
                            title: l10n.changeEmail,
                            subtitle: l10n.profileEmail,
                          ),
                          const _RowDivider(),
                          _SettingsRow(
                            icon: Icons.key_outlined,
                            title: l10n.changePassword,
                            subtitle: l10n.changePasswordLastUpdated,
                            onTap: _showChangePasswordDialog,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.stackLg),
                  _sectionLabel(theme, l10n.accountManagementSection),
                  const SizedBox(height: AppDimensions.stackSm),
                  GlassCard(
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _SettingsRow(
                            icon: Icons.delete_forever_outlined,
                            title: l10n.deleteAccount,
                            destructive: true,
                            onTap: _confirmDeleteAccount,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.stackSm),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.outline,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

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

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.destructive = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool destructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFF00DCE5) : vibrantCyan;
    final titleColor = destructive
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.containerPadding),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: destructive
                    ? theme.colorScheme.error.withValues(alpha: 0.1)
                    : const Color(0xFF0B101A),
              ),
              child: Icon(
                icon,
                size: 20,
                color: destructive ? theme.colorScheme.error : accentColor,
              ),
            ),
            const SizedBox(width: AppDimensions.stackMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: titleColor,
                      fontWeight: destructive
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else
              Icon(
                Icons.chevron_right,
                color: destructive
                    ? theme.colorScheme.error.withValues(alpha: 0.5)
                    : theme.colorScheme.outline,
              ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTrailing extends StatelessWidget {
  const _LanguageTrailing({required this.accentColor, required this.onTap});

  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.stackMd,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF0B101A),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.english,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: accentColor),
          ],
        ),
      ),
    );
  }
}

class _DummyDarkModeSwitch extends StatelessWidget {
  const _DummyDarkModeSwitch({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Drawn only — not wired to theme yet.
    return IgnorePointer(
      child: Switch(value: isDark, onChanged: (_) {}),
    );
  }
}
