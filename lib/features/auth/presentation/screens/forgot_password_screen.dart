import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/brand_title.dart';
import '../../data/validation_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/hero_background.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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

  void _onResetPassword() {
    if (!_formKey.currentState!.validate()) return;
    context.go('/email-sent');
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.forgotPasswordTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.stackSm),
            Text(
              l10n.forgotPasswordDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppDimensions.stackLg),
            _buildEmailField(theme),
            const SizedBox(height: AppDimensions.stackLg),
            _buildResetButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.emailAddress,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimensions.stackSm),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: l10n.emailHint,
            prefixIcon: Icon(
              Icons.mail_outline,
              color: theme.colorScheme.outline,
            ),
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
        ),
      ],
    );
  }

  Widget _buildResetButton(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return ElevatedButton(
      onPressed: _onResetPassword,
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
        l10n.resetPassword,
        style: theme.textTheme.displaySmall?.copyWith(color: brandPrimary),
      ),
    );
  }
}
