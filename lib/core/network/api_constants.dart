import 'package:flutter/foundation.dart';

abstract final class ApiConstants {
  /// Host loopback as seen from the emulator/simulator. The Android emulator
  /// exposes the host machine via 10.0.2.2; the iOS simulator shares the host
  /// network, so `localhost` works directly. Physical devices need the host's
  /// LAN IP instead — pass it via --dart-define if required.
  static String get _localHost {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return '10.0.2.2';
    }
    return 'localhost';
  }

  static String get localBaseUrl => 'http://$_localHost:8080/api';
  static const String devBaseUrl = 'https://dev.fng.rs/api';

  static String get baseUrl => kDebugMode ? localBaseUrl : devBaseUrl;

  // Spring Boot Actuator runs on the management port (8081 in dev).
  static String get localManagementBaseUrl => 'http://$_localHost:8081';
  static const String devManagementBaseUrl = 'https://dev.fng.rs:8081';

  static String get managementBaseUrl =>
      kDebugMode ? localManagementBaseUrl : devManagementBaseUrl;

  // ── Actuator endpoints ─────────────────────────────────────────
  static const String actuatorHealth = '/actuator/health';
  static const String actuatorInfo = '/actuator/info';

  // ── Secure storage keys ────────────────────────────────────────
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String passkeyEnabledKey = 'passkey_enabled';

  // ── Auth endpoints ─────────────────────────────────────────────
  static const String registration = '/v1/auth/registration';
  static const String confirmRegistration = '/v1/auth/confirm/registration';
  static const String login = '/v1/auth/login';
  static const String logout = '/v1/auth/logout';
  static const String tokenExchange = '/v1/auth/token/exchange';
  static const String webauthnLogin = '/v1/auth/login/webauthn';

  // ── WebAuthn endpoints (Spring Security managed filter) ────────
  static const String webauthnRegisterOptions = '/webauthn/register/options';
  static const String webauthnRegister = '/webauthn/register';
  static const String webauthnAuthenticateOptions =
      '/webauthn/authenticate/options';

  static const String forgottenPasswordEmail =
      '/v1/auth/forgotten/password/email';
  static const String forgottenPassword = '/v1/auth/forgotten/password';
  static const String changePassword = '/v1/account/change-password';

  // ── Account endpoints ──────────────────────────────────────────
  static const String account = '/v1/account';
  static const String organization = '/v1/account/{accountId}/organization';
  static const String vehicleRegistrationPlate =
      '/v1/account/vehicle-registration-plate';
  static const String paymentCards = '/v1/account/payment-cards';
}
