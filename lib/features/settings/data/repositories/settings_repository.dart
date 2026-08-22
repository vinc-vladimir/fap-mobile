import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_exceptions.dart';

/// Repository for account-management operations performed from the Settings
/// screen (change password, soft-delete account). Authenticated via the shared
/// [dioProvider]'s JWT interceptor.
class SettingsRepository {
  SettingsRepository(this._dio);

  final Dio _dio;

  /// POST /v1/account/change-password — updates the password of the logged-in
  /// user.
  Future<void> changePassword({
    required String password,
    required String confirmedPassword,
  }) async {
    try {
      await _dio.post(
        ApiConstants.changePassword,
        data: {'password': password, 'confirmedPassword': confirmedPassword},
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// DELETE /v1/account — soft-deletes (deactivates) the logged-in account.
  Future<void> softDeleteAccount() async {
    try {
      await _dio.delete(ApiConstants.account);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
