import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy', style: theme.textTheme.titleLarge),
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
              'Information We Collect',
              'We collect information you provide directly to us, such as your name, '
                  'email address, phone number, vehicle registration details, and payment '
                  'information when you create an account or use our services.',
            ),
            const SizedBox(height: AppDimensions.stackLg),
            _buildSection(
              theme,
              'How We Use Your Information',
              'We use the information we collect to provide, maintain, and improve our '
                  'fuel payment services, process transactions, send you transaction '
                  'confirmations and receipts, and communicate with you about your account.',
            ),
            const SizedBox(height: AppDimensions.stackLg),
            _buildSection(
              theme,
              'Information Sharing',
              'We do not share your personal information with third parties except as '
                  'necessary to process payments, comply with legal obligations, or with '
                  'your explicit consent.',
            ),
            const SizedBox(height: AppDimensions.stackLg),
            _buildSection(
              theme,
              'Data Security',
              'We implement industry-standard security measures to protect your personal '
                  'information, including encryption of sensitive data, secure storage '
                  'practices, and regular security audits.',
            ),
            const SizedBox(height: AppDimensions.stackLg),
            _buildSection(
              theme,
              'Your Rights',
              'You have the right to access, update, or delete your personal information '
                  'at any time through your account settings. You may also contact us '
                  'directly to exercise these rights.',
            ),
            const SizedBox(height: AppDimensions.stackLg),
            _buildSection(
              theme,
              'Contact Us',
              'If you have any questions about this Privacy Policy, please contact us '
                  'at support@fuelautopay.com.',
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
