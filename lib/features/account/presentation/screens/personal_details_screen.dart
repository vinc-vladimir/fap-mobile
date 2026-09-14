import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/screen_app_bar.dart';
import '../../../auth/presentation/widgets/glass_card.dart';
import '../../data/models/account_model.dart';
import '../providers/account_provider.dart';

/// Personal Details sub-screen pushed from the Account tab.
///
/// Physical-user profile CRUD backed by `GET /v1/account` (pre-fill) and
/// `PUT /v1/account/{id}` / `POST /v1/account` (save). Organization/company
/// contact fields are intentionally out of scope here.
class PersonalDetailsScreen extends ConsumerWidget {
  const PersonalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final account = ref.watch(accountProvider);

    return Scaffold(
      body: Column(
        children: [
          ScreenAppBar(title: l10n.personalDetails, mode: ScreenAppBarMode.sub),
          Expanded(
            child: account.when(
              data: (account) => _PersonalDetailsForm(account: account),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _LoadError(
                message: error.toString(),
                onRetry: () => ref.invalidate(accountProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.marginMain),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: theme.colorScheme.error),
            const SizedBox(height: AppDimensions.stackMd),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.stackLg),
            OutlinedButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}

class _PersonalDetailsForm extends ConsumerStatefulWidget {
  const _PersonalDetailsForm({required this.account});

  final AccountModel? account;

  @override
  ConsumerState<_PersonalDetailsForm> createState() =>
      _PersonalDetailsFormState();
}

class _PersonalDetailsFormState extends ConsumerState<_PersonalDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _city;
  late final TextEditingController _zip;
  late final TextEditingController _country;

  @override
  void initState() {
    super.initState();
    final a = widget.account;
    _firstName = TextEditingController(text: a?.firstName);
    _lastName = TextEditingController(text: a?.lastName);
    _phone = TextEditingController(text: a?.phone);
    _address = TextEditingController(text: a?.address);
    _city = TextEditingController(text: a?.city);
    _zip = TextEditingController(text: a?.zip);
    _country = TextEditingController(text: a?.country);
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _address.dispose();
    _city.dispose();
    _zip.dispose();
    _country.dispose();
    super.dispose();
  }

  String? _trimmed(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    final updated = (widget.account ?? const AccountModel()).copyWith(
      firstName: _trimmed(_firstName),
      lastName: _trimmed(_lastName),
      phone: _trimmed(_phone),
      address: _trimmed(_address),
      city: _trimmed(_city),
      zip: _trimmed(_zip),
      country: _trimmed(_country),
    );

    await ref.read(accountFormControllerProvider.notifier).save(updated);

    if (!mounted) return;
    final state = ref.read(accountFormControllerProvider);
    if (state.hasError) {
      showAppSnackBar(
        messenger,
        message: state.error?.toString() ?? l10n.errorSomethingWentWrong,
        isError: true,
      );
      return;
    }

    showAppSnackBar(messenger, message: l10n.personalDetailsSaved);
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/account');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.marginMain,
        AppDimensions.stackLg,
        AppDimensions.marginMain,
        AppDimensions.stackLg + MediaQuery.of(context).padding.bottom,
      ),
      child: GlassCard(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.personalDetailsSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppDimensions.stackLg),
              _buildField(
                theme: theme,
                controller: _firstName,
                label: l10n.firstName,
                icon: Icons.person_outline,
                textCapitalization: TextCapitalization.words,
                maxLength: 50,
              ),
              const SizedBox(height: AppDimensions.stackMd),
              _buildField(
                theme: theme,
                controller: _lastName,
                label: l10n.lastName,
                icon: Icons.badge_outlined,
                textCapitalization: TextCapitalization.words,
                maxLength: 50,
              ),
              const SizedBox(height: AppDimensions.stackMd),
              _buildField(
                theme: theme,
                controller: _phone,
                label: l10n.phoneNumber,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppDimensions.stackMd),
              _buildField(
                theme: theme,
                controller: _address,
                label: l10n.address,
                icon: Icons.home_outlined,
                textCapitalization: TextCapitalization.words,
                maxLength: 100,
              ),
              const SizedBox(height: AppDimensions.stackMd),
              _buildField(
                theme: theme,
                controller: _city,
                label: l10n.city,
                icon: Icons.location_city_outlined,
                textCapitalization: TextCapitalization.words,
                maxLength: 50,
              ),
              const SizedBox(height: AppDimensions.stackMd),
              _buildField(
                theme: theme,
                controller: _zip,
                label: l10n.zipCode,
                icon: Icons.markunread_mailbox_outlined,
                keyboardType: TextInputType.text,
                maxLength: 10,
              ),
              const SizedBox(height: AppDimensions.stackMd),
              _buildField(
                theme: theme,
                controller: _country,
                label: l10n.country,
                icon: Icons.public_outlined,
                textCapitalization: TextCapitalization.words,
                maxLength: 50,
              ),
              const SizedBox(height: AppDimensions.stackLg),
              _buildSaveButton(theme, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required ThemeData theme,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLength: maxLength,
      inputFormatters: maxLength == null
          ? null
          : [LengthLimitingTextInputFormatter(maxLength)],
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        prefixIcon: Icon(icon, color: theme.colorScheme.outline),
      ),
    );
  }

  Widget _buildSaveButton(ThemeData theme, AppLocalizations l10n) {
    final isLoading = ref.watch(accountFormControllerProvider).isLoading;
    return ElevatedButton(
      onPressed: isLoading ? null : _onSave,
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
              l10n.save,
              style: theme.textTheme.displaySmall?.copyWith(
                color: brandPrimary,
              ),
            ),
    );
  }
}
