import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/auth_models.dart';

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  static const String _userRole = 'USER';

  /// POST /v1/auth/registration — creates a user (role is always USER) and
  /// emails a registration confirmation link with a one-time token.
  Future<void> register({
    required String email,
    required String password,
  }) async {
    try {
      await _dio.post(
        ApiConstants.registration,
        data: RegisterRequest(
          email: email,
          password: password,
          role: _userRole,
        ).toJson(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /v1/auth/confirm/registration — confirms email with a one-time token.
  Future<void> confirmRegistration({required String token}) async {
    try {
      await _dio.post(
        ApiConstants.confirmRegistration,
        data: EmailTokenRequest(token: token).toJson(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /v1/auth/login — basic email + password sign in.
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: LoginRequest(email: email, password: password).toJson(),
      );
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /v1/auth/logout — invalidates the server-side session (requires auth).
  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout, data: const <String, dynamic>{});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /v1/auth/token/exchange — consumes a one-time token (from an email
  /// link or the OAuth2 social login redirect) and returns a JWT.
  Future<AuthResponse> exchangeToken({required String token}) async {
    try {
      final response = await _dio.post(
        ApiConstants.tokenExchange,
        data: EmailTokenRequest(token: token).toJson(),
      );
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /v1/auth/login/webauthn — completes passkey sign in.
  Future<AuthResponse> loginWithPasskey(Map<String, dynamic> assertion) async {
    try {
      final response = await _dio.post(
        ApiConstants.webauthnLogin,
        data: assertion,
      );
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /v1/auth/forgotten/password/email — requests a password reset email.
  Future<void> sendForgottenPasswordEmail({required String email}) async {
    try {
      await _dio.post(
        ApiConstants.forgottenPasswordEmail,
        data: ForgottenPasswordEmailRequest(email: email).toJson(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /v1/auth/forgotten/password — sets a new password with the reset token.
  Future<void> resetPassword({
    required String token,
    required String password,
    required String confirmedPassword,
  }) async {
    try {
      await _dio.post(
        ApiConstants.forgottenPassword,
        data: ForgottenPasswordRequest(
          token: token,
          password: password,
          confirmedPassword: confirmedPassword,
        ).toJson(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /v1/account/change-password — updates the password of the logged-in user.
  Future<void> changePassword({
    required String password,
    required String confirmedPassword,
  }) async {
    try {
      await _dio.post(
        ApiConstants.changePassword,
        data: ChangePasswordRequest(
          password: password,
          confirmedPassword: confirmedPassword,
        ).toJson(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
