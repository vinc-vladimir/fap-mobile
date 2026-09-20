import 'package:freezed_annotation/freezed_annotation.dart';

import 'organization_role.dart';

part 'organization_membership_model.freezed.dart';
part 'organization_membership_model.g.dart';

/// The organization membership of the authenticated account
/// (`GET /v1/organizations/me`).
///
/// A user belongs to at most one organization. When the caller has none, both
/// `organizationId` and `role` are null and the request still succeeds (200).
@freezed
abstract class OrganizationMembershipModel with _$OrganizationMembershipModel {
  const OrganizationMembershipModel._();

  const factory OrganizationMembershipModel({
    @JsonKey(name: 'organizationId') String? organizationId,
    @JsonKey(name: 'role') String? role,
  }) = _OrganizationMembershipModel;

  factory OrganizationMembershipModel.fromJson(Map<String, dynamic> json) =>
      _$OrganizationMembershipModelFromJson(json);

  /// Whether the account belongs to an organization.
  bool get hasOrganization =>
      organizationId != null && organizationId!.isNotEmpty;

  /// The caller's role, or [OrganizationRole.unknown] when absent/unrecognised.
  OrganizationRole get roleValue => OrganizationRole.fromWire(role);
}
