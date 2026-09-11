import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';

/// User-facing failure categories for the passkey ceremony. The UI/provider
/// maps each to a localized message.
enum PasskeyFailure {
  cancelled,
  noCredentials,
  googleSignInRequired,
  domainNotAssociated,
  noCreateOption,
  deviceUnsupported,
  syncUnavailable,
  credentialAlreadyExists,
  malformedChallenge,
  timeout,
  unhandled,
}

/// Exception thrown by [PasskeyService] after mapping a platform
/// `AuthenticatorException` to a user-facing category. Cancellations are
/// surfaced via [failure] == [PasskeyFailure.cancelled] so the UI can stay
/// silent.
class PasskeyException implements Exception {
  const PasskeyException(this.failure, [this.details]);

  final PasskeyFailure failure;
  final Object? details;

  bool get isCancellation => failure == PasskeyFailure.cancelled;

  @override
  String toString() => 'PasskeyException($failure)';
}

/// Thin wrapper around the `passkeys` platform authenticator.
///
/// - [register] / [authenticate] accept the decoded options JSON returned by
///   the backend and return the decoded credential/assertion JSON ready to be
///   POSTed back (register → `{ publicKey: { credential, label } }`; login →
///   `POST /v1/auth/login/webauthn`).
/// - All plugin `AuthenticatorException`s are mapped to [PasskeyException].
class PasskeyService {
  PasskeyService([PasskeyAuthenticator? authenticator])
    : _authenticator = authenticator ?? PasskeyAuthenticator();

  final PasskeyAuthenticator _authenticator;

  /// Whether the current platform can perform passkey ceremonies.
  Future<bool> isAvailable() async {
    final availability = _authenticator.getAvailability();
    if (kIsWeb) {
      return (await availability.web()).hasPasskeySupport;
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android =>
        (await availability.android()).hasPasskeySupport,
      TargetPlatform.iOS => (await availability.iOS()).hasPasskeySupport,
      _ => false,
    };
  }

  /// Runs the platform registration ceremony.
  ///
  /// [creationOptions] is the decoded `PublicKeyCredentialCreationOptions` from
  /// `POST /webauthn/register/options`. Returns the decoded
  /// `RegisterResponseType.toJson()` map to send to `POST /webauthn/register`.
  Future<Map<String, dynamic>> register(
    Map<String, dynamic> creationOptions,
  ) async {
    try {
      final request = RegisterRequestType.fromJsonString(
        jsonEncode(creationOptions),
      );
      final response = await _authenticator.register(request);
      return jsonDecode(response.toJsonString()) as Map<String, dynamic>;
    } on AuthenticatorException catch (e) {
      debugPrint('[passkey] register platform error: $e');
      throw PasskeyException(_mapFailure(e), e);
    }
  }

  /// Runs the platform authentication (assertion) ceremony.
  ///
  /// [requestOptions] is the decoded `PublicKeyCredentialRequestOptions` from
  /// `POST /webauthn/authenticate/options`. Returns the decoded
  /// `AuthenticateResponseType.toJson()` map to send to
  /// `POST /v1/auth/login/webauthn`.
  Future<Map<String, dynamic>> authenticate(
    Map<String, dynamic> requestOptions,
  ) async {
    try {
      final request = AuthenticateRequestType.fromJsonString(
        jsonEncode(requestOptions),
      );
      final response = await _authenticator.authenticate(request);
      return jsonDecode(response.toJsonString()) as Map<String, dynamic>;
    } on AuthenticatorException catch (e) {
      debugPrint('[passkey] authenticate platform error: $e');
      throw PasskeyException(_mapFailure(e), e);
    }
  }

  PasskeyFailure _mapFailure(AuthenticatorException e) {
    return switch (e) {
      PasskeyAuthCancelledException() => PasskeyFailure.cancelled,
      NoCredentialsAvailableException() => PasskeyFailure.noCredentials,
      MissingGoogleSignInException() => PasskeyFailure.googleSignInRequired,
      DomainNotAssociatedException() => PasskeyFailure.domainNotAssociated,
      NoCreateOptionException() => PasskeyFailure.noCreateOption,
      DeviceNotSupportedException() => PasskeyFailure.deviceUnsupported,
      PasskeyUnsupportedException() => PasskeyFailure.deviceUnsupported,
      SyncAccountNotAvailableException() => PasskeyFailure.syncUnavailable,
      ExcludeCredentialsCanNotBeRegisteredException() =>
        PasskeyFailure.credentialAlreadyExists,
      MalformedBase64Url() => PasskeyFailure.malformedChallenge,
      TimeoutException() => PasskeyFailure.timeout,
      _ => PasskeyFailure.unhandled,
    };
  }
}
