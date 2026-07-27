import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Terms of Service', style: theme.textTheme.titleLarge),
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
              'Acceptance of Terms',
              'By creating an account or using the Fuel Auto Pay service, you agree to be '
                  'bound by these Terms of Service. If you do not agree to these terms, please '
                  'do not use the service.',
            ),
            const SizedBox(height: AppDimensions.stackLg),
            _buildSection(
              theme,
              'Service Description',
              'Fuel Auto Pay provides an automated fuel payment system that uses Automatic '
                  'Number Plate Recognition (ANPR) technology to identify vehicles and process '
                  'payments at participating gas stations without requiring physical payment at '
                  'the pump.',
            ),
            const SizedBox(height: AppDimensions.stackLg),
            _buildSection(
              theme,
              'User Responsibilities',
              'You are responsible for maintaining the accuracy of your account information, '
                  'including vehicle registration details and payment methods. You must notify '
                  'us immediately of any unauthorized use of your account.',
            ),
            const SizedBox(height: AppDimensions.stackLg),
            _buildSection(
              theme,
              'Payment Authorization',
              'By registering a payment method, you authorize Fuel Auto Pay to charge the '
                  'registered payment method for all fuel transactions initiated by vehicles '
                  'registered to your account.',
            ),
            const SizedBox(height: AppDimensions.stackLg),
            _buildSection(
              theme,
              'Limitation of Liability',
              'Fuel Auto Pay shall not be liable for any indirect, incidental, or consequential '
                  'damages arising from the use or inability to use the service, including but '
                  'not limited to incorrect charges or service interruptions.',
            ),
            const SizedBox(height: AppDimensions.stackLg),
            _buildSection(
              theme,
              'Termination',
              'We reserve the right to suspend or terminate your access to the service at any '
                  'time for violation of these terms or any applicable laws.',
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
