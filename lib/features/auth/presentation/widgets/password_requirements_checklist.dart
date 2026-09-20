import 'package:flutter/material.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/validation_constants.dart';

/// Live checklist of the password policy requirements.
///
/// Computes each requirement from [password] and renders a check/empty icon per
/// rule. Shared by the sign-up and invited-registration forms so the policy UI
/// lives in one place.
class PasswordRequirementsChecklist extends StatelessWidget {
  const PasswordRequirementsChecklist({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
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
          _item(l10n.passwordReqLength, password.length >= 8, theme),
          const SizedBox(height: 4),
          _item(
            l10n.passwordReqUppercase,
            uppercaseRegex.hasMatch(password),
            theme,
          ),
          const SizedBox(height: 4),
          _item(
            l10n.passwordReqLowercase,
            lowercaseRegex.hasMatch(password),
            theme,
          ),
          const SizedBox(height: 4),
          _item(l10n.passwordReqDigit, digitRegex.hasMatch(password), theme),
          const SizedBox(height: 4),
          _item(
            l10n.passwordReqSpecial,
            specialCharRegex.hasMatch(password),
            theme,
          ),
        ],
      ),
    );
  }

  Widget _item(String label, bool isMet, ThemeData theme) {
    final accent = theme.brightness == Brightness.dark
        ? vibrantCyan
        : brandPrimary;
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isMet ? accent : theme.colorScheme.outline,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isMet ? accent : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
