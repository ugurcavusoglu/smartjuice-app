import 'package:flutter_test/flutter_test.dart';
import 'package:smartjuice_wear/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const WatchApp());
    expect(find.byType(WatchApp), findsOneWidget);
  });
}
