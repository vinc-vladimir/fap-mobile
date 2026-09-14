import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/account_model.dart';

/// Repository for the authenticated user's account profile, backed by the
/// live OpenAPI spec for `/v1/account` (operationId `getAccountOfLoggedInAuthUser`).
/// Authenticated via the shared [Dio]'s JWT interceptor.
class AccountRepository {
  AccountRepository(this._dio);

  final Dio _dio;

  /// GET /v1/account — returns the account profile of the logged-in user,
  /// including `createdAt` and `passwordChangedAt` (both ISO-8601, nullable).
  Future<AccountModel?> getAccount() async {
    try {
      final response = await _dio.get(ApiConstants.account);
      final data = response.data;
      if (data is! Map<String, dynamic>) return null;
      return AccountModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Persists the logged-in user's physical-user profile.
  ///
  /// `PUT /v1/account/{id}` when the account already has an `id` (the backend
  /// requires the body `authUserId` to match and `{id}` to be the caller's
  /// account). Falls back to `POST /v1/account`, which upserts by `authUserId`,
  /// if the id is missing. Only writable profile fields are sent — server-owned
  /// fields (`createdAt`, `passwordChangedAt`, `organizationId`) are omitted.
  Future<AccountModel> saveAccount(AccountModel account) async {
    final body = <String, dynamic>{
      'authUserId': account.authUserId,
      'firstName': account.firstName,
      'lastName': account.lastName,
      'phone': account.phone,
      'address': account.address,
      'city': account.city,
      'zip': account.zip,
      'country': account.country,
    };

    try {
      final id = account.id;
      final response = (id != null && id.isNotEmpty)
          ? await _dio.put('${ApiConstants.account}/$id', data: body)
          : await _dio.post(ApiConstants.account, data: body);
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ApiException(message: 'Unexpected response from server.');
      }
      return AccountModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
