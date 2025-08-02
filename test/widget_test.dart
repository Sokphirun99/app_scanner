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

    // Verify that the app title is displayed on the home page.
    expect(find.text('PDF Scanner Pro'), findsOneWidget);

    // Verify that the navigation tabs are present
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Scanner'), findsOneWidget);
    expect(find.text('PDF Tools'), findsAtLeastNWidgets(1)); // Can appear in navigation and quick actions
    expect(find.text('Settings'), findsOneWidget);
    
    // Verify that the Quick Actions section is visible
    expect(find.text('Quick Actions'), findsOneWidget);
    
    // Verify that the scan button is present in quick actions
    expect(find.text('Scan Document'), findsOneWidget);
    
    // Verify that scanner icons are present (multiple instances expected)
    expect(find.byIcon(Icons.document_scanner_outlined), findsWidgets);
  });
}
