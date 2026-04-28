// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:products_task/main.dart';

void main() {
  testWidgets('App boots to products home', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // The home screen triggers a remote fetch via Dio. In widget tests we let
    // the request time out so the repository falls back to local storage and
    // the test framework has no pending timers.
    await tester.pump();
    await tester.pump(const Duration(seconds: 16));
    await tester.pumpAndSettle();

    // Basic smoke assertions for this app (not the default counter template).
    expect(find.text('Products'), findsOneWidget);
    expect(find.byType(Scaffold), findsWidgets);
  });
}
