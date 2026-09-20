import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fap_mobile/features/organization/data/models/organization_membership_model.dart';
import 'package:fap_mobile/features/organization/data/models/organization_model.dart';
import 'package:fap_mobile/features/organization/presentation/providers/organization_providers.dart';
import 'package:fap_mobile/features/organization/presentation/screens/organization_screen.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

Widget _app({
  required OrganizationModel? organization,
  required OrganizationMembershipModel? membership,
}) {
  return ProviderScope(
    overrides: [
      organizationProvider.overrideWith((ref) async => organization),
      organizationMembershipProvider.overrideWith((ref) async => membership),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('en'),
      home: OrganizationScreen(),
    ),
  );
}

void main() {
  testWidgets('shows the empty state when the user has no organization', (
    tester,
  ) async {
    await tester.pumpWidget(_app(organization: null, membership: null));
    await tester.pumpAndSettle();

    expect(find.text('No Organization'), findsOneWidget);
    expect(find.text('CREATE ORGANIZATION'), findsOneWidget);
    expect(find.text('EDIT ORGANIZATION'), findsNothing);
  });

  testWidgets('shows owner actions for an ORG_OWNER', (tester) async {
    await tester.pumpWidget(
      _app(
        organization: const OrganizationModel(
          id: 'org-1',
          name: 'Acme Fuel',
          crn: '12345678',
          active: true,
        ),
        membership: const OrganizationMembershipModel(
          organizationId: 'org-1',
          role: 'ORG_OWNER',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Acme Fuel'), findsOneWidget);
    expect(find.text('OWNER'), findsOneWidget);
    expect(find.text('EDIT ORGANIZATION'), findsOneWidget);
    expect(find.text('DEACTIVATE ORGANIZATION'), findsOneWidget);
  });

  testWidgets('hides owner actions for an ORG_MEMBER', (tester) async {
    await tester.pumpWidget(
      _app(
        organization: const OrganizationModel(
          id: 'org-1',
          name: 'Acme Fuel',
          active: true,
        ),
        membership: const OrganizationMembershipModel(
          organizationId: 'org-1',
          role: 'ORG_MEMBER',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Acme Fuel'), findsOneWidget);
    expect(find.text('MEMBER'), findsOneWidget);
    expect(find.text('EDIT ORGANIZATION'), findsNothing);
    expect(find.text('DEACTIVATE ORGANIZATION'), findsNothing);
    expect(find.textContaining('Only the owner can edit'), findsOneWidget);
  });
}
