import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_models.freezed.dart';
part 'health_models.g.dart';

/// Response of GET /actuator/health.
///
/// ```json
/// {
///   "status": "UP",
///   "groups": ["liveness", "readiness"],
///   "components": { "livenessState": { "status": "UP" }, ... }
/// }
/// ```
@freezed
abstract class HealthResponse with _$HealthResponse {
  const HealthResponse._();

  const factory HealthResponse({
    @JsonKey(name: 'status') required String status,
    @JsonKey(name: 'groups') List<String>? groups,
    @JsonKey(name: 'components') Map<String, dynamic>? components,
  }) = _HealthResponse;

  factory HealthResponse.fromJson(Map<String, dynamic> json) =>
      _$HealthResponseFromJson(json);

  bool get isUp => status.toLowerCase() == 'up';
}

/// Response of GET /actuator/info.
///
/// ```json
/// {
///   "build": {
///     "artifact": "fap-service",
///     "name": "Fuel Auto Pay service",
///     "time": "2026-07-31T10:46:03.267Z",
///     "version": "0.0.1-SNAPSHOT",
///     "group": "com.vincsoftware"
///   }
/// }
/// ```
@freezed
abstract class ServiceInfo with _$ServiceInfo {
  const factory ServiceInfo({@JsonKey(name: 'build') ServiceBuildInfo? build}) =
      _ServiceInfo;

  factory ServiceInfo.fromJson(Map<String, dynamic> json) =>
      _$ServiceInfoFromJson(json);
}

@freezed
abstract class ServiceBuildInfo with _$ServiceBuildInfo {
  const factory ServiceBuildInfo({
    @JsonKey(name: 'artifact') String? artifact,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'time') String? time,
    @JsonKey(name: 'version') String? version,
    @JsonKey(name: 'group') String? group,
  }) = _ServiceBuildInfo;

  factory ServiceBuildInfo.fromJson(Map<String, dynamic> json) =>
      _$ServiceBuildInfoFromJson(json);
}
