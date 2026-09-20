import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fap_mobile/core/network/api_exceptions.dart';
import 'package:fap_mobile/features/organization/data/models/organization_request.dart';
import 'package:fap_mobile/features/organization/data/models/organization_role.dart';
import 'package:fap_mobile/features/organization/data/repositories/organization_repository.dart';

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

OrganizationRepository _repository(_RecordingAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api'))
    ..httpClientAdapter = adapter;
  return OrganizationRepository(dio);
}

void main() {
  group('getMembership', () {
    test('parses an owner membership', () async {
      final adapter = _RecordingAdapter(
        statusCode: 200,
        body: '{"organizationId":"org-1","role":"ORG_OWNER"}',
      );

      final membership = await _repository(adapter).getMembership();

      expect(adapter.lastRequest!.method, 'GET');
      expect(adapter.lastRequest!.path, '/v1/organizations/me');
      expect(membership, isNotNull);
      expect(membership!.hasOrganization, isTrue);
      expect(membership.organizationId, 'org-1');
      expect(membership.roleValue, OrganizationRole.orgOwner);
      expect(membership.roleValue.isOwner, isTrue);
    });

    test('parses a member membership', () async {
      final adapter = _RecordingAdapter(
        statusCode: 200,
        body: '{"organizationId":"org-2","role":"ORG_MEMBER"}',
      );

      final membership = await _repository(adapter).getMembership();

      expect(membership!.roleValue, OrganizationRole.orgMember);
      expect(membership.roleValue.isOwner, isFalse);
    });

    test('handles a user with no organization (null fields)', () async {
      final adapter = _RecordingAdapter(
        statusCode: 200,
        body: '{"organizationId":null,"role":null}',
      );

      final membership = await _repository(adapter).getMembership();

      expect(membership, isNotNull);
      expect(membership!.hasOrganization, isFalse);
      expect(membership.organizationId, isNull);
    });
  });

  group('createOrganization', () {
    test('POSTs the writable request body and parses the response', () async {
      final adapter = _RecordingAdapter(
        statusCode: 200,
        body:
            '{"id":"org-9","name":"Acme","crn":"123","vat":"456",'
            '"active":true,"createdAt":"2026-09-20T10:00:00Z"}',
      );

      final organization = await _repository(adapter).createOrganization(
        const OrganizationRequest(name: 'Acme', crn: '123', vat: '456'),
      );

      expect(adapter.lastRequest!.method, 'POST');
      expect(adapter.lastRequest!.path, '/v1/organizations');
      final body = adapter.lastRequest!.data as Map<String, dynamic>;
      expect(body['name'], 'Acme');
      expect(body['crn'], '123');
      expect(body['vat'], '456');
      expect(body.containsKey('id'), isFalse);
      expect(body.containsKey('active'), isFalse);
      expect(organization.id, 'org-9');
      expect(organization.name, 'Acme');
      expect(organization.active, isTrue);
    });
  });

  group('updateOrganization', () {
    test('PUTs to the organization path', () async {
      final adapter = _RecordingAdapter(
        statusCode: 200,
        body: '{"id":"org-1","name":"Renamed","active":true}',
      );

      final organization = await _repository(
        adapter,
      ).updateOrganization('org-1', const OrganizationRequest(name: 'Renamed'));

      expect(adapter.lastRequest!.method, 'PUT');
      expect(adapter.lastRequest!.path, '/v1/organizations/org-1');
      expect(organization.name, 'Renamed');
    });
  });

  group('deactivateOrganization', () {
    test('POSTs to the deactivate path', () async {
      final adapter = _RecordingAdapter(statusCode: 200, body: '{}');

      await _repository(adapter).deactivateOrganization('org-1');

      expect(adapter.lastRequest!.method, 'POST');
      expect(adapter.lastRequest!.path, '/v1/organizations/org-1/deactivate');
    });
  });

  group('error mapping', () {
    test('maps an RFC 7807 ProblemDetail to ApiException', () async {
      final adapter = _RecordingAdapter(
        statusCode: 409,
        body: jsonEncode({
          'title': 'Conflict',
          'status': 409,
          'detail': 'The caller already belongs to an organization.',
        }),
      );

      expect(
        () => _repository(
          adapter,
        ).createOrganization(const OrganizationRequest(name: 'Acme')),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 409)
              .having(
                (e) => e.message,
                'message',
                'The caller already belongs to an organization.',
              ),
        ),
      );
    });
  });
}
