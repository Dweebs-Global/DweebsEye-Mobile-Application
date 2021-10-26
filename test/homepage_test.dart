import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dweebs_eye/homepage.dart';

void main() {
  testWidgets('Results screen displays results', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: HomePage('test', null)));

    // Verify that commands are displayed
    expect(find.text('text'), findsOneWidget);
    expect(find.text('object'), findsOneWidget);
    expect(find.text('face'), findsOneWidget);
    expect(find.text('map'), findsNothing);
    expect(find.byType(TextButton), findsNWidgets(3));
  });
}
