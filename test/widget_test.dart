import 'package:flutter_test/flutter_test.dart';
import 'package:itantra/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ITantraApp());
    expect(find.text('Choose Your Primary\nLanguage'), findsOneWidget);
  });
}
