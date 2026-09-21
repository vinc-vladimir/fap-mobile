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
import '../../../organization/presentation/providers/organization_providers.dart';
import '../../data/models/registration_plate_model.dart';
import '../../data/models/registration_plate_request.dart';
import '../providers/registration_plate_providers.dart';

/// Create or edit a vehicle registration plate.
///
/// Backed by `POST /v1/registration-plates` (create) and
/// `PUT /v1/registration-plates/{id}` (edit). On create, an `ORG_OWNER` sends
/// their `organizationId` so the plate is added to the fleet; a private user
/// omits it and gets a personal plate. Ownership is immutable on edit.
class RegistrationPlateFormScreen extends ConsumerWidget {
  const RegistrationPlateFormScreen({super.key, this.plateId});

  /// Null for create; the plate id for edit.
  final String? plateId;

  bool get _isEdit => plateId != null && plateId!.isNotEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    if (!_isEdit) {
      return _FormScaffold(
        title: l10n.addPlateTitle,
        child: const _RegistrationPlateForm(plate: null),
      );
    }

    final plates = ref.watch(registrationPlatesProvider);
    return _FormScaffold(
      title: l10n.editPlateTitle,
      child: plates.when(
        data: (list) {
          RegistrationPlateModel? plate;
          for (final candidate in list) {
            if (candidate.id == plateId) {
              plate = candidate;
              break;
            }
          }
          if (plate == null) {
            return _CenteredMessage(message: l10n.errorSomethingWentWrong);
          }
          return _RegistrationPlateForm(plate: plate);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _CenteredMessage(message: error.toString()),
      ),
    );
  }
}

class _FormScaffold extends StatelessWidget {
  const _FormScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ScreenAppBar(title: title, mode: ScreenAppBarMode.sub),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.marginMain),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _RegistrationPlateForm extends ConsumerStatefulWidget {
  const _RegistrationPlateForm({required this.plate});

  final RegistrationPlateModel? plate;

  @override
  ConsumerState<_RegistrationPlateForm> createState() =>
      _RegistrationPlateFormState();
}

class _RegistrationPlateFormState
    extends ConsumerState<_RegistrationPlateForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _number;
  late final TextEditingController _city;
  late final TextEditingController _country;
  DateTime? _registrationDate;
  DateTime? _expiryDate;

  bool get _isEdit => widget.plate != null;

  @override
  void initState() {
    super.initState();
    final plate = widget.plate;
    _number = TextEditingController(text: plate?.number);
    _city = TextEditingController(text: plate?.city);
    _country = TextEditingController(text: plate?.country);
    _registrationDate = plate?.registrationDateValue;
    _expiryDate = plate?.expiresAtValue;
  }

  @override
  void dispose() {
    _number.dispose();
    _city.dispose();
    _country.dispose();
    super.dispose();
  }

  String? _trimmed(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  String? _toIso(DateTime? date) {
    if (date == null) return null;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year.toString().padLeft(4, '0')}-$month-$day';
  }

  String? _validateNumber(String? value) {
    final l10n = AppLocalizations.of(context)!;
    final number = value?.trim() ?? '';
    if (number.isEmpty) return l10n.plateNumberRequired;
    if (number.length > 20) return l10n.plateNumberTooLong;
    return null;
  }

  /// The organization to attach a new plate to: only an `ORG_OWNER` creates a
  /// fleet plate; everyone else creates a personal plate.
  String? _organizationIdForCreate() {
    final membership = ref.read(organizationMembershipProvider).value;
    if (membership == null || !membership.hasOrganization) return null;
    if (!membership.roleValue.isOwner) return null;
    return membership.organizationId;
  }

  Future<void> _pickDate({
    required DateTime? current,
    required ValueChanged<DateTime?> onPicked,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year - 30),
      lastDate: DateTime(now.year + 30),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    final request = RegistrationPlateRequest(
      number: _trimmed(_number),
      registrationDate: _toIso(_registrationDate),
      expiresAt: _toIso(_expiryDate),
      city: _trimmed(_city),
      country: _trimmed(_country),
      organizationId: _isEdit ? null : _organizationIdForCreate(),
    );

    final controller = ref.read(registrationPlateControllerProvider.notifier);
    final id = widget.plate?.id;
    if (_isEdit && id != null && id.isNotEmpty) {
      await controller.updatePlate(id, request);
    } else {
      await controller.create(request);
    }

    if (!mounted) return;
    final state = ref.read(registrationPlateControllerProvider);
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
      message: _isEdit ? l10n.plateUpdated : l10n.plateCreated,
    );
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/account/plates');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isLoading = ref.watch(registrationPlateControllerProvider).isLoading;

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
              TextFormField(
                controller: _number,
                textCapitalization: TextCapitalization.characters,
                maxLength: 20,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(20),
                  UpperCaseTextFormatter(),
                ],
                validator: _validateNumber,
                decoration: InputDecoration(
                  labelText: l10n.plateNumber,
                  hintText: l10n.plateNumberHint,
                  counterText: '',
                  prefixIcon: Icon(
                    Icons.directions_car_outlined,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.stackMd),
              _DateField(
                label: l10n.registrationDate,
                hint: l10n.registrationDateHint,
                value: _registrationDate,
                onTap: () => _pickDate(
                  current: _registrationDate,
                  onPicked: (date) => setState(() => _registrationDate = date),
                ),
                onClear: () => setState(() => _registrationDate = null),
              ),
              const SizedBox(height: AppDimensions.stackMd),
              _DateField(
                label: l10n.expiryDate,
                hint: l10n.expiryDateHint,
                value: _expiryDate,
                onTap: () => _pickDate(
                  current: _expiryDate,
                  onPicked: (date) => setState(() => _expiryDate = date),
                ),
                onClear: () => setState(() => _expiryDate = null),
              ),
              const SizedBox(height: AppDimensions.stackMd),
              TextFormField(
                controller: _city,
                textCapitalization: TextCapitalization.words,
                maxLength: 50,
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                decoration: InputDecoration(
                  labelText: l10n.city,
                  counterText: '',
                  prefixIcon: Icon(
                    Icons.location_city_outlined,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.stackMd),
              TextFormField(
                controller: _country,
                textCapitalization: TextCapitalization.words,
                maxLength: 50,
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                decoration: InputDecoration(
                  labelText: l10n.country,
                  counterText: '',
                  prefixIcon: Icon(
                    Icons.public_outlined,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.stackLg),
              ElevatedButton(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Read-only date field that opens a date picker on tap.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.hint,
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final String hint;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final display = value == null
        ? null
        : MaterialLocalizations.of(context).formatMediumDate(value!);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            Icons.calendar_today_outlined,
            color: theme.colorScheme.outline,
          ),
          suffixIcon: value == null
              ? null
              : IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close),
                  iconSize: 18,
                  color: theme.colorScheme.outline,
                  tooltip: l10n.clearDate,
                ),
        ),
        child: Text(
          display ?? hint,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: display == null
                ? theme.colorScheme.outline.withValues(alpha: 0.7)
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Uppercases plate input as the user types.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
