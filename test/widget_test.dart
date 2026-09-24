import 'package:flutter_test/flutter_test.dart';

import 'package:aurenix/main.dart';

void main() {
  testWidgets('App starts on the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsWidgets);
  });
}
