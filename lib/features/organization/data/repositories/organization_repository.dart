import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/create_invitation_request.dart';
import '../models/organization_invitation_details_model.dart';
import '../models/organization_invitation_model.dart';
import '../models/organization_member_model.dart';
import '../models/organization_membership_model.dart';
import '../models/organization_model.dart';
import '../models/organization_request.dart';
import '../models/transfer_ownership_request.dart';

/// Repository for the organization (B2B fleet) domain, backed by the live
/// OpenAPI spec (`fap-service/doc/openapi/organization-api.yaml`).
///
/// Authenticated via the shared [Dio]'s JWT interceptor. Phase 1 covers the
/// organization profile lifecycle only — members, vehicles, payment cards and
/// invitations are added in later phases.
class OrganizationRepository {
  OrganizationRepository(this._dio);

  final Dio _dio;

  /// GET /v1/organizations/me — the organization the authenticated user
  /// belongs to, plus their role. Returns null when the user has no
  /// organization (both fields null in the response).
  Future<OrganizationMembershipModel?> getMembership() async {
    try {
      final response = await _dio.get(ApiConstants.organizationMe);
      final data = response.data;
      if (data is! Map<String, dynamic>) return null;
      return OrganizationMembershipModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /v1/organizations — creates an organization and makes the caller its
  /// `ORG_OWNER`. Fails with 409 if the caller already belongs to one.
  Future<OrganizationModel> createOrganization(
    OrganizationRequest request,
  ) async {
    return _organizationCall(
      () => _dio.post(ApiConstants.organizations, data: request.toJson()),
    );
  }

  /// GET /v1/organizations/{id} — full organization profile.
  Future<OrganizationModel> getOrganization(String organizationId) async {
    return _organizationCall(
      () => _dio.get(ApiConstants.organization(organizationId)),
    );
  }

  /// PUT /v1/organizations/{id} — updates the writable profile fields.
  /// Requires `ORG_OWNER`.
  Future<OrganizationModel> updateOrganization(
    String organizationId,
    OrganizationRequest request,
  ) async {
    return _organizationCall(
      () => _dio.put(
        ApiConstants.organization(organizationId),
        data: request.toJson(),
      ),
    );
  }

  /// POST /v1/organizations/{id}/deactivate — soft-deletes the organization.
  /// Requires `ORG_OWNER`.
  Future<void> deactivateOrganization(String organizationId) async {
    try {
      await _dio.post(ApiConstants.organizationDeactivate(organizationId));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /v1/organizations/{id}/members — lists the organization's members.
  /// Requires the caller to be a member.
  Future<List<OrganizationMemberModel>> getMembers(
    String organizationId,
  ) async {
    try {
      final response = await _dio.get(
        ApiConstants.organizationMembers(organizationId),
      );
      final data = response.data;
      if (data is! List) return const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(OrganizationMemberModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// DELETE /v1/organizations/{id}/members/{memberId} — removes a member.
  /// Requires `ORG_OWNER`; the owner cannot be removed.
  Future<void> removeMember(String organizationId, String memberId) async {
    try {
      await _dio.delete(
        ApiConstants.organizationMember(organizationId, memberId),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /v1/organizations/{id}/transfer-ownership — promotes [memberId] to
  /// `ORG_OWNER` and demotes the current owner. Requires `ORG_OWNER`.
  Future<void> transferOwnership(String organizationId, String memberId) async {
    try {
      await _dio.post(
        ApiConstants.organizationTransferOwnership(organizationId),
        data: TransferOwnershipRequest(memberId: memberId).toJson(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /v1/organizations/{id}/invitations — invites a not-yet-registered
  /// email to the organization and sends the invitation email. Requires
  /// `ORG_OWNER`.
  Future<OrganizationInvitationModel> inviteMember(
    String organizationId,
    String email,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.organizationInvitations(organizationId),
        data: CreateInvitationRequest(email: email).toJson(),
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ApiException(message: 'Unexpected response from server.');
      }
      return OrganizationInvitationModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /v1/organizations/{id}/invitations — lists the organization's
  /// invitations. Requires `ORG_OWNER`.
  Future<List<OrganizationInvitationModel>> getInvitations(
    String organizationId,
  ) async {
    try {
      final response = await _dio.get(
        ApiConstants.organizationInvitations(organizationId),
      );
      final data = response.data;
      if (data is! List) return const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(OrganizationInvitationModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// DELETE /v1/organizations/{id}/invitations/{invitationId} — revokes an
  /// invitation. Requires `ORG_OWNER`.
  Future<void> revokeInvitation(
    String organizationId,
    String invitationId,
  ) async {
    try {
      await _dio.delete(
        ApiConstants.organizationInvitation(organizationId, invitationId),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /v1/invitations/{token} — public invitation details used to display
  /// the invitation and prefill the invited sign-up. No auth required.
  Future<OrganizationInvitationDetailsModel> getInvitationDetails(
    String token,
  ) async {
    try {
      final response = await _dio.get(ApiConstants.invitationDetails(token));
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ApiException(message: 'Unexpected response from server.');
      }
      return OrganizationInvitationDetailsModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /v1/invitations/{token}/accept — joins the authenticated invitee to
  /// the organization as `ORG_MEMBER`. The caller's email must match the
  /// invitation.
  Future<OrganizationModel> acceptInvitation(String token) async {
    return _organizationCall(
      () => _dio.post(ApiConstants.invitationAccept(token)),
    );
  }

  Future<OrganizationModel> _organizationCall(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ApiException(message: 'Unexpected response from server.');
      }
      return OrganizationModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
