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
import '../../data/models/organization_model.dart';
import '../../data/models/organization_request.dart';
import '../providers/organization_providers.dart';

/// Create or edit the organization profile.
///
/// Backed by `POST /v1/organizations` (create) and
/// `PUT /v1/organizations/{id}` (edit). Only the writable profile fields are
/// sent; `id`, `active` and `createdAt` are server-managed.
class OrganizationFormScreen extends ConsumerWidget {
  const OrganizationFormScreen({super.key, required this.isEdit});

  final bool isEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    if (!isEdit) {
      return Scaffold(
        body: Column(
          children: [
            ScreenAppBar(
              title: l10n.createOrganization,
              mode: ScreenAppBarMode.sub,
            ),
            const Expanded(
              child: _OrganizationForm(organization: null, isEdit: false),
            ),
          ],
        ),
      );
    }

    final organization = ref.watch(organizationProvider);
    return Scaffold(
      body: Column(
        children: [
          ScreenAppBar(
            title: l10n.editOrganization,
            mode: ScreenAppBarMode.sub,
          ),
          Expanded(
            child: organization.when(
              data: (organization) => organization == null
                  ? Center(
                      child: Text(
                        l10n.errorSomethingWentWrong,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : _OrganizationForm(organization: organization, isEdit: true),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.marginMain),
                  child: Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrganizationForm extends ConsumerStatefulWidget {
  const _OrganizationForm({required this.organization, required this.isEdit});

  final OrganizationModel? organization;
  final bool isEdit;

  @override
  ConsumerState<_OrganizationForm> createState() => _OrganizationFormState();
}

class _OrganizationFormState extends ConsumerState<_OrganizationForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _crn;
  late final TextEditingController _vat;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;
  late final TextEditingController _city;
  late final TextEditingController _zip;
  late final TextEditingController _country;

  @override
  void initState() {
    super.initState();
    final o = widget.organization;
    _name = TextEditingController(text: o?.name);
    _crn = TextEditingController(text: o?.crn);
    _vat = TextEditingController(text: o?.vat);
    _phone = TextEditingController(text: o?.phone);
    _email = TextEditingController(text: o?.email);
    _address = TextEditingController(text: o?.address);
    _city = TextEditingController(text: o?.city);
    _zip = TextEditingController(text: o?.zip);
    _country = TextEditingController(text: o?.country);
  }

  @override
  void dispose() {
    _name.dispose();
    _crn.dispose();
    _vat.dispose();
    _phone.dispose();
    _email.dispose();
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

  String? _validateEmail(String? value) {
    final l10n = AppLocalizations.of(context)!;
    final email = value?.trim() ?? '';
    if (email.isEmpty) return null;
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    return valid ? null : l10n.validationEmailInvalid;
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    final request = OrganizationRequest(
      name: _trimmed(_name),
      crn: _trimmed(_crn),
      vat: _trimmed(_vat),
      phone: _trimmed(_phone),
      email: _trimmed(_email),
      address: _trimmed(_address),
      city: _trimmed(_city),
      zip: _trimmed(_zip),
      country: _trimmed(_country),
    );

    final controller = ref.read(organizationFormControllerProvider.notifier);
    if (widget.isEdit) {
      final id = widget.organization?.id;
      if (id == null || id.isEmpty) return;
      await controller.updateOrganization(id, request);
    } else {
      await controller.create(request);
    }

    if (!mounted) return;
    final state = ref.read(organizationFormControllerProvider);
    if (state.hasError) {
      showAppSnackBar(
        messenger,
        message: state.error?.toString() ?? l10n.errorSomethingWentWrong,
        isError: true,
      );
      return;
    }

    showAppSnackBar(
      messenger,
      message: widget.isEdit
          ? l10n.organizationSaved
          : l10n.organizationCreated,
    );
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/account/organization');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isLoading = ref.watch(organizationFormControllerProvider).isLoading;

    final body = SingleChildScrollView(
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
                widget.isEdit
                    ? l10n.organizationEditSubtitle
                    : l10n.organizationCreateSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppDimensions.stackLg),
              _buildField(
                theme: theme,
                controller: _name,
                label: l10n.organizationName,
                icon: Icons.business_outlined,
                textCapitalization: TextCapitalization.words,
                maxLength: 100,
              ),
              const SizedBox(height: AppDimensions.stackMd),
              _buildField(
                theme: theme,
                controller: _crn,
                label: l10n.crn,
                icon: Icons.confirmation_number_outlined,
                maxLength: 30,
              ),
              const SizedBox(height: AppDimensions.stackMd),
              _buildField(
                theme: theme,
                controller: _vat,
                label: l10n.vat,
                icon: Icons.receipt_long_outlined,
                maxLength: 30,
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
                controller: _email,
                label: l10n.companyEmail,
                icon: Icons.alternate_email_outlined,
                keyboardType: TextInputType.emailAddress,
                maxLength: 100,
                validator: _validateEmail,
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
              _buildSaveButton(theme, l10n, isLoading),
            ],
          ),
        ),
      ),
    );

    return body;
  }

  Widget _buildField({
    required ThemeData theme,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLength: maxLength,
      validator: validator,
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

  Widget _buildSaveButton(
    ThemeData theme,
    AppLocalizations l10n,
    bool isLoading,
  ) {
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
