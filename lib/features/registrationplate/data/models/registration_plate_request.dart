import 'package:freezed_annotation/freezed_annotation.dart';

part 'registration_plate_request.freezed.dart';
part 'registration_plate_request.g.dart';

/// Writable registration plate fields
/// (`POST /v1/registration-plates`, `PUT /v1/registration-plates/{id}`).
///
/// [organizationId] is only sent on create when the caller is the `ORG_OWNER`
/// of an organization; the backend then creates a fleet plate. When omitted the
/// plate is personal. Ownership is immutable on update, so [organizationId] is
/// left null on update requests.
@freezed
abstract class RegistrationPlateRequest with _$RegistrationPlateRequest {
  const factory RegistrationPlateRequest({
    @JsonKey(name: 'number') String? number,
    @JsonKey(name: 'registrationDate') String? registrationDate,
    @JsonKey(name: 'expiresAt') String? expiresAt,
    @JsonKey(name: 'city') String? city,
    @JsonKey(name: 'country') String? country,
    @JsonKey(name: 'organizationId') String? organizationId,
  }) = _RegistrationPlateRequest;

  factory RegistrationPlateRequest.fromJson(Map<String, dynamic> json) =>
      _$RegistrationPlateRequestFromJson(json);
}
