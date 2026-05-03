import 'package:customer_app/src/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Splash screen renders branding', (tester) async {
    await tester.pumpWidget(const CustomerApp());

    expect(find.text('سوبر ماركت فتوش'), findsOneWidget);
    expect(find.text('توصيل سريع لحد البيت'), findsOneWidget);
  });
}
