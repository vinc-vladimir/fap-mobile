import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fap_mobile/app/app.dart';
import 'package:fap_mobile/core/network/health_providers.dart';
import 'package:fap_mobile/core/network/health_repository.dart';

class _FakeAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.endsWith('/actuator/health')) {
      return ResponseBody.fromString(
        '{"status":"UP","groups":["liveness","readiness"],'
        '"components":{"livenessState":{"status":"UP"},'
        '"readinessState":{"status":"UP"}}}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    if (options.path.endsWith('/actuator/info')) {
      return ResponseBody.fromString(
        '{"build":{"artifact":"fap-service",'
        '"name":"Fuel Auto Pay service",'
        '"time":"2026-07-31T10:46:03.267Z",'
        '"version":"0.0.1-SNAPSHOT","group":"com.vincsoftware"}}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString('{}', 404);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  testWidgets('App renders sign-in screen on startup', (
    WidgetTester tester,
  ) async {
    final dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8081'))
      ..httpClientAdapter = _FakeAdapter();
    final repository = HealthRepository(dio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [healthRepositoryProvider.overrideWithValue(repository)],
        child: const FapApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('FUEL AUTO PAY'), findsWidgets);
  });
}
