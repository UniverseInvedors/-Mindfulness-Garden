import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pranaverse/main.dart' as app;
import 'package:pranaverse/data/repositories/session_repository.dart';
import 'package:flutter/material.dart';

Future<void> _goBack(WidgetTester tester) async {
  // Prefer UI back buttons if present, otherwise use system back.
  final backIcon = find.byIcon(Icons.arrow_back).hitTestable();
  if (backIcon.evaluate().isNotEmpty) {
    await tester.tap(backIcon.first);
  } else {
    await tester.pageBack();
  }
  await tester.pumpAndSettle();
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration step = const Duration(milliseconds: 300),
  int maxSteps = 40,
}) async {
  for (var i = 0; i < maxSteps; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(step);
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Main flows: navigate and back works', (tester) async {
    final originalFlutterOnError = FlutterError.onError;
    final originalPlatformOnError = PlatformDispatcher.instance.onError;

    app.main();
    await _pumpUntilFound(tester, find.text('Quick Actions'));
    await tester.pumpAndSettle();

    // `app.main()` overrides global error handlers; restore so tests fail normally.
    FlutterError.onError = originalFlutterOnError;
    PlatformDispatcher.instance.onError = originalPlatformOnError;

    // Ensure we're on main menu (after splash redirect).
    expect(find.text('Quick Actions'), findsOneWidget);

    // Seed at least one real session so Progress shows real data.
    await SessionRepository().saveSession(
      durationMinutes: 7,
      meditationType: 'Focus',
    );

    // Progress
    final progressText = find.text('Progress');
    expect(progressText, findsWidgets);
    await tester.ensureVisible(progressText.first);
    await tester.tap(progressText.first);
    await _pumpUntilFound(tester, find.text('Your Progress'));
    await tester.pumpAndSettle();
    expect(find.text('Your Progress'), findsOneWidget);
    expect(find.text('TOTAL SESSIONS'), findsOneWidget);
    expect(find.text('1'), findsWidgets); // value shown somewhere in stats
    await _goBack(tester);
    expect(find.text('Quick Actions'), findsOneWidget);

    // Garden
    final gardenText = find.text('Visit Garden');
    expect(gardenText, findsOneWidget);
    await tester.ensureVisible(gardenText);
    await tester.tap(gardenText);
    await tester.pump(const Duration(seconds: 2));
    await _goBack(tester);
    expect(find.text('Quick Actions'), findsOneWidget);

    // Start Session (Meditation)
    final startText = find.text('Start Session');
    expect(startText, findsOneWidget);
    await tester.ensureVisible(startText);
    await tester.tap(startText);
    await tester.pump(const Duration(seconds: 2));
    await _goBack(tester);
    expect(find.text('Quick Actions'), findsOneWidget);
  });
}
