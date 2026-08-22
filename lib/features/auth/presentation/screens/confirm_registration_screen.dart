import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../providers/auth_providers.dart';
import '../widgets/glass_card.dart';
import '../widgets/hero_background.dart';

/// Verifies the user's email using the one-time token from the confirmation
/// deep link (`fap://registration-confirm?token=...`) and shows the result.
class ConfirmRegistrationScreen extends ConsumerWidget {
  const ConfirmRegistrationScreen({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('[ConfirmRegistrationScreen] build START token=$token');
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    final confirmation = ref.watch(confirmRegistrationProvider(token: token));

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppDimensions.stackSm),
                  confirmation.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.stackLg,
                      ),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ),
                    error: (error, _) =>
                        _buildErrorContent(context, ref, theme, l10n),
                    data: (_) => _buildSuccessContent(context, theme, l10n),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dismisses the confirm screen (presented on top of the current route via the
  /// navigator for deep links) and lands on the Sign In screen.
  void _goToSignIn(BuildContext context) {
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
    router.go('/sign-in');
  }

  Widget _buildSuccessContent(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.check_circle, size: 56, color: brandPrimary),
        const SizedBox(height: AppDimensions.stackMd),
        Text(
          l10n.registrationConfirmedTitle,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.stackSm),
        Text(
          l10n.registrationConfirmedDescription,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.stackLg),
        ElevatedButton(
          onPressed: () => _goToSignIn(context),
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

  Widget _buildErrorContent(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.error_outline, size: 56, color: theme.colorScheme.error),
        const SizedBox(height: AppDimensions.stackMd),
        Text(
          l10n.registrationConfirmationFailedTitle,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.stackSm),
        Text(
          l10n.registrationConfirmationFailedDescription,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.stackLg),
        OutlinedButton(
          onPressed: () =>
              ref.invalidate(confirmRegistrationProvider(token: token)),
          style: OutlinedButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceContainerLow,
            foregroundColor: theme.colorScheme.onSurface,
            side: BorderSide(color: theme.colorScheme.outlineVariant),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
          ),
          child: Text(l10n.retry, style: theme.textTheme.displaySmall),
        ),
        const SizedBox(height: AppDimensions.stackMd),
        ElevatedButton(
          onPressed: () => _goToSignIn(context),
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
            l10n.backToSignIn,
            style: theme.textTheme.displaySmall?.copyWith(color: brandPrimary),
          ),
        ),
      ],
    );
  }
}
