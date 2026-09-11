import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/validation_constants.dart';
import '../providers/auth_providers.dart';
import '../widgets/glass_card.dart';
import '../widgets/hero_background.dart';

/// Sets a new password using the one-time token from the reset email link
/// (`https://dev.fap.rs/set-new-password?token=...` or
/// `fap://set-new-password?token=...`).
///
/// Public, token-driven screen — like [ConfirmRegistrationScreen] it renders
/// whether or not a session exists. On success the backend returns no session,
/// so the user is sent back to Sign In.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.token});

  final String token;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
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
  bool _success = false;

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

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(resetPasswordControllerProvider.notifier)
        .reset(
          token: widget.token,
          password: _passwordController.text,
          confirmedPassword: _confirmPasswordController.text,
        );

    if (!mounted) return;
    if (!ref.read(resetPasswordControllerProvider).hasError) {
      setState(() => _success = true);
    }
  }

  /// Dismisses the screen (presented on top of the current route for deep links)
  /// and lands on Sign In.
  void _goToSignIn() {
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
    router.go('/sign-in');
  }

  void _goToForgotPassword() {
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
    router.go('/forgot-password');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    final resetState = ref.watch(resetPasswordControllerProvider);
    final isInvalid = widget.token.isEmpty || resetState.hasError;

    return Scaffold(
      body: Stack(
        children: [
          const HeroBackground(),
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: screenHeight * 0.30,
              left: AppDimensions.marginMain,
              right: AppDimensions.marginMain,
              bottom: AppDimensions.stackLg + bottomInset,
            ),
            child: GlassCard(
              child: _success
                  ? _buildSuccessContent(theme)
                  : isInvalid
                  ? _buildInvalidContent(theme)
                  : _buildForm(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = ref.watch(resetPasswordControllerProvider).isLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.resetPasswordTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.stackSm),
          Text(
            l10n.resetPasswordSubtitle,
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
          _buildSubmitButton(theme, l10n, isLoading),
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

  Widget _buildSubmitButton(
    ThemeData theme,
    AppLocalizations l10n,
    bool isLoading,
  ) {
    return ElevatedButton(
      onPressed: isLoading ? null : _onSubmit,
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
              l10n.resetPassword,
              style: theme.textTheme.displaySmall?.copyWith(
                color: brandPrimary,
              ),
            ),
    );
  }

  Widget _buildSuccessContent(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.check_circle, size: 56, color: brandPrimary),
        const SizedBox(height: AppDimensions.stackMd),
        Text(
          l10n.resetPasswordSuccessTitle,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.stackSm),
        Text(
          l10n.passwordChangedSuccess,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.stackLg),
        ElevatedButton(
          onPressed: _goToSignIn,
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
            l10n.goToSignIn,
            style: theme.textTheme.displaySmall?.copyWith(color: brandPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildInvalidContent(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.error_outline, size: 56, color: theme.colorScheme.error),
        const SizedBox(height: AppDimensions.stackMd),
        Text(
          l10n.resetPasswordInvalidTitle,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.stackSm),
        Text(
          l10n.resetPasswordInvalidDescription,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.stackLg),
        ElevatedButton(
          onPressed: _goToForgotPassword,
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
            l10n.requestNewLink,
            style: theme.textTheme.displaySmall?.copyWith(color: brandPrimary),
          ),
        ),
      ],
    );
  }
}
