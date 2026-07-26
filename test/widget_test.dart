import 'package:flutter_test/flutter_test.dart';
import 'package:sarraf_gold/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GoldApp());

    // Verify that we are on a screen with 'Altın' in the bottom navigation.
    expect(find.text('Altın'), findsAtLeastNWidgets(1));
    expect(find.text('Döviz'), findsOneWidget);
  });
}
