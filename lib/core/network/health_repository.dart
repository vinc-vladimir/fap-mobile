import 'package:dio/dio.dart';

import 'api_constants.dart';
import 'api_exceptions.dart';
import 'health_models.dart';

class HealthRepository {
  HealthRepository(this._dio);

  final Dio _dio;

  /// GET /actuator/health — liveness/readiness probe of the fap-service.
  Future<HealthResponse> checkHealth() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.actuatorHealth,
      );
      return HealthResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /actuator/info — build/version metadata of the running service.
  Future<ServiceInfo> fetchServiceInfo() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.actuatorInfo,
      );
      return ServiceInfo.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
