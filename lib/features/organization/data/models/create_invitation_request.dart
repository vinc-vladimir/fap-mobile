import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_invitation_request.freezed.dart';
part 'create_invitation_request.g.dart';

/// Body for `POST /v1/organizations/{id}/invitations`.
@freezed
abstract class CreateInvitationRequest with _$CreateInvitationRequest {
  const factory CreateInvitationRequest({
    @JsonKey(name: 'email') required String email,
  }) = _CreateInvitationRequest;

  factory CreateInvitationRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateInvitationRequestFromJson(json);
}
