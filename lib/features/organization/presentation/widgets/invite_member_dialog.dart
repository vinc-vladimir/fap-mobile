import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

import '../../../../core/widgets/app_snack_bar.dart';
import '../../../auth/data/validation_constants.dart';
import '../providers/organization_providers.dart';

/// Opens the owner-only "invite member" dialog (email only).
Future<void> showInviteMemberDialog(
  BuildContext context, {
  required String organizationId,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _InviteMemberDialog(organizationId: organizationId),
  );
}

class _InviteMemberDialog extends ConsumerStatefulWidget {
  const _InviteMemberDialog({required this.organizationId});

  final String organizationId;

  @override
  ConsumerState<_InviteMemberDialog> createState() =>
      _InviteMemberDialogState();
}

class _InviteMemberDialogState extends ConsumerState<_InviteMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    await ref
        .read(organizationInvitationControllerProvider.notifier)
        .invite(widget.organizationId, _email.text.trim());

    if (!mounted) return;
    final state = ref.read(organizationInvitationControllerProvider);
    if (state.hasError) {
      showAppSnackBar(
        messenger,
        message: state.error?.toString() ?? l10n.errorSomethingWentWrong,
        isError: true,
      );
      return;
    }

    showAppSnackBar(messenger, message: l10n.invitationSent);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = ref
        .watch(organizationInvitationControllerProvider)
        .isLoading;

    return AlertDialog(
      title: Text(l10n.inviteMemberTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.inviteMemberBody,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n.emailAddress,
                hintText: l10n.emailHint,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.validationEmailRequired;
                }
                if (!emailRegex.hasMatch(value.trim())) {
                  return l10n.validationEmailInvalid;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: isLoading ? null : _submit,
          child: Text(l10n.invite),
        ),
      ],
    );
  }
}
