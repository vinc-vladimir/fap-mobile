import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/registration_plate_model.dart';
import '../models/registration_plate_request.dart';

/// Repository for vehicle registration plates, backed by the unified
/// `/v1/registration-plates` API (live OpenAPI spec).
///
/// The list endpoint resolves the scope server-side: it returns the caller's
/// organization fleet plates when they belong to an organization (any member),
/// otherwise their personal plates. Authenticated via the shared [Dio]'s JWT
/// interceptor.
class RegistrationPlateRepository {
  RegistrationPlateRepository(this._dio);

  final Dio _dio;

  /// GET /v1/registration-plates — fleet plates when the caller is an
  /// organization member, otherwise personal plates, most recently modified
  /// first.
  Future<List<RegistrationPlateModel>> getRegistrationPlates() async {
    try {
      final response = await _dio.get(ApiConstants.registrationPlates);
      final data = response.data;
      if (data is! List) return const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(RegistrationPlateModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /v1/registration-plates — creates a personal plate, or a fleet plate
  /// when [RegistrationPlateRequest.organizationId] is set (caller must be the
  /// `ORG_OWNER`). Fails with 409 when the number already exists.
  Future<RegistrationPlateModel> createRegistrationPlate(
    RegistrationPlateRequest request,
  ) async {
    return _registrationPlateCall(
      () => _dio.post(ApiConstants.registrationPlates, data: request.toJson()),
    );
  }

  /// PUT /v1/registration-plates/{id} — updates the writable fields. Ownership
  /// is immutable, so the request carries no `organizationId`.
  Future<RegistrationPlateModel> updateRegistrationPlate(
    String id,
    RegistrationPlateRequest request,
  ) async {
    return _registrationPlateCall(
      () =>
          _dio.put(ApiConstants.registrationPlate(id), data: request.toJson()),
    );
  }

  /// DELETE /v1/registration-plates/{id} — deletes a plate the caller owns
  /// (personal) or owns the organization of (`ORG_OWNER`).
  Future<void> deleteRegistrationPlate(String id) async {
    try {
      await _dio.delete(ApiConstants.registrationPlate(id));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<RegistrationPlateModel> _registrationPlateCall(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ApiException(message: 'Unexpected response from server.');
      }
      return RegistrationPlateModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
