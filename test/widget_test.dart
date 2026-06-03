// Smoke test for the Keeper app: verifies the login screen renders.

import 'package:flutter_test/flutter_test.dart';

import 'package:keeper2/main.dart';

void main() {
  testWidgets('Keeper boots into the operator login screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KeeperApp());
    await tester.pumpAndSettle();

    expect(find.text('Acceso de operador'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
