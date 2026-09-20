import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../auth/data/validation_constants.dart';
import '../../../auth/presentation/widgets/glass_card.dart';
import '../../../auth/presentation/widgets/hero_background.dart';
import '../../../auth/presentation/widgets/password_requirements_checklist.dart';
import '../../data/models/organization_invitation_details_model.dart';
import '../../data/models/organization_invitation_status.dart';
import '../providers/invitation_accept_provider.dart';

/// Public, token-driven screen opened from the organization-invitation email
/// deep link (`https://dev.fap.rs/org-invitation?token=…`).
///
/// Shows the invitation, lets the invitee set a password, registers them
/// (verified + active), joins the organization and lands in the app.
class InvitationAcceptScreen extends ConsumerWidget {
  const InvitationAcceptScreen({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final details = ref.watch(invitationDetailsProvider(token: token));

    return Scaffold(
      body: Stack(
        children: [
          const HeroBackground(),
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: screenHeight * 0.18,
              left: AppDimensions.marginMain,
              right: AppDimensions.marginMain,
              bottom: AppDimensions.stackLg + bottomInset,
            ),
            child: GlassCard(
              child: details.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: AppDimensions.stackLg,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
                error: (error, _) => _ErrorContent(error: error, token: token),
                data: (details) => details.statusValue.isPending
                    ? _AcceptForm(details: details, token: token)
                    : _HandledContent(status: details.statusValue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorContent extends ConsumerWidget {
  const _ErrorContent({required this.error, required this.token});

  final Object error;
  final String token;

  void _goToSignIn(BuildContext context) {
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
    router.go('/sign-in');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final statusCode = error is ApiException
        ? (error as ApiException).statusCode
        : null;

    final (title, body) = switch (statusCode) {
      410 => (l10n.invitationExpiredTitle, l10n.invitationExpiredBody),
      404 => (l10n.invitationInvalidTitle, l10n.invitationInvalidBody),
      _ => (l10n.invitationErrorTitle, l10n.invitationErrorBody),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.error_outline, size: 56, color: theme.colorScheme.error),
        const SizedBox(height: AppDimensions.stackMd),
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.stackSm),
        Text(
          body,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.stackLg),
        OutlinedButton(
          onPressed: () =>
              ref.invalidate(invitationDetailsProvider(token: token)),
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

class _HandledContent extends StatelessWidget {
  const _HandledContent({required this.status});

  final OrganizationInvitationStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final label = switch (status) {
      OrganizationInvitationStatus.accepted => l10n.invitationStatusAccepted,
      OrganizationInvitationStatus.revoked => l10n.invitationStatusRevoked,
      OrganizationInvitationStatus.expired => l10n.invitationStatusExpired,
      _ => l10n.invitationStatusUnknown,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.info_outline,
          size: 56,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: AppDimensions.stackMd),
        Text(
          l10n.invitationNotAvailableTitle,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.stackSm),
        Text(
          l10n.invitationNotAvailableBody(label),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _AcceptForm extends ConsumerStatefulWidget {
  const _AcceptForm({required this.details, required this.token});

  final OrganizationInvitationDetailsModel details;
  final String token;

  @override
  ConsumerState<_AcceptForm> createState() => _AcceptFormState();
}

class _AcceptFormState extends ConsumerState<_AcceptForm> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _onJoin() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    await ref
        .read(invitationAcceptControllerProvider.notifier)
        .accept(token: widget.token, password: _password.text);

    if (!mounted) return;
    final state = ref.read(invitationAcceptControllerProvider);
    if (state.hasError) {
      showAppSnackBar(
        messenger,
        message: state.error?.toString() ?? l10n.errorSomethingWentWrong,
        isError: true,
      );
      return;
    }

    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
    router.go('/account/organization');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isLoading = ref.watch(invitationAcceptControllerProvider).isLoading;
    final orgName = widget.details.organizationName?.trim();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppDimensions.stackSm),
          Text(
            l10n.invitationTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: brandPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.stackSm),
          Text(
            orgName != null && orgName.isNotEmpty
                ? l10n.invitationSubtitle(orgName)
                : l10n.invitationSubtitleFallback,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.stackLg),
          TextFormField(
            initialValue: widget.details.email,
            enabled: false,
            decoration: InputDecoration(
              labelText: l10n.emailAddress,
              prefixIcon: Icon(
                Icons.mail_outline,
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.stackMd),
          TextFormField(
            controller: _password,
            obscureText: _obscurePassword,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l10n.createPassword,
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
          PasswordRequirementsChecklist(password: _password.text),
          const SizedBox(height: AppDimensions.stackMd),
          TextFormField(
            controller: _confirm,
            obscureText: _obscureConfirm,
            decoration: InputDecoration(
              labelText: l10n.confirmPassword,
              hintText: l10n.repeatPasswordHint,
              prefixIcon: Icon(
                Icons.lock_outline,
                color: theme.colorScheme.outline,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                  color: theme.colorScheme.outline,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.validationPasswordRequired;
              }
              if (value != _password.text) {
                return l10n.matchError;
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.stackLg),
          ElevatedButton(
            onPressed: isLoading ? null : _onJoin,
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
                    l10n.invitationJoin,
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: brandPrimary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
