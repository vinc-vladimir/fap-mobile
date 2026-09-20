import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fap_mobile/features/organization/data/models/organization_member_model.dart';
import 'package:fap_mobile/features/organization/data/models/organization_membership_model.dart';
import 'package:fap_mobile/features/organization/data/repositories/organization_repository.dart';
import 'package:fap_mobile/features/organization/presentation/providers/organization_providers.dart';
import 'package:fap_mobile/features/organization/presentation/screens/organization_members_screen.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

/// Records every request and returns an empty 200 JSON body.
class _FakeAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _owner = OrganizationMemberModel(
  id: 'm-1',
  organizationId: 'org-1',
  accountId: 'a-1',
  role: 'ORG_OWNER',
  firstName: 'Ada',
  lastName: 'Lovelace',
  email: 'ada@example.com',
);

const _member = OrganizationMemberModel(
  id: 'm-2',
  organizationId: 'org-1',
  accountId: 'a-2',
  role: 'ORG_MEMBER',
  firstName: 'Alan',
  lastName: 'Turing',
  email: 'alan@example.com',
);

Widget _app({
  required List<OrganizationMemberModel> members,
  required OrganizationMembershipModel membership,
  OrganizationRepository? repository,
}) {
  return ProviderScope(
    overrides: [
      organizationMembershipProvider.overrideWith((ref) async => membership),
      organizationMembersProvider.overrideWith((ref) async => members),
      if (repository != null)
        organizationRepositoryProvider.overrideWithValue(repository),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('en'),
      home: OrganizationMembersScreen(),
    ),
  );
}

OrganizationRepository _repository(_FakeAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api'))
    ..httpClientAdapter = adapter;
  return OrganizationRepository(dio);
}

void main() {
  testWidgets('renders the member list with names and role chips', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        members: const [_owner, _member],
        membership: const OrganizationMembershipModel(
          organizationId: 'org-1',
          role: 'ORG_OWNER',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(find.text('Alan Turing'), findsOneWidget);
    expect(find.text('OWNER'), findsOneWidget);
    expect(find.text('MEMBER'), findsOneWidget);
  });

  testWidgets('shows the empty state when there are no members', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        members: const [],
        membership: const OrganizationMembershipModel(
          organizationId: 'org-1',
          role: 'ORG_OWNER',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No members to show.'), findsOneWidget);
  });

  testWidgets('owner sees an action menu for non-owner members only', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        members: const [_owner, _member],
        membership: const OrganizationMembershipModel(
          organizationId: 'org-1',
          role: 'ORG_OWNER',
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Exactly one manageable member (m-2) → one action menu.
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
  });

  testWidgets('a plain member sees no action menu', (tester) async {
    await tester.pumpWidget(
      _app(
        members: const [_owner, _member],
        membership: const OrganizationMembershipModel(
          organizationId: 'org-1',
          role: 'ORG_MEMBER',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.more_vert), findsNothing);
  });

  testWidgets('owner can remove a member', (tester) async {
    final adapter = _FakeAdapter();
    await tester.pumpWidget(
      _app(
        members: const [_owner, _member],
        membership: const OrganizationMembershipModel(
          organizationId: 'org-1',
          role: 'ORG_OWNER',
        ),
        repository: _repository(adapter),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove member'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(adapter.requests, hasLength(1));
    expect(adapter.requests.single.method, 'DELETE');
    expect(adapter.requests.single.path, '/v1/organizations/org-1/members/m-2');
  });

  testWidgets('owner can transfer ownership', (tester) async {
    final adapter = _FakeAdapter();
    await tester.pumpWidget(
      _app(
        members: const [_owner, _member],
        membership: const OrganizationMembershipModel(
          organizationId: 'org-1',
          role: 'ORG_OWNER',
        ),
        repository: _repository(adapter),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transfer ownership'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transfer ownership').last);
    await tester.pumpAndSettle();

    expect(adapter.requests, hasLength(1));
    expect(adapter.requests.single.method, 'POST');
    expect(
      adapter.requests.single.path,
      '/v1/organizations/org-1/transfer-ownership',
    );
    final body = adapter.requests.single.data as Map<String, dynamic>;
    expect(body['memberId'], 'm-2');
  });
}
