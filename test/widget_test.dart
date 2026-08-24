import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_guard/core/security/app_lock_screen.dart';

void main() {
  testWidgets('AppLockScreen renders lock UI and unlock button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AppLockScreen(),
        ),
      ),
    );

    // Verify lock screen elements
    expect(find.text('SubGuard is Locked'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
