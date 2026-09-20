import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fap_mobile/core/network/api_exceptions.dart';
import 'package:fap_mobile/features/organization/data/models/organization_invitation_status.dart';
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

  group('getOrganization', () {
    test('GETs the organization by id and parses the profile', () async {
      final adapter = _RecordingAdapter(
        statusCode: 200,
        body:
            '{"id":"org-1","name":"Acme","crn":"123","active":false,'
            '"createdAt":"2026-09-20T10:00:00Z"}',
      );

      final organization = await _repository(adapter).getOrganization('org-1');

      expect(adapter.lastRequest!.method, 'GET');
      expect(adapter.lastRequest!.path, '/v1/organizations/org-1');
      expect(organization.id, 'org-1');
      expect(organization.name, 'Acme');
      expect(organization.active, isFalse);
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

  group('getMembers', () {
    test('GETs the members list and parses roles', () async {
      final adapter = _RecordingAdapter(
        statusCode: 200,
        body: jsonEncode([
          {
            'id': 'm-1',
            'organizationId': 'org-1',
            'accountId': 'a-1',
            'role': 'ORG_OWNER',
            'firstName': 'Ada',
            'lastName': 'Lovelace',
            'email': 'ada@example.com',
          },
          {
            'id': 'm-2',
            'organizationId': 'org-1',
            'accountId': 'a-2',
            'role': 'ORG_MEMBER',
            'firstName': 'Alan',
            'lastName': 'Turing',
            'email': 'alan@example.com',
          },
        ]),
      );

      final members = await _repository(adapter).getMembers('org-1');

      expect(adapter.lastRequest!.method, 'GET');
      expect(adapter.lastRequest!.path, '/v1/organizations/org-1/members');
      expect(members, hasLength(2));
      expect(members.first.isOwner, isTrue);
      expect(members.first.displayName, 'Ada Lovelace');
      expect(members.last.roleValue, OrganizationRole.orgMember);
      expect(members.last.displayName, 'Alan Turing');
    });

    test('returns an empty list when the response is not a list', () async {
      final adapter = _RecordingAdapter(statusCode: 200, body: '{}');

      final members = await _repository(adapter).getMembers('org-1');

      expect(members, isEmpty);
    });
  });

  group('removeMember', () {
    test('DELETEs the member path', () async {
      final adapter = _RecordingAdapter(statusCode: 200, body: '{}');

      await _repository(adapter).removeMember('org-1', 'm-2');

      expect(adapter.lastRequest!.method, 'DELETE');
      expect(adapter.lastRequest!.path, '/v1/organizations/org-1/members/m-2');
    });
  });

  group('transferOwnership', () {
    test('POSTs the memberId body to the transfer path', () async {
      final adapter = _RecordingAdapter(statusCode: 200, body: '{}');

      await _repository(adapter).transferOwnership('org-1', 'm-2');

      expect(adapter.lastRequest!.method, 'POST');
      expect(
        adapter.lastRequest!.path,
        '/v1/organizations/org-1/transfer-ownership',
      );
      final body = adapter.lastRequest!.data as Map<String, dynamic>;
      expect(body['memberId'], 'm-2');
    });
  });

  group('inviteMember', () {
    test('POSTs the email body to the invitations path', () async {
      final adapter = _RecordingAdapter(
        statusCode: 200,
        body:
            '{"id":"inv-1","organizationId":"org-1","email":"new@example.com",'
            '"status":"PENDING","expiresAt":"2026-09-23T10:00:00Z"}',
      );

      final invitation = await _repository(
        adapter,
      ).inviteMember('org-1', 'new@example.com');

      expect(adapter.lastRequest!.method, 'POST');
      expect(adapter.lastRequest!.path, '/v1/organizations/org-1/invitations');
      final body = adapter.lastRequest!.data as Map<String, dynamic>;
      expect(body['email'], 'new@example.com');
      expect(invitation.id, 'inv-1');
      expect(invitation.isPending, isTrue);
    });
  });

  group('getInvitations', () {
    test('GETs the invitations list and parses statuses', () async {
      final adapter = _RecordingAdapter(
        statusCode: 200,
        body: jsonEncode([
          {
            'id': 'inv-1',
            'organizationId': 'org-1',
            'email': 'pending@example.com',
            'status': 'PENDING',
          },
          {
            'id': 'inv-2',
            'organizationId': 'org-1',
            'email': 'accepted@example.com',
            'status': 'ACCEPTED',
          },
        ]),
      );

      final invitations = await _repository(adapter).getInvitations('org-1');

      expect(adapter.lastRequest!.method, 'GET');
      expect(adapter.lastRequest!.path, '/v1/organizations/org-1/invitations');
      expect(invitations, hasLength(2));
      expect(invitations.first.isPending, isTrue);
      expect(
        invitations.last.statusValue,
        OrganizationInvitationStatus.accepted,
      );
    });
  });

  group('revokeInvitation', () {
    test('DELETEs the invitation path', () async {
      final adapter = _RecordingAdapter(statusCode: 200, body: '{}');

      await _repository(adapter).revokeInvitation('org-1', 'inv-1');

      expect(adapter.lastRequest!.method, 'DELETE');
      expect(
        adapter.lastRequest!.path,
        '/v1/organizations/org-1/invitations/inv-1',
      );
    });
  });

  group('getInvitationDetails', () {
    test('GETs the public invitation details', () async {
      final adapter = _RecordingAdapter(
        statusCode: 200,
        body:
            '{"email":"new@example.com","organizationName":"Acme",'
            '"status":"PENDING","expiresAt":"2026-09-23T10:00:00Z"}',
      );

      final details = await _repository(adapter).getInvitationDetails('tok-1');

      expect(adapter.lastRequest!.method, 'GET');
      expect(adapter.lastRequest!.path, '/v1/invitations/tok-1');
      expect(details.email, 'new@example.com');
      expect(details.organizationName, 'Acme');
      expect(details.statusValue, OrganizationInvitationStatus.pending);
    });
  });

  group('acceptInvitation', () {
    test('POSTs to the accept path and parses the organization', () async {
      final adapter = _RecordingAdapter(
        statusCode: 200,
        body: '{"id":"org-1","name":"Acme","active":true}',
      );

      final organization = await _repository(adapter).acceptInvitation('tok-1');

      expect(adapter.lastRequest!.method, 'POST');
      expect(adapter.lastRequest!.path, '/v1/invitations/tok-1/accept');
      expect(organization.id, 'org-1');
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

    test('maps a 404 on getOrganization to ApiException', () async {
      final adapter = _RecordingAdapter(
        statusCode: 404,
        body: jsonEncode({
          'title': 'Not Found',
          'status': 404,
          'detail': 'Organization not found.',
        }),
      );

      expect(
        () => _repository(adapter).getOrganization('missing'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 404)
              .having((e) => e.message, 'message', 'Organization not found.'),
        ),
      );
    });

    test('maps a 403 on removeMember to ApiException', () async {
      final adapter = _RecordingAdapter(
        statusCode: 403,
        body: jsonEncode({
          'title': 'Forbidden',
          'status': 403,
          'detail': 'The caller is not the ORG_OWNER of the organization.',
        }),
      );

      expect(
        () => _repository(adapter).removeMember('org-1', 'm-2'),
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

    test('maps a 400 on inviteMember to ApiException', () async {
      final adapter = _RecordingAdapter(
        statusCode: 400,
        body: jsonEncode({
          'title': 'Bad Request',
          'status': 400,
          'detail': 'Email already registered.',
        }),
      );

      expect(
        () => _repository(adapter).inviteMember('org-1', 'taken@example.com'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having((e) => e.message, 'message', 'Email already registered.'),
        ),
      );
    });
  });
}
