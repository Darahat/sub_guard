import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_guard/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:sub_guard/features/onboarding/presentation/screens/product_tour_screen.dart';

void main() {
  testWidgets('OnboardingScreen renders slides, dots, and action buttons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );

    // Verify header and button
    expect(find.text('Master Your Subscriptions'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Take a Quick Interactive Tour'), findsOneWidget);
  });

  testWidgets('ProductTourScreen renders step 1 and progress bar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProductTourScreen(),
        ),
      ),
    );

    // Verify step 1 content
    expect(find.text('Adding Your Subscriptions'), findsOneWidget);
    expect(find.text('Skip Tour'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
