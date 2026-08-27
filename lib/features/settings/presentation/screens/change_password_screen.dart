import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/screen_app_bar.dart';
import '../../../account/presentation/providers/account_provider.dart';
import '../../../auth/data/validation_constants.dart';
import '../../../auth/presentation/widgets/glass_card.dart';
import '../providers/settings_providers.dart';

/// Change Password sub-screen pushed from the Settings tab.
///
/// Mirrors the Sign Up password UX: live password-requirements checklist and
/// frontend validation, submitted to `POST /v1/account/change-password`. The
/// user remains signed in after a successful change; the new password is
/// required on the next sign-in.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _hasLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigit = false;
  bool _hasSpecial = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _hasLength = value.length >= 8;
      _hasUppercase = uppercaseRegex.hasMatch(value);
      _hasLowercase = lowercaseRegex.hasMatch(value);
      _hasDigit = digitRegex.hasMatch(value);
      _hasSpecial = specialCharRegex.hasMatch(value);
    });
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    await ref
        .read(changePasswordControllerProvider.notifier)
        .changePassword(
          password: _passwordController.text,
          confirmedPassword: _confirmPasswordController.text,
        );

    if (!mounted) return;
    final state = ref.read(changePasswordControllerProvider);
    if (state.hasError) {
      showAppSnackBar(
        messenger,
        message: state.error?.toString() ?? l10n.errorSomethingWentWrong,
        isError: true,
      );
      return;
    }

    showAppSnackBar(messenger, message: l10n.passwordChangedSuccess);
    // Password changed on the backend → drop cached account so the Settings
    // screen refetches and shows the updated passwordChangedAt.
    ref.invalidate(accountProvider);
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/account');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          ScreenAppBar(title: l10n.changePassword, mode: ScreenAppBarMode.sub),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.marginMain,
                AppDimensions.stackLg,
                AppDimensions.marginMain,
                AppDimensions.stackLg + MediaQuery.of(context).padding.bottom,
              ),
              child: GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.containerPadding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.changePasswordSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.stackLg),
                        _buildPasswordField(theme, l10n),
                        const SizedBox(height: AppDimensions.stackMd),
                        _buildConfirmPasswordField(theme, l10n),
                        const SizedBox(height: AppDimensions.stackLg),
                        _buildSaveButton(theme, l10n),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          onChanged: _onPasswordChanged,
          decoration: InputDecoration(
            labelText: l10n.newPassword,
            prefixIcon: Icon(
              Icons.lock_outline,
              color: theme.colorScheme.outline,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: theme.colorScheme.outline,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.validationPasswordRequired;
            }
            if (!passwordRegex.hasMatch(value)) {
              return l10n.validationPasswordInvalid;
            }
            return null;
          },
        ),
        const SizedBox(height: AppDimensions.stackSm),
        _buildPasswordRequirements(theme, l10n),
      ],
    );
  }

  Widget _buildPasswordRequirements(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.stackSm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _requirementItem(l10n.passwordReqLength, _hasLength, theme),
          const SizedBox(height: 4),
          _requirementItem(l10n.passwordReqUppercase, _hasUppercase, theme),
          const SizedBox(height: 4),
          _requirementItem(l10n.passwordReqLowercase, _hasLowercase, theme),
          const SizedBox(height: 4),
          _requirementItem(l10n.passwordReqDigit, _hasDigit, theme),
          const SizedBox(height: 4),
          _requirementItem(l10n.passwordReqSpecial, _hasSpecial, theme),
        ],
      ),
    );
  }

  Widget _requirementItem(String label, bool isMet, ThemeData theme) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isMet ? brandPrimary : theme.colorScheme.outline,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isMet ? brandPrimary : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField(ThemeData theme, AppLocalizations l10n) {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirm,
      decoration: InputDecoration(
        labelText: l10n.confirmPassword,
        hintText: l10n.repeatPasswordHint,
        prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirm ? Icons.visibility : Icons.visibility_off,
            color: theme.colorScheme.outline,
          ),
          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.validationPasswordRequired;
        }
        if (value != _passwordController.text) {
          return l10n.matchError;
        }
        return null;
      },
    );
  }

  Widget _buildSaveButton(ThemeData theme, AppLocalizations l10n) {
    final isLoading = ref.watch(changePasswordControllerProvider).isLoading;
    return ElevatedButton(
      onPressed: isLoading ? null : _onSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: vibrantCyan,
        foregroundColor: brandPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: brandPrimary,
              ),
            )
          : Text(
              l10n.save,
              style: theme.textTheme.displaySmall?.copyWith(
                color: brandPrimary,
              ),
            ),
    );
  }
}
