import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fap_mobile/features/organization/presentation/providers/organization_providers.dart';
import 'package:fap_mobile/features/registrationplate/data/models/registration_plate_model.dart';
import 'package:fap_mobile/features/registrationplate/presentation/providers/registration_plate_providers.dart';
import 'package:fap_mobile/features/registrationplate/presentation/screens/registration_plate_form_screen.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

Widget _app({String? plateId, List<RegistrationPlateModel> plates = const []}) {
  return ProviderScope(
    overrides: [
      registrationPlatesProvider.overrideWith((ref) async => plates),
      organizationMembershipProvider.overrideWith((ref) async => null),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: RegistrationPlateFormScreen(plateId: plateId),
    ),
  );
}

void main() {
  testWidgets('create form requires a plate number', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Add Licence Plate'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Plate number is required.'), findsOneWidget);
  });

  testWidgets('create form uppercases the plate number input', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'ns846ta');
    await tester.pump();

    expect(find.text('NS846TA'), findsOneWidget);
  });

  testWidgets('edit form prefills the existing plate', (tester) async {
    await tester.pumpWidget(
      _app(
        plateId: 'p-1',
        plates: const [
          RegistrationPlateModel(
            id: 'p-1',
            number: 'NS846TA',
            registrationDate: '2024-01-15',
            expiresAt: '2025-12-01',
            city: 'Sydney',
            country: 'AU',
            accountId: 'a-1',
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Licence Plate'), findsOneWidget);
    expect(find.text('NS846TA'), findsOneWidget);
    expect(find.text('Sydney'), findsOneWidget);
    expect(find.text('AU'), findsOneWidget);
  });
}
