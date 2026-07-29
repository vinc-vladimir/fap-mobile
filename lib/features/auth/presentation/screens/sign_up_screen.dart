import 'package:flutter/material.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/validation_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/hero_background.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
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
    _emailController.dispose();
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

  void _onCreateAccount() {
    if (!_formKey.currentState!.validate()) return;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          const HeroBackground(),
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: screenHeight * 0.20,
              left: AppDimensions.marginMain,
              right: AppDimensions.marginMain,
              bottom:
                  AppDimensions.stackLg + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBrandHeader(theme),
                const SizedBox(height: AppDimensions.stackLg),
                _buildFormCard(theme, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandHeader(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: AppDimensions.stackSm),
            Text(
              l10n.fuelAutoPay,
              style: theme.textTheme.displayLarge?.copyWith(
                color: vibrantCyan,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.stackSm),
        Text(
          l10n.tagline,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(ThemeData theme, AppLocalizations l10n) {
    return GlassCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppDimensions.stackSm),
            Text(
              l10n.createAccountTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: brandPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.stackSm),
            Text(
              l10n.createAccountSubtitle,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.stackLg),
            _buildEmailField(theme, l10n),
            const SizedBox(height: AppDimensions.stackMd),
            _buildPasswordField(theme, l10n),
            const SizedBox(height: AppDimensions.stackMd),
            _buildConfirmPasswordField(theme, l10n),
            const SizedBox(height: AppDimensions.stackMd),
            _buildCreateAccountButton(theme, l10n),
            const SizedBox(height: AppDimensions.stackLg),
            _buildSignInRow(theme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField(ThemeData theme, AppLocalizations l10n) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: l10n.emailAddress,
        hintText: l10n.emailHint,
        prefixIcon: Icon(Icons.mail_outline, color: theme.colorScheme.outline),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.validationEmailRequired;
        }
        if (!emailRegex.hasMatch(value)) {
          return l10n.validationEmailInvalid;
        }
        return null;
      },
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
            labelText: l10n.createPassword,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.confirmPassword,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimensions.stackSm),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirm,
          decoration: InputDecoration(
            hintText: l10n.repeatPasswordHint,
            prefixIcon: Icon(
              Icons.lock_outline,
              color: theme.colorScheme.outline,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                color: theme.colorScheme.outline,
              ),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
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
        ),
      ],
    );
  }

  Widget _buildCreateAccountButton(ThemeData theme, AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: _onCreateAccount,
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
        l10n.createAccount,
        style: theme.textTheme.displaySmall?.copyWith(color: brandPrimary),
      ),
    );
  }

  Widget _buildSignInRow(ThemeData theme, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.alreadyHaveAccount,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SignInScreen()),
          ),
          child: Text(
            l10n.signInLink,
            style: linkMedium.copyWith(color: vibrantCyan),
          ),
        ),
      ],
    );
  }
}
