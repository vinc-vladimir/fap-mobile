import 'package:freezed_annotation/freezed_annotation.dart';

import 'organization_invitation_status.dart';

part 'organization_invitation_details_model.freezed.dart';
part 'organization_invitation_details_model.g.dart';

/// Public invitation details shown on the accept screen
/// (`GET /v1/invitations/{token}`).
@freezed
abstract class OrganizationInvitationDetailsModel
    with _$OrganizationInvitationDetailsModel {
  const OrganizationInvitationDetailsModel._();

  const factory OrganizationInvitationDetailsModel({
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'organizationName') String? organizationName,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'expiresAt') DateTime? expiresAt,
  }) = _OrganizationInvitationDetailsModel;

  factory OrganizationInvitationDetailsModel.fromJson(
    Map<String, dynamic> json,
  ) => _$OrganizationInvitationDetailsModelFromJson(json);

  OrganizationInvitationStatus get statusValue =>
      OrganizationInvitationStatus.fromWire(status);
}
