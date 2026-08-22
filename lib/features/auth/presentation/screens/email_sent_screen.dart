import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../widgets/glass_card.dart';
import '../widgets/hero_background.dart';

class EmailSentScreen extends StatelessWidget {
  const EmailSentScreen({super.key, this.description});

  final String? description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          const HeroBackground(imagePath: 'assets/images/digital_envelope.png'),
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: screenHeight * 0.35,
              left: AppDimensions.marginMain,
              right: AppDimensions.marginMain,
              bottom: AppDimensions.stackLg + bottomInset,
            ),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.checkYourEmail,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.stackSm),
                  Text(
                    description ?? l10n.emailSentDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.stackLg),
                  ElevatedButton(
                    onPressed: () => context.go('/sign-in'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vibrantCyan,
                      foregroundColor: brandPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLg,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.backToSignIn,
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: brandPrimary,
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
}
