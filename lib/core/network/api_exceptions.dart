import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({this.statusCode, required this.message});

  final int? statusCode;
  final String message;

  @override
  String toString() => message;

  static ApiException fromDio(DioException error) {
    final response = error.response;
    final data = response?.data;

    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String && detail.isNotEmpty) {
        return ApiException(statusCode: response?.statusCode, message: detail);
      }
      final title = data['title'];
      if (title is String && title.isNotEmpty) {
        return ApiException(statusCode: response?.statusCode, message: title);
      }
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return ApiException(statusCode: response?.statusCode, message: message);
      }
    }

    final statusMessage = response?.statusMessage;
    if (statusMessage != null && statusMessage.isNotEmpty) {
      return ApiException(
        statusCode: response?.statusCode,
        message: statusMessage,
      );
    }

    return ApiException(message: error.message ?? 'Network error');
  }
}
