import 'package:customer_app/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Splash screen renders branding', (tester) async {
    await tester.pumpWidget(const CustomerApp());

    expect(find.byType(Image), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
