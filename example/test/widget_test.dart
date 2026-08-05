import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:native_natural_sort_example/src/home_page.dart';

void main() {
  testWidgets('App renders with title bar', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    // Title should be visible immediately even before sort completes.
    expect(find.text('Native Natural Sort'), findsOneWidget);
  });
}
