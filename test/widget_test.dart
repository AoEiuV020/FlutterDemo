// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:demo/apps/app_a.dart';

void main() {
  testWidgets('应用 A 计数可以增加', (WidgetTester tester) async {
    await tester.pumpWidget(const AppA());

    expect(find.text('应用 A 计数：0'), findsOneWidget);
    expect(find.text('应用 A 计数：1'), findsNothing);

    await tester.tap(find.text('增加应用 A 计数'));
    await tester.pump();

    expect(find.text('应用 A 计数：0'), findsNothing);
    expect(find.text('应用 A 计数：1'), findsOneWidget);
  });
}
