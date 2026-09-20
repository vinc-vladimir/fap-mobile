import 'package:freezed_annotation/freezed_annotation.dart';

part 'organization_model.freezed.dart';
part 'organization_model.g.dart';

/// Read model for an organization profile (`GET /v1/organizations/{id}`).
///
/// Server-managed fields (`id`, `active`, `createdAt`) are read-only; only the
/// writable subset in [OrganizationRequest] is ever sent back.
@freezed
abstract class OrganizationModel with _$OrganizationModel {
  const factory OrganizationModel({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'crn') String? crn,
    @JsonKey(name: 'vat') String? vat,
    @JsonKey(name: 'phone') String? phone,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'address') String? address,
    @JsonKey(name: 'city') String? city,
    @JsonKey(name: 'zip') String? zip,
    @JsonKey(name: 'country') String? country,
    @JsonKey(name: 'active') bool? active,
    @JsonKey(name: 'createdAt') DateTime? createdAt,
  }) = _OrganizationModel;

  factory OrganizationModel.fromJson(Map<String, dynamic> json) =>
      _$OrganizationModelFromJson(json);
}
