// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orka_sports/core/services/secure_storage_service.dart';
import 'package:orka_sports/core/services/shared_prefs.dart';

import 'package:orka_sports/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final prefsService = SharedPreferencesService(sharedPrefs);
    final secureStorage = SecureStorageService();
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      prefsService: prefsService,
      secureStorage: secureStorage,
    ));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
