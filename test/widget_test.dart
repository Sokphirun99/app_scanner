// This is a basic Flutter widget test for the PDF Scanner app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_scanner/main.dart';

void main() {
  testWidgets('PDF Scanner app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // Wait for all animations to complete
    await tester.pumpAndSettle();

    // Verify that the app title is displayed.
    expect(find.text('PDF Scanner'), findsOneWidget);
    
    // Verify that the empty state message is displayed.
    expect(find.text('No Documents Scanned'), findsOneWidget);
    expect(find.text('Tap the scan button to start scanning documents'), findsOneWidget);
    
    // Verify that the document scanner icon is present in the empty state.
    expect(find.byIcon(Icons.document_scanner_outlined), findsWidgets);
    
    // Verify that the scan button is present
    expect(find.text('Scan Document'), findsOneWidget);
  });
}
