import 'package:flutter/material.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_dimensions.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.termsTitle, style: theme.textTheme.titleLarge),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppDimensions.marginMain).copyWith(
          bottom: MediaQuery.of(context).padding.bottom + AppDimensions.stackLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              theme,
              l10n.termsAcceptance,
              l10n.termsAcceptanceBody,
            ),
            const SizedBox(height: AppDimensions.stackLg),
            _buildSection(
              theme,
              l10n.termsServiceDesc,
              l10n.termsServiceDescBody,
            ),
            const SizedBox(height: AppDimensions.stackLg),
            _buildSection(theme, l10n.termsUserResp, l10n.termsUserRespBody),
            const SizedBox(height: AppDimensions.stackLg),
            _buildSection(
              theme,
              l10n.termsPaymentAuth,
              l10n.termsPaymentAuthBody,
            ),
            const SizedBox(height: AppDimensions.stackLg),
            _buildSection(
              theme,
              l10n.termsLimitation,
              l10n.termsLimitationBody,
            ),
            const SizedBox(height: AppDimensions.stackLg),
            _buildSection(
              theme,
              l10n.termsTermination,
              l10n.termsTerminationBody,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppDimensions.stackSm),
        Text(
          body,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
