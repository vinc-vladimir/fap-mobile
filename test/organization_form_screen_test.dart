import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fap_mobile/features/organization/data/models/organization_membership_model.dart';
import 'package:fap_mobile/features/organization/data/models/organization_model.dart';
import 'package:fap_mobile/features/organization/presentation/providers/organization_providers.dart';
import 'package:fap_mobile/features/organization/presentation/screens/organization_form_screen.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

Widget _wrap(
  Widget child, {
  OrganizationModel? organization,
  OrganizationMembershipModel? membership,
}) {
  return ProviderScope(
    overrides: [
      organizationProvider.overrideWith((ref) async => organization),
      organizationMembershipProvider.overrideWith((ref) async => membership),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: child,
    ),
  );
}

void main() {
  testWidgets('create form renders the fields and validates the email', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const OrganizationFormScreen(isEdit: false)));
    await tester.pumpAndSettle();

    expect(find.text('CREATE ORGANIZATION'), findsWidgets);
    expect(find.byType(TextFormField), findsNWidgets(9));

    // Email is the 5th field (index 4).
    await tester.enterText(find.byType(TextFormField).at(4), 'not-an-email');
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Save'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
    await tester.pump();

    expect(find.text('Please enter a valid email address'), findsOneWidget);
  });

  testWidgets('edit form prefills the existing organization', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const OrganizationFormScreen(isEdit: true),
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

    expect(find.text('EDIT ORGANIZATION'), findsWidgets);
    expect(find.text('Acme Fuel'), findsOneWidget);
    expect(find.text('12345678'), findsOneWidget);
  });
}
