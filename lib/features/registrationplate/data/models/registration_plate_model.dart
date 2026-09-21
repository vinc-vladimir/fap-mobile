import 'package:freezed_annotation/freezed_annotation.dart';

part 'registration_plate_model.freezed.dart';
part 'registration_plate_model.g.dart';

/// Read model for a vehicle registration plate
/// (`GET /v1/registration-plates`, `GET /v1/registration-plates/{id}`).
///
/// A plate belongs either to the authenticated account (personal, `accountId`
/// set) or to an organization (fleet, `organizationId` set). Dates are ISO
/// `yyyy-MM-dd` strings as emitted by the backend.
@freezed
abstract class RegistrationPlateModel with _$RegistrationPlateModel {
  const RegistrationPlateModel._();

  const factory RegistrationPlateModel({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'number') String? number,
    @JsonKey(name: 'registrationDate') String? registrationDate,
    @JsonKey(name: 'expiresAt') String? expiresAt,
    @JsonKey(name: 'expiresSoon') bool? expiresSoon,
    @JsonKey(name: 'city') String? city,
    @JsonKey(name: 'country') String? country,
    @JsonKey(name: 'accountId') String? accountId,
    @JsonKey(name: 'organizationId') String? organizationId,
  }) = _RegistrationPlateModel;

  factory RegistrationPlateModel.fromJson(Map<String, dynamic> json) =>
      _$RegistrationPlateModelFromJson(json);

  /// Whether this plate belongs to an organization (fleet) rather than the
  /// authenticated account (personal).
  bool get isFleet => organizationId != null && organizationId!.isNotEmpty;

  /// Parsed registration date, or null when absent/unparseable.
  DateTime? get registrationDateValue => _parseDate(registrationDate);

  /// Parsed expiry date, or null when absent/unparseable.
  DateTime? get expiresAtValue => _parseDate(expiresAt);

  /// Whether the backend flagged this plate as nearing expiry.
  bool get isExpiringSoon => expiresSoon ?? false;

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
