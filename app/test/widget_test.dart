import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_memory_book/app.dart';

Future<void> _pumpAt(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const ProviderScope(child: MyApp()));
  // Let the trip list load; the loader animates forever, so no pumpAndSettle.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('Wide screen: drawer with brand and the first-book prompt',
      (tester) async {
    await _pumpAt(tester, const Size(1440, 900));
    expect(find.text('Travel Memory Book'), findsOneWidget);
    expect(find.text('Turn your trips into books'), findsOneWidget);
    expect(find.text('Create your first book'), findsOneWidget);
  });

  testWidgets('Phone width: bottom tab bar replaces the drawer',
      (tester) async {
    await _pumpAt(tester, const Size(390, 844));
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Journey stats'), findsOneWidget);
    expect(find.text('Turn your trips into books'), findsOneWidget);
  });
}
