import 'package:freezed_annotation/freezed_annotation.dart';

import 'organization_invitation_status.dart';

part 'organization_invitation_model.freezed.dart';
part 'organization_invitation_model.g.dart';

/// An invitation to join an organization
/// (`GET /v1/organizations/{id}/invitations`).
@freezed
abstract class OrganizationInvitationModel with _$OrganizationInvitationModel {
  const OrganizationInvitationModel._();

  const factory OrganizationInvitationModel({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'organizationId') String? organizationId,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'expiresAt') DateTime? expiresAt,
    @JsonKey(name: 'createdAt') DateTime? createdAt,
  }) = _OrganizationInvitationModel;

  factory OrganizationInvitationModel.fromJson(Map<String, dynamic> json) =>
      _$OrganizationInvitationModelFromJson(json);

  OrganizationInvitationStatus get statusValue =>
      OrganizationInvitationStatus.fromWire(status);

  bool get isPending => statusValue.isPending;
}
