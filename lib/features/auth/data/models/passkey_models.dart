import 'package:freezed_annotation/freezed_annotation.dart';

part 'passkey_models.freezed.dart';
part 'passkey_models.g.dart';

/// Request body for `POST /webauthn/register`.
///
/// `credential` is the decoded map of `RegisterResponseType.toJsonString()`
/// output (id, rawId, response{clientDataJSON, attestationObject}, type,
/// clientExtensionResults). The backend does NOT parse an `options` field —
/// it reloads the creation options from its own options repository.
@freezed
abstract class WebauthnRegisterRequest with _$WebauthnRegisterRequest {
  const factory WebauthnRegisterRequest({
    @JsonKey(name: 'publicKey') required WebauthnRegisterPublicKey publicKey,
  }) = _WebauthnRegisterRequest;

  factory WebauthnRegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$WebauthnRegisterRequestFromJson(json);
}

@freezed
abstract class WebauthnRegisterPublicKey with _$WebauthnRegisterPublicKey {
  const factory WebauthnRegisterPublicKey({
    @JsonKey(name: 'credential') required Map<String, dynamic> credential,
    @JsonKey(name: 'label') required String label,
  }) = _WebauthnRegisterPublicKey;

  factory WebauthnRegisterPublicKey.fromJson(Map<String, dynamic> json) =>
      _$WebauthnRegisterPublicKeyFromJson(json);
}

/// Response body for `POST /webauthn/register`.
@freezed
abstract class WebauthnRegisterResponse with _$WebauthnRegisterResponse {
  const factory WebauthnRegisterResponse({
    @JsonKey(name: 'success') @Default(false) bool success,
  }) = _WebauthnRegisterResponse;

  factory WebauthnRegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$WebauthnRegisterResponseFromJson(json);
}
