// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in this test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures to the widget.

import 'package:flutter_test/flutter_test.dart';
import 'package:vyra/main.dart';

void main() {
  testWidgets('Vyra app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VyraApp());

    // Verify that the app shows the login screen
    expect(find.text('Vyra'), findsOneWidget);
    expect(find.text('Bienvenido de vuelta'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
