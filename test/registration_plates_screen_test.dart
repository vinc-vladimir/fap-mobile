import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fap_mobile/features/organization/data/models/organization_membership_model.dart';
import 'package:fap_mobile/features/organization/presentation/providers/organization_providers.dart';
import 'package:fap_mobile/features/registrationplate/data/models/registration_plate_model.dart';
import 'package:fap_mobile/features/registrationplate/presentation/providers/registration_plate_providers.dart';
import 'package:fap_mobile/features/registrationplate/presentation/screens/registration_plates_screen.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

Widget _app({
  required List<RegistrationPlateModel> plates,
  OrganizationMembershipModel? membership,
}) {
  return ProviderScope(
    overrides: [
      registrationPlatesProvider.overrideWith((ref) async => plates),
      organizationMembershipProvider.overrideWith((ref) async => membership),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('en'),
      home: RegistrationPlatesScreen(),
    ),
  );
}

void main() {
  testWidgets('private user sees personal plates with management actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        plates: const [
          RegistrationPlateModel(
            id: 'p-1',
            number: 'NS846TA',
            city: 'Sydney',
            country: 'AU',
            expiresAt: '2025-12-01',
            expiresSoon: false,
            accountId: 'a-1',
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('NS846TA'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);
    expect(find.text('ADD LICENSE PLATE'), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets('flags a plate that is expiring soon', (tester) async {
    await tester.pumpWidget(
      _app(
        plates: const [
          RegistrationPlateModel(
            id: 'p-2',
            number: 'BG1456CD',
            city: 'Belgrade',
            country: 'RS',
            expiresAt: '2024-10-01',
            expiresSoon: true,
            accountId: 'a-1',
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('EXPIRING SOON'), findsOneWidget);
    expect(find.text('ACTIVE'), findsNothing);
  });

  testWidgets('ORG_OWNER sees fleet plates with management actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        plates: const [
          RegistrationPlateModel(
            id: 'p-3',
            number: 'VIP-001-HQ',
            city: 'Berlin',
            country: 'DE',
            expiresAt: '2026-08-01',
            organizationId: 'org-1',
          ),
        ],
        membership: const OrganizationMembershipModel(
          organizationId: 'org-1',
          role: 'ORG_OWNER',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('VIP-001-HQ'), findsOneWidget);
    expect(find.text('CORPORATE FLEET'), findsOneWidget);
    expect(find.text('ADD LICENSE PLATE'), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets('ORG_MEMBER sees fleet plates read-only', (tester) async {
    await tester.pumpWidget(
      _app(
        plates: const [
          RegistrationPlateModel(
            id: 'p-3',
            number: 'VIP-001-HQ',
            country: 'DE',
            organizationId: 'org-1',
          ),
        ],
        membership: const OrganizationMembershipModel(
          organizationId: 'org-1',
          role: 'ORG_MEMBER',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('VIP-001-HQ'), findsOneWidget);
    expect(find.text('ADD LICENSE PLATE'), findsNothing);
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
    expect(find.textContaining('Only the owner can manage'), findsOneWidget);
  });

  testWidgets('shows the empty state with an add action for a private user', (
    tester,
  ) async {
    await tester.pumpWidget(_app(plates: const []));
    await tester.pumpAndSettle();

    expect(find.text('No Licence Plates'), findsOneWidget);
    expect(find.text('ADD LICENSE PLATE'), findsOneWidget);
  });

  testWidgets('shows an error state with retry when loading fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          registrationPlatesProvider.overrideWith(
            (ref) =>
                Future<List<RegistrationPlateModel>>.error(Exception('boom')),
          ),
          organizationMembershipProvider.overrideWith((ref) async => null),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: RegistrationPlatesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('boom'), findsOneWidget);
    expect(find.text('RETRY'), findsOneWidget);
  });
}
