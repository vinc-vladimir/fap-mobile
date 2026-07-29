import 'package:flutter/material.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_dimensions.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyPolicyTitle, style: theme.textTheme.titleLarge),
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
              l10n.privacyInfoCollect,
              l10n.privacyInfoCollectBody,
            ),
            const SizedBox(height: AppDimensions.stackLg),
            _buildSection(
              theme,
              l10n.privacyHowWeUse,
              l10n.privacyHowWeUseBody,
            ),
            const SizedBox(height: AppDimensions.stackLg),
            _buildSection(
              theme,
              l10n.privacyInfoSharing,
              l10n.privacyInfoSharingBody,
            ),
            const SizedBox(height: AppDimensions.stackLg),
            _buildSection(
              theme,
              l10n.privacyDataSecurity,
              l10n.privacyDataSecurityBody,
            ),
            const SizedBox(height: AppDimensions.stackLg),
            _buildSection(
              theme,
              l10n.privacyYourRights,
              l10n.privacyYourRightsBody,
            ),
            const SizedBox(height: AppDimensions.stackLg),
            _buildSection(
              theme,
              l10n.privacyContactUs,
              l10n.privacyContactUsBody,
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
