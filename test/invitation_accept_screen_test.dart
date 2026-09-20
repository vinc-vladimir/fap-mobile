import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fap_mobile/core/network/api_exceptions.dart';
import 'package:fap_mobile/features/organization/data/models/organization_invitation_details_model.dart';
import 'package:fap_mobile/features/organization/presentation/providers/invitation_accept_provider.dart';
import 'package:fap_mobile/features/organization/presentation/screens/invitation_accept_screen.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

const _token = 'tok-1';

Widget _app({
  required Future<OrganizationInvitationDetailsModel> Function() load,
}) {
  return ProviderScope(
    overrides: [
      invitationDetailsProvider(token: _token).overrideWith((ref) => load()),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('en'),
      home: InvitationAcceptScreen(token: _token),
    ),
  );
}

void main() {
  testWidgets('pending invitation shows the join form', (tester) async {
    await tester.pumpWidget(
      _app(
        load: () async => const OrganizationInvitationDetailsModel(
          email: 'new@example.com',
          organizationName: 'Acme',
          status: 'PENDING',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Join Organization'), findsOneWidget);
    expect(find.textContaining('Acme'), findsOneWidget);
    expect(find.text('new@example.com'), findsOneWidget);
    expect(find.text('JOIN ORGANIZATION'), findsOneWidget);
  });

  testWidgets('expired invitation (410) shows the expired state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        load: () => Future<OrganizationInvitationDetailsModel>.error(
          const ApiException(statusCode: 410, message: 'expired'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Invitation Expired'), findsOneWidget);
  });

  testWidgets('unknown token (404) shows the invalid state', (tester) async {
    await tester.pumpWidget(
      _app(
        load: () => Future<OrganizationInvitationDetailsModel>.error(
          const ApiException(statusCode: 404, message: 'not found'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Invalid Invitation'), findsOneWidget);
  });

  testWidgets('a non-pending invitation shows the not-available state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        load: () async => const OrganizationInvitationDetailsModel(
          email: 'new@example.com',
          organizationName: 'Acme',
          status: 'REVOKED',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Invitation Not Available'), findsOneWidget);
    expect(find.textContaining('Revoked'), findsOneWidget);
  });
}
