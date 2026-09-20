import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fap_mobile/features/organization/data/models/organization_invitation_model.dart';
import 'package:fap_mobile/features/organization/data/models/organization_membership_model.dart';
import 'package:fap_mobile/features/organization/data/repositories/organization_repository.dart';
import 'package:fap_mobile/features/organization/presentation/providers/organization_providers.dart';
import 'package:fap_mobile/features/organization/presentation/screens/organization_invitations_screen.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

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

const _pending = OrganizationInvitationModel(
  id: 'inv-1',
  organizationId: 'org-1',
  email: 'pending@example.com',
  status: 'PENDING',
);

const _accepted = OrganizationInvitationModel(
  id: 'inv-2',
  organizationId: 'org-1',
  email: 'accepted@example.com',
  status: 'ACCEPTED',
);

Widget _app({
  required List<OrganizationInvitationModel> invitations,
  required OrganizationMembershipModel membership,
  OrganizationRepository? repository,
}) {
  return ProviderScope(
    overrides: [
      organizationMembershipProvider.overrideWith((ref) async => membership),
      organizationInvitationsProvider.overrideWith((ref) async => invitations),
      if (repository != null)
        organizationRepositoryProvider.overrideWithValue(repository),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('en'),
      home: OrganizationInvitationsScreen(),
    ),
  );
}

OrganizationRepository _repository(_FakeAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api'))
    ..httpClientAdapter = adapter;
  return OrganizationRepository(dio);
}

void main() {
  testWidgets('renders invitations with status chips', (tester) async {
    await tester.pumpWidget(
      _app(
        invitations: const [_pending, _accepted],
        membership: const OrganizationMembershipModel(
          organizationId: 'org-1',
          role: 'ORG_OWNER',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('pending@example.com'), findsOneWidget);
    expect(find.text('accepted@example.com'), findsOneWidget);
    expect(find.text('PENDING'), findsOneWidget);
    expect(find.text('ACCEPTED'), findsOneWidget);
  });

  testWidgets('shows the empty state when there are no invitations', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        invitations: const [],
        membership: const OrganizationMembershipModel(
          organizationId: 'org-1',
          role: 'ORG_OWNER',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No invitations.'), findsOneWidget);
  });

  testWidgets('owner can revoke a pending invitation', (tester) async {
    final adapter = _FakeAdapter();
    await tester.pumpWidget(
      _app(
        invitations: const [_pending, _accepted],
        membership: const OrganizationMembershipModel(
          organizationId: 'org-1',
          role: 'ORG_OWNER',
        ),
        repository: _repository(adapter),
      ),
    );
    await tester.pumpAndSettle();

    // Only the pending row offers Revoke.
    expect(find.text('Revoke'), findsOneWidget);
    await tester.tap(find.text('Revoke'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Revoke').last);
    await tester.pumpAndSettle();

    expect(adapter.requests, hasLength(1));
    expect(adapter.requests.single.method, 'DELETE');
    expect(
      adapter.requests.single.path,
      '/v1/organizations/org-1/invitations/inv-1',
    );
  });
}
