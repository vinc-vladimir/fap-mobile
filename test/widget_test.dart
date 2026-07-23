import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fap_mobile/main.dart';

void main() {
  testWidgets('App renders placeholder screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FapApp()));
    expect(find.text('Fuel Auto Pay'), findsWidgets);
  });
}
