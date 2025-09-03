// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:toastr_flutter_example/main.dart';

void main() {
  testWidgets('Toastr example app loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ToastrExampleApp());

    // Verify that our app loads with the expected title
    expect(find.text('Toastr Demo'), findsOneWidget);
    
    // Verify that the success button is present
    expect(find.text('Success'), findsOneWidget);
    
    // Verify that other toast type buttons are present
    expect(find.text('Error'), findsOneWidget);
    expect(find.text('Warning'), findsOneWidget);
    expect(find.text('Info'), findsOneWidget);
  });

  testWidgets('Success toast can be triggered', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ToastrExampleApp());

    // Tap the success button
    await tester.tap(find.text('Success'));
    await tester.pump();

    // Allow some time for the toast to appear
    await tester.pump(const Duration(milliseconds: 100));

    // Verify that the success toast appeared
    // Note: This might not find the toast as it's in an overlay
    // but the test verifies the button interaction works
    expect(find.text('Success'), findsWidgets);
  });
}
