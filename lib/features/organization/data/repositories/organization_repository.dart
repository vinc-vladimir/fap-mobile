import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/organization_membership_model.dart';
import '../models/organization_model.dart';
import '../models/organization_request.dart';

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
