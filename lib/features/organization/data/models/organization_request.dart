import 'package:freezed_annotation/freezed_annotation.dart';

part 'organization_request.freezed.dart';
part 'organization_request.g.dart';

/// Writable organization profile fields used for create and update
/// (`POST /v1/organizations`, `PUT /v1/organizations/{id}`).
///
/// `id`, `active` and `createdAt` are server-managed and intentionally omitted.
@freezed
abstract class OrganizationRequest with _$OrganizationRequest {
  const factory OrganizationRequest({
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'crn') String? crn,
    @JsonKey(name: 'vat') String? vat,
    @JsonKey(name: 'phone') String? phone,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'address') String? address,
    @JsonKey(name: 'city') String? city,
    @JsonKey(name: 'zip') String? zip,
    @JsonKey(name: 'country') String? country,
  }) = _OrganizationRequest;

  factory OrganizationRequest.fromJson(Map<String, dynamic> json) =>
      _$OrganizationRequestFromJson(json);
}
