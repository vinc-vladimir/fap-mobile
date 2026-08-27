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
}
