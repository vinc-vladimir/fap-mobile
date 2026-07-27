import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../widgets/glass_card.dart';
import '../widgets/hero_background.dart';
import '../widgets/or_divider.dart';
import '../widgets/social_button.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  static final _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?|)+\.[a-zA-Z]{2,}$",
  );
  static final _passwordRegex = RegExp(
    r'^(?=.*\d)(?=.*[A-Z])(?=.*[a-z])(?=.*[^\w\s:])(\S){8,}$',
  );

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

  void _onSignIn() {
    if (!_formKey.currentState!.validate()) return;
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
              top: screenHeight * 0.35,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bolt, color: vibrantCyan, size: 32),
            const SizedBox(width: AppDimensions.stackSm),
            Text(
              'Fuel Auto Pay',
              style: theme.textTheme.displayLarge?.copyWith(
                color: brandPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.stackSm),
        Text(
          'The fastest way to fuel your vehicle.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
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
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email Address',
        hintText: 'name@velocity.com',
        prefixIcon: Icon(Icons.mail_outline, color: theme.colorScheme.outline),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email address';
        }
        if (!_emailRegex.hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password',
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
              return 'Please enter your password';
            }
            if (!_passwordRegex.hasMatch(value)) {
              return 'Please enter a valid password';
            }
            return null;
          },
        ),
        const SizedBox(height: AppDimensions.stackSm),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Forgot password?',
            style: theme.textTheme.labelMedium?.copyWith(color: brandPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton(ThemeData theme) {
    return ElevatedButton(
      onPressed: _onSignIn,
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
        'SIGN IN',
        style: theme.textTheme.displaySmall?.copyWith(color: brandPrimary),
      ),
    );
  }

  Widget _buildBiometricButton(ThemeData theme) {
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
          Text('BIOMETRIC SIGN IN', style: theme.textTheme.displaySmall),
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Sign up now',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: brandPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.stackMd),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Privacy Policy',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.stackMd),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Terms of Service',
                style: theme.textTheme.labelSmall?.copyWith(
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
