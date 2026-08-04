import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

@freezed
abstract class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    @JsonKey(name: 'email') required String email,
    @JsonKey(name: 'password') required String password,
    @JsonKey(name: 'role') @Default('USER') String role,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}

@freezed
abstract class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    @JsonKey(name: 'email') required String email,
    @JsonKey(name: 'password') required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

@freezed
abstract class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') String? refreshToken,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

@freezed
abstract class EmailTokenRequest with _$EmailTokenRequest {
  const factory EmailTokenRequest({
    @JsonKey(name: 'token') required String token,
  }) = _EmailTokenRequest;

  factory EmailTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$EmailTokenRequestFromJson(json);
}

@freezed
abstract class ForgottenPasswordEmailRequest
    with _$ForgottenPasswordEmailRequest {
  const factory ForgottenPasswordEmailRequest({
    @JsonKey(name: 'email') required String email,
  }) = _ForgottenPasswordEmailRequest;

  factory ForgottenPasswordEmailRequest.fromJson(Map<String, dynamic> json) =>
      _$ForgottenPasswordEmailRequestFromJson(json);
}

@freezed
abstract class ForgottenPasswordRequest with _$ForgottenPasswordRequest {
  const factory ForgottenPasswordRequest({
    @JsonKey(name: 'token') required String token,
    @JsonKey(name: 'password') required String password,
    @JsonKey(name: 'confirmedPassword') required String confirmedPassword,
  }) = _ForgottenPasswordRequest;

  factory ForgottenPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ForgottenPasswordRequestFromJson(json);
}

@freezed
abstract class ChangePasswordRequest with _$ChangePasswordRequest {
  const factory ChangePasswordRequest({
    @JsonKey(name: 'password') required String password,
    @JsonKey(name: 'confirmedPassword') required String confirmedPassword,
  }) = _ChangePasswordRequest;

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordRequestFromJson(json);
}
