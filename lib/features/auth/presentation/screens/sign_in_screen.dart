import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_title.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/glass_card.dart';
import '../widgets/hero_background.dart';
import '../widgets/or_divider.dart';
import '../widgets/social_button.dart';
import '../../data/validation_constants.dart';
import '../providers/auth_providers.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    await ref
        .read(loginControllerProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    final state = ref.read(loginControllerProvider);
    if (state.hasError) {
      final error = state.error;
      messenger.showSnackBar(
        SnackBar(
          content: Text(error?.toString() ?? l10n.errorSomethingWentWrong),
        ),
      );
      return;
    }

    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          const HeroBackground(),
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: screenHeight * 0.32,
              left: AppDimensions.marginMain,
              right: AppDimensions.marginMain,
              bottom: AppDimensions.stackLg + bottomInset,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBrandHeader(theme),
                const SizedBox(height: AppDimensions.stackLg),
                _buildFormCard(theme),
                const SizedBox(height: 4),
                _buildFooter(theme),
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
            BrandTitle(text: l10n.fuelAutoPay),
          ],
        ),
        const SizedBox(height: AppDimensions.stackSm),
        BrandTitle(
          text: l10n.tagline,
          style: theme.textTheme.bodyMedium,
          fillColor: vibrantCyan,
          strokeWidth: 1,
        ),
      ],
    );
  }

  Widget _buildFormCard(ThemeData theme) {
    return GlassCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildEmailField(theme),
            const SizedBox(height: AppDimensions.stackMd),
            _buildPasswordField(theme),
            const SizedBox(height: AppDimensions.stackMd),
            _buildSignInButton(theme),
            const SizedBox(height: AppDimensions.stackSm),
            _buildBiometricButton(theme),
            const SizedBox(height: AppDimensions.stackMd),
            const OrDivider(),
            const SizedBox(height: AppDimensions.stackMd),
            _buildSocialRow(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
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

  Widget _buildPasswordField(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: l10n.password,
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
        TextButton(
          onPressed: () => context.push('/forgot-password'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            l10n.forgotPassword,
            style: linkMedium.copyWith(color: vibrantCyan),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = ref.watch(loginControllerProvider).isLoading;
    return ElevatedButton(
      onPressed: isLoading ? null : _onSignIn,
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
              l10n.signIn,
              style: theme.textTheme.displaySmall?.copyWith(
                color: brandPrimary,
              ),
            ),
    );
  }

  Widget _buildBiometricButton(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        backgroundColor: theme.colorScheme.surfaceContainerLow,
        foregroundColor: theme.colorScheme.onSurface,
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fingerprint, color: theme.colorScheme.onSurface),
          const SizedBox(width: AppDimensions.stackSm),
          Text(l10n.biometricSignIn, style: theme.textTheme.displaySmall),
        ],
      ),
    );
  }

  Widget _buildSocialRow(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: SocialButton(
            provider: SocialProvider.google,
            onPressed: () {},
          ),
        ),
        const SizedBox(width: AppDimensions.gutter),
        Expanded(
          child: SocialButton(
            provider: SocialProvider.github,
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.noAccount,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/sign-up'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.signUpNow,
                style: linkMedium.copyWith(color: vibrantCyan),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.stackMd),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => context.push('/privacy-policy'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.privacyPolicy,
                style: linkSmall.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.stackMd),
            TextButton(
              onPressed: () => context.push('/terms-of-service'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.termsOfService,
                style: linkSmall.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
