import 'package:flutter_test/flutter_test.dart';
import 'package:travel_memory_book/app.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Travel Memory Book'), findsOneWidget);
  });
}
