import 'package:freezed_annotation/freezed_annotation.dart';

import 'organization_role.dart';

part 'organization_member_model.freezed.dart';
part 'organization_member_model.g.dart';

/// A member of an organization (`GET /v1/organizations/{id}/members`).
@freezed
abstract class OrganizationMemberModel with _$OrganizationMemberModel {
  const OrganizationMemberModel._();

  const factory OrganizationMemberModel({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'organizationId') String? organizationId,
    @JsonKey(name: 'accountId') String? accountId,
    @JsonKey(name: 'role') String? role,
    @JsonKey(name: 'firstName') String? firstName,
    @JsonKey(name: 'lastName') String? lastName,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'createdAt') DateTime? createdAt,
  }) = _OrganizationMemberModel;

  factory OrganizationMemberModel.fromJson(Map<String, dynamic> json) =>
      _$OrganizationMemberModelFromJson(json);

  OrganizationRole get roleValue => OrganizationRole.fromWire(role);

  bool get isOwner => roleValue.isOwner;

  /// Full name when available, otherwise the email (or empty string).
  String get displayName {
    final name = [
      firstName,
      lastName,
    ].where((part) => part != null && part.trim().isNotEmpty).join(' ').trim();
    if (name.isNotEmpty) return name;
    return email ?? '';
  }
}
