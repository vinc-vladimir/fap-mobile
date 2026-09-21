import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fap_mobile/core/network/api_exceptions.dart';
import 'package:fap_mobile/features/registrationplate/data/models/registration_plate_request.dart';
import 'package:fap_mobile/features/registrationplate/data/repositories/registration_plate_repository.dart';

/// Records the last request and returns a scripted response.
class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter({required this.statusCode, required this.body});

  int statusCode;
  String body;
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

RegistrationPlateRepository _repository(_RecordingAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api'))
    ..httpClientAdapter = adapter;
  return RegistrationPlateRepository(dio);
}

void main() {
  group('getRegistrationPlates', () {
    test('GETs the list and parses personal and fleet plates', () async {
      final adapter = _RecordingAdapter(
        statusCode: 200,
        body: jsonEncode([
          {
            'id': 'p-1',
            'number': 'NS846TA',
            'registrationDate': '2024-01-15',
            'expiresAt': '2025-12-01',
            'expiresSoon': false,
            'city': 'Sydney',
            'country': 'AU',
            'accountId': 'a-1',
            'organizationId': null,
          },
          {
            'id': 'p-2',
            'number': 'BG1456CD',
            'registrationDate': '2023-05-02',
            'expiresAt': '2024-10-01',
            'expiresSoon': true,
            'city': 'Belgrade',
            'country': 'RS',
            'accountId': null,
            'organizationId': 'org-1',
          },
        ]),
      );

      final plates = await _repository(adapter).getRegistrationPlates();

      expect(adapter.lastRequest!.method, 'GET');
      expect(adapter.lastRequest!.path, '/v1/registration-plates');
      expect(plates, hasLength(2));

      final personal = plates.first;
      expect(personal.isFleet, isFalse);
      expect(personal.number, 'NS846TA');
      expect(personal.registrationDateValue, DateTime(2024, 1, 15));
      expect(personal.expiresAtValue, DateTime(2025, 12, 1));
      expect(personal.isExpiringSoon, isFalse);

      final fleet = plates.last;
      expect(fleet.isFleet, isTrue);
      expect(fleet.organizationId, 'org-1');
      expect(fleet.isExpiringSoon, isTrue);
    });

    test('returns an empty list when the response is not a list', () async {
      final adapter = _RecordingAdapter(statusCode: 200, body: '{}');

      final plates = await _repository(adapter).getRegistrationPlates();

      expect(plates, isEmpty);
    });
  });

  group('createRegistrationPlate', () {
    test('POSTs a personal plate without organizationId', () async {
      final adapter = _RecordingAdapter(
        statusCode: 200,
        body: '{"id":"p-1","number":"NS846TA","accountId":"a-1"}',
      );

      final plate = await _repository(adapter).createRegistrationPlate(
        const RegistrationPlateRequest(number: 'NS846TA', city: 'Sydney'),
      );

      expect(adapter.lastRequest!.method, 'POST');
      expect(adapter.lastRequest!.path, '/v1/registration-plates');
      final body = adapter.lastRequest!.data as Map<String, dynamic>;
      expect(body['number'], 'NS846TA');
      expect(body['city'], 'Sydney');
      expect(body['organizationId'], isNull);
      expect(plate.id, 'p-1');
      expect(plate.isFleet, isFalse);
    });

    test('POSTs a fleet plate with organizationId', () async {
      final adapter = _RecordingAdapter(
        statusCode: 200,
        body: '{"id":"p-2","number":"BG1456CD","organizationId":"org-1"}',
      );

      final plate = await _repository(adapter).createRegistrationPlate(
        const RegistrationPlateRequest(
          number: 'BG1456CD',
          registrationDate: '2024-02-01',
          expiresAt: '2026-02-01',
          organizationId: 'org-1',
        ),
      );

      final body = adapter.lastRequest!.data as Map<String, dynamic>;
      expect(body['organizationId'], 'org-1');
      expect(body['registrationDate'], '2024-02-01');
      expect(body['expiresAt'], '2026-02-01');
      expect(plate.isFleet, isTrue);
    });
  });

  group('updateRegistrationPlate', () {
    test('PUTs to the plate path without organizationId', () async {
      final adapter = _RecordingAdapter(
        statusCode: 200,
        body: '{"id":"p-1","number":"NEW123","accountId":"a-1"}',
      );

      final plate = await _repository(adapter).updateRegistrationPlate(
        'p-1',
        const RegistrationPlateRequest(number: 'NEW123', city: 'Nis'),
      );

      expect(adapter.lastRequest!.method, 'PUT');
      expect(adapter.lastRequest!.path, '/v1/registration-plates/p-1');
      final body = adapter.lastRequest!.data as Map<String, dynamic>;
      expect(body['organizationId'], isNull);
      expect(plate.number, 'NEW123');
    });
  });

  group('deleteRegistrationPlate', () {
    test('DELETEs the plate path', () async {
      final adapter = _RecordingAdapter(statusCode: 200, body: '{}');

      await _repository(adapter).deleteRegistrationPlate('p-1');

      expect(adapter.lastRequest!.method, 'DELETE');
      expect(adapter.lastRequest!.path, '/v1/registration-plates/p-1');
    });
  });

  group('error mapping', () {
    test('maps a 403 on create to ApiException', () async {
      final adapter = _RecordingAdapter(
        statusCode: 403,
        body: jsonEncode({
          'title': 'Forbidden',
          'status': 403,
          'detail': 'The caller is not the ORG_OWNER of the organization.',
        }),
      );

      expect(
        () => _repository(
          adapter,
        ).createRegistrationPlate(const RegistrationPlateRequest(number: 'X')),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 403)
              .having(
                (e) => e.message,
                'message',
                'The caller is not the ORG_OWNER of the organization.',
              ),
        ),
      );
    });

    test('maps a 404 on update to ApiException', () async {
      final adapter = _RecordingAdapter(
        statusCode: 404,
        body: jsonEncode({
          'title': 'Not Found',
          'status': 404,
          'detail': 'Registration plate not found.',
        }),
      );

      expect(
        () => _repository(adapter).updateRegistrationPlate(
          'missing',
          const RegistrationPlateRequest(number: 'X'),
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 404)
              .having(
                (e) => e.message,
                'message',
                'Registration plate not found.',
              ),
        ),
      );
    });

    test('maps a 409 on create to ApiException', () async {
      final adapter = _RecordingAdapter(
        statusCode: 409,
        body: jsonEncode({
          'title': 'Conflict',
          'status': 409,
          'detail': 'A registration plate with the same number already exists.',
        }),
      );

      expect(
        () => _repository(adapter).createRegistrationPlate(
          const RegistrationPlateRequest(number: 'DUP'),
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 409)
              .having(
                (e) => e.message,
                'message',
                'A registration plate with the same number already exists.',
              ),
        ),
      );
    });
  });
}
