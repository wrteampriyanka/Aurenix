import 'package:flutter_test/flutter_test.dart';

import 'package:aurenix/core/localization/app_translations.dart';
import 'package:aurenix/main.dart';

void main() {
  testWidgets('App starts on the login screen', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final translations = await AppTranslations.load();
    await tester.pumpWidget(MyApp(translations: translations));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsWidgets);
  });
}
