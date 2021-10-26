import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dweebs_eye/results.dart';

void main() {
  testWidgets('Results screen displays results', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: ResultsScreen(results: 'hello')));

    // Verify that results are displayed
    expect(find.text('hello'), findsOneWidget);
    expect(find.text('hola'), findsNothing);
    expect(find.byType(Text), findsOneWidget);
  });
}
