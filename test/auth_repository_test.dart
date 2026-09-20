import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fap_mobile/features/auth/data/repositories/auth_repository.dart';

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

AuthRepository _repository(_RecordingAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api'))
    ..httpClientAdapter = adapter;
  return AuthRepository(dio);
}

void main() {
  test('register posts email, password and role', () async {
    final adapter = _RecordingAdapter(statusCode: 200, body: '{}');

    await _repository(
      adapter,
    ).register(email: 'a@example.com', password: 'Passw0rd!');

    expect(adapter.lastRequest!.method, 'POST');
    expect(adapter.lastRequest!.path, '/v1/auth/registration');
    final body = adapter.lastRequest!.data as Map<String, dynamic>;
    expect(body['email'], 'a@example.com');
    expect(body['password'], 'Passw0rd!');
    expect(body['role'], 'USER');
    expect(body.containsKey('invitationToken'), isFalse);
  });

  test(
    'registerInvited posts password + invitationToken and returns tokens',
    () async {
      final adapter = _RecordingAdapter(
        statusCode: 200,
        body: '{"access_token":"acc","refresh_token":"ref"}',
      );

      final response = await _repository(
        adapter,
      ).registerInvited(password: 'Passw0rd!', invitationToken: 'tok-1');

      expect(adapter.lastRequest!.method, 'POST');
      expect(adapter.lastRequest!.path, '/v1/auth/registration');
      final body = adapter.lastRequest!.data as Map<String, dynamic>;
      expect(body['password'], 'Passw0rd!');
      expect(body['invitationToken'], 'tok-1');
      expect(body.containsKey('email'), isFalse);
      expect(response.accessToken, 'acc');
      expect(response.refreshToken, 'ref');
    },
  );
}
