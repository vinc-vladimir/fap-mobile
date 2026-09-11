import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/passkey_models.dart';

/// WebAuthn REST operations for the passkey feature.
///
/// The `/webauthn/**` endpoints are served by the backend's Spring Security
/// managed filter (JSON content negotiation). Login is handled by the existing
/// [AuthRepository.loginWithPasskey] — this repository covers only the
/// registration + authenticate-options calls.
class PasskeyRepository {
  PasskeyRepository(this._dio);

  final Dio _dio;

  /// POST /webauthn/register/options — returns `PublicKeyCredentialCreationOptions`.
  Future<Map<String, dynamic>> getRegisterOptions() async {
    try {
      final response = await _dio.post(
        ApiConstants.webauthnRegisterOptions,
        data: const <String, dynamic>{},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /webauthn/register — completes registration with the platform-created
  /// credential. The backend does not parse an `options` field; it reloads the
  /// creation options from its own options repository.
  Future<void> register({
    required Map<String, dynamic> credential,
    required String label,
  }) async {
    try {
      await _dio.post(
        ApiConstants.webauthnRegister,
        data: WebauthnRegisterRequest(
          publicKey: WebauthnRegisterPublicKey(
            credential: credential,
            label: label,
          ),
        ).toJson(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /webauthn/authenticate/options — returns `PublicKeyCredentialRequestOptions`
  /// (discoverable-credential mode, `allowCredentials: []`).
  Future<Map<String, dynamic>> getAuthenticateOptions() async {
    try {
      final response = await _dio.post(
        ApiConstants.webauthnAuthenticateOptions,
        data: const <String, dynamic>{},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
